#!/bin/bash
# Removido 'set -e' global para evitar interrupção no primeiro erro do comando psql

# Configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_NAME="auth_db"

# Base command for psql without docker
PSQL_CMD="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME"

echo "Checking migration status..."

# 1. Ensure schema_migrations table exists
$PSQL_CMD -c "
CREATE TABLE IF NOT EXISTS schema_migrations (
    id SERIAL PRIMARY KEY,
    version VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT TRUE,
    execution_time_ms INTEGER,
    error_message TEXT,
    checksum VARCHAR(64)
);" > /dev/null 2>&1 || true

# 2. Get list of applied migrations from DB
APPLIED=$($PSQL_CMD -t -c "SELECT version FROM schema_migrations" 2>/dev/null || echo "")

# Trackers
HAS_ERRORS=0

# 3. Iterate over all .sql files in migrations directory, sorted by name
for file in $(ls migrations/*.sql | sort 2>/dev/null); do
    # Skip rollback files
    if [[ $file == *"_rollback.sql" ]]; then
        continue
    fi
    
    filename=$(basename "$file" .sql)
    version="$filename"
    
    # 4. Check if this version is in the APPLIED list
    if echo "$APPLIED" | grep -q "$version"; then
        echo "⏭️  Skipping $version (already recorded in DB)"
        continue
    fi
    
    echo "Applying migration: $version"
    
    # 5. Run the migration without stopping on failure
    if $PSQL_CMD -v ON_ERROR_STOP=1 -f "$file" > /dev/null 2>&1; then
        # 6. Record success
        $PSQL_CMD -c "
            INSERT INTO schema_migrations (version, name, success, applied_at)
            VALUES ('$version', '$version', true, NOW())
            ON CONFLICT (version) DO NOTHING;" > /dev/null
        echo "✅ Applied $version"
    else
        echo "⚠️ Failed/Skipped SQL execution for $version (moving to next)"
        HAS_ERRORS=1
    fi
done

if [ $HAS_ERRORS -eq 0 ]; then
    echo "All migrations processed successfully."
else
    echo "Migrations process completed with warnings/skipped files."
fi