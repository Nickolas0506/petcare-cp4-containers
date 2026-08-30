# =============================================================================
# 03 - Conta de Armazenamento + File Share do banco
#
# O File Share e montado em /var/lib/mysql dentro do container do MySQL.
# E ele que faz os dados sobreviverem quando o container e recriado.
# =============================================================================
. "$PSScriptRoot\00-variaveis.ps1"

Write-Host "`n>> Criando a conta de armazenamento $STORAGE_NAME ..." -ForegroundColor Green

az storage account create `
    --resource-group $RESOURCE_GROUP `
    --name $STORAGE_NAME `
    --location $LOCATION `
    --sku Standard_LRS `
    --kind StorageV2 `
    --output table

Write-Host "`n>> Criando o compartilhamento $FILE_SHARE ..." -ForegroundColor Green

az storage share-rm create `
    --resource-group $RESOURCE_GROUP `
    --storage-account $STORAGE_NAME `
    --name $FILE_SHARE `
    --quota 10 `
    --output table

Write-Host ">> Armazenamento pronto." -ForegroundColor Green
