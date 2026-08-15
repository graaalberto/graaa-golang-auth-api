@echo off
setlocal

REM Configurações do banco
set PGPASSWORD=138B9bu6y5
set DB_USER=postgres
set DB_NAME=auth_db

echo ======================================
echo Executando migrações no PostgreSQL...
echo Pasta: C:\Users\ith\Desktop\golang-auth-api\migrations
echo ======================================

REM Loop por todos os arquivos .sql da pasta
for %%f in ("C:\Users\ith\Desktop\golang-auth-api\migrations\*.sql") do (
    echo Aplicando %%~nxf ...
    psql -U %DB_USER% -d %DB_NAME% -f "%%f"
)

echo ======================================
echo Migrações concluídas!
pause
