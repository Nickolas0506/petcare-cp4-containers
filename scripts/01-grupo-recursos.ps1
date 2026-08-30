# =============================================================================
# 01 - Cria o Resource Group que vai guardar todos os recursos do CP
# =============================================================================
. "$PSScriptRoot\00-variaveis.ps1"

Write-Host "`n>> Criando o grupo de recursos $RESOURCE_GROUP em $LOCATION ..." -ForegroundColor Green

az group create `
    --name $RESOURCE_GROUP `
    --location $LOCATION `
    --output table

Write-Host ">> Grupo pronto." -ForegroundColor Green
