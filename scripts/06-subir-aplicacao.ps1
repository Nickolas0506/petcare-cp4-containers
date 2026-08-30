# =============================================================================
# 06 - Sobe o container da APLICACAO (Spring Boot) no ACI
#
# A aplicacao acha o banco pelo nome DNS publico do outro container.
# =============================================================================
. "$PSScriptRoot\00-variaveis.ps1"

$acrServer = az acr show --name $ACR_NAME --query loginServer --output tsv
$acrUser   = az acr credential show --name $ACR_NAME --query username --output tsv
$acrPass   = az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv

$fqdnBanco = az container show --resource-group $RESOURCE_GROUP --name $ACI_DB `
                --query ipAddress.fqdn --output tsv

if (-not $fqdnBanco) {
    throw "O container do banco ($ACI_DB) nao foi encontrado. Rode antes o 05-subir-banco.ps1."
}

Write-Host "`n>> Banco encontrado em $fqdnBanco" -ForegroundColor Cyan
Write-Host ">> Subindo a aplicacao ($ACI_APP) ..." -ForegroundColor Green

az container create `
    --resource-group $RESOURCE_GROUP `
    --name $ACI_APP `
    --image "$acrServer/$IMAGE_APP`:$TAG" `
    --registry-login-server $acrServer `
    --registry-username $acrUser `
    --registry-password $acrPass `
    --location $LOCATION `
    --os-type Linux `
    --cpu 1 --memory 2 `
    --ports $APP_PORT `
    --ip-address Public `
    --dns-name-label $DNS_APP `
    --restart-policy OnFailure `
    --environment-variables DB_HOST=$fqdnBanco DB_PORT=$DB_PORT DB_NAME=$DB_NAME DB_USER=$DB_USER `
    --secure-environment-variables DB_PASSWORD=$DB_PASSWORD `
    --output table

$fqdnApp = az container show --resource-group $RESOURCE_GROUP --name $ACI_APP `
              --query ipAddress.fqdn --output tsv

Write-Host "`n>> Aplicacao no ar:" -ForegroundColor Green
Write-Host "   Painel ....... http://$fqdnApp`:$APP_PORT/"
Write-Host "   Tutores ...... http://$fqdnApp`:$APP_PORT/api/v1/tutores"
Write-Host "   Pets ......... http://$fqdnApp`:$APP_PORT/api/v1/pets"
Write-Host "   Saude ........ http://$fqdnApp`:$APP_PORT/actuator/health"
