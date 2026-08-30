# =============================================================================
# 02 - Cria o Azure Container Registry (onde as imagens ficam guardadas)
#
# O admin user e ligado porque o ACI precisa de usuario e senha para puxar a
# imagem privada, e porque o kaniko usa essa credencial para fazer o push.
# =============================================================================
. "$PSScriptRoot\00-variaveis.ps1"

Write-Host "`n>> Criando o registro de imagens $ACR_NAME ..." -ForegroundColor Green

az acr create `
    --resource-group $RESOURCE_GROUP `
    --name $ACR_NAME `
    --sku Basic `
    --location $LOCATION `
    --admin-enabled true `
    --output table

$loginServer = az acr show --name $ACR_NAME --query loginServer --output tsv
Write-Host ">> Endereco do registro: $loginServer" -ForegroundColor Green
