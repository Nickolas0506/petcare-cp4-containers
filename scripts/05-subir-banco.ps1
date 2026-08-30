# =============================================================================
# 05 - Sobe o container do BANCO (MySQL) no ACI
#
# O File Share e montado em /var/lib/mysql: e assim que os dados continuam
# existindo mesmo que o container seja apagado e recriado.
# As senhas vao por --secure-environment-variables, que nao aparecem no
# "az container show" nem no portal.
# =============================================================================
. "$PSScriptRoot\00-variaveis.ps1"

$chave  = az storage account keys list `
              --resource-group $RESOURCE_GROUP `
              --account-name $STORAGE_NAME `
              --query "[0].value" --output tsv

$acrServer = az acr show --name $ACR_NAME --query loginServer --output tsv
$acrUser   = az acr credential show --name $ACR_NAME --query username --output tsv
$acrPass   = az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv

Write-Host "`n>> Subindo o banco ($ACI_DB) ..." -ForegroundColor Green

az container create `
    --resource-group $RESOURCE_GROUP `
    --name $ACI_DB `
    --image "$acrServer/$IMAGE_DB`:$TAG" `
    --registry-login-server $acrServer `
    --registry-username $acrUser `
    --registry-password $acrPass `
    --location $LOCATION `
    --os-type Linux `
    --cpu 1 --memory 2 `
    --ports $DB_PORT `
    --ip-address Public `
    --dns-name-label $DNS_DB `
    --restart-policy OnFailure `
    --environment-variables MYSQL_DATABASE=$DB_NAME MYSQL_USER=$DB_USER `
    --secure-environment-variables MYSQL_PASSWORD=$DB_PASSWORD MYSQL_ROOT_PASSWORD=$DB_ROOT_PASSWORD `
    --azure-file-volume-account-name $STORAGE_NAME `
    --azure-file-volume-account-key $chave `
    --azure-file-volume-share-name $FILE_SHARE `
    --azure-file-volume-mount-path /var/lib/mysql `
    --output table

$fqdnBanco = az container show --resource-group $RESOURCE_GROUP --name $ACI_DB `
                --query ipAddress.fqdn --output tsv

Write-Host "`n>> Banco no ar em: $fqdnBanco`:$DB_PORT" -ForegroundColor Green
Write-Host ">> Aguarde cerca de 1 minuto antes de subir a aplicacao." -ForegroundColor Yellow
