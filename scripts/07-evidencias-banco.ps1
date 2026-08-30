# =============================================================================
# 07 - Abre um cliente MySQL dentro do container do banco
#
# Use no video para mostrar a estrutura das tabelas e rodar os SELECT de
# evidencia depois de cada operacao do CRUD.
# =============================================================================
. "$PSScriptRoot\00-variaveis.ps1"

Write-Host "`n>> Abrindo o MySQL dentro do container $ACI_DB ..." -ForegroundColor Green
Write-Host ">> Ja dentro do banco, comece com:" -ForegroundColor Yellow
Write-Host "     USE petcare;"
Write-Host "     SHOW TABLES;"
Write-Host "     DESCRIBE tb_tutor;"
Write-Host "     DESCRIBE tb_pet;"
Write-Host ""
Write-Host ">> As consultas de evidencia estao em db/init/03-consultas-evidencia.sql" -ForegroundColor Yellow
Write-Host ">> Para sair, digite: exit" -ForegroundColor Yellow
Write-Host ""

az container exec `
    --resource-group $RESOURCE_GROUP `
    --name $ACI_DB `
    --exec-command "mysql -u root -p$DB_ROOT_PASSWORD"
