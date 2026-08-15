# Configurações do Banco de Dados
$env:PGHOST = if ($env:DB_HOST) { $env:DB_HOST } else { "localhost" }
$env:PGPORT = if ($env:DB_PORT) { $env:DB_PORT } else { "5432" }
$env:PGUSER = if ($env:DB_USER) { $env:DB_USER } else { "postgres" }
$DB_NAME    = "auth_db"

Write-Host "Checking migration status..." -ForegroundColor Cyan

# 1. Garantir que a tabela schema_migrations exista
$createTableSql = @"
CREATE TABLE IF NOT EXISTS schema_migrations (
    id SERIAL PRIMARY KEY,
    version VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT TRUE,
    execution_time_ms INTEGER,
    error_message TEXT,
    checksum VARCHAR(64)
);
"@

psql -d $DB_NAME -c $createTableSql *> $null

# 2. Obter a lista de migrações já aplicadas
$APPLIED = psql -d $DB_NAME -t -c "SELECT version FROM schema_migrations" 2>$null

# Controle de erros
$hasErrors = $false

# 3. Listar e ordenar os arquivos .sql na pasta migrations
$migrationFiles = Get-ChildItem -Path "migrations" -Filter "*.sql" | 
                  Where-Object { $_.Name -notlike "*_rollback.sql" } | 
                  Sort-Object Name

foreach ($file in $migrationFiles) {
    $version = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    
    # 4. Verificar se a versão já está na lista de migrações aplicadas
    if ($APPLIED -and ($APPLIED -match [regex]::Escape($version))) {
        Write-Host "⏭️  Skipping $version (already recorded in DB)" -ForegroundColor Gray
        continue
    }
    
    Write-Host "Applying migration: $version" -ForegroundColor Yellow
    
    # 5. Executar a migração no psql
    psql -d $DB_NAME -v ON_ERROR_STOP=1 -f $file.FullName *> $null
    
    if ($LASTEXITCODE -eq 0) {
        # 6. Registrar sucesso
        $insertSql = "INSERT INTO schema_migrations (version, name, success, applied_at) VALUES ('$version', '$version', true, NOW()) ON CONFLICT (version) DO NOTHING;"
        psql -d $DB_NAME -c $insertSql *> $null
        Write-Host "✅ Applied $version" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Failed/Skipped SQL execution for $version (moving to next)" -ForegroundColor DarkYellow
        $hasErrors = $true
    }
}

if (-not $hasErrors) {
    Write-Host "All migrations processed successfully." -ForegroundColor Green
} else {
    Write-Host "Migrations process completed with warnings/skipped files." -ForegroundColor Yellow
}