#!/bin/bash
set -e

# Configuration
DB_CONTAINER="auth_db"
DB_USER="postgres"
DB_NAME="maintenance_db"
DB_PORT="5432"

echo "Checking maintenance DB migration status..."

docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
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

APPLIED=$(docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "SELECT version FROM schema_migrations" 2>/dev/null || echo "")

for file in $(ls migrations/*.sql | sort); do
    if [[ $file == *"_rollback.sql" ]]; then
        continue
    fi

    filename=$(basename "$file" .sql)
    version="$filename"

    if echo "$APPLIED" | grep -q "$version"; then
        continue
    fi

    echo "Applying migration to maintenance_db: $version"

    if docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -v ON_ERROR_STOP=1 < "$file"; then
        docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
            INSERT INTO schema_migrations (version, name, success, applied_at)
            VALUES ('$version', '$version', true, NOW())
        ON CONFLICT (version) DO NOTHING;" > /dev/null
        echo "✅ Applied $version"
    else
        echo "❌ Failed to apply $version"
        exit 1
    fi

done

echo "All maintenance_db migrations up to date."
