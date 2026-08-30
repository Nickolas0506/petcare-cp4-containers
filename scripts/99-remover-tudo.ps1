# =============================================================================
# 99 - Apaga TODOS os recursos do CP na Azure
#
# Rode somente DEPOIS de gravar o video e entregar o trabalho.
# Apagar o grupo de recursos apaga tudo que esta dentro dele, inclusive o
# banco de dados e o File Share. Nao tem como desfazer.
# =============================================================================
. "$PSScriptRoot\00-variaveis.ps1"

Write-Host "`nEste comando vai APAGAR o grupo $RESOURCE_GROUP e tudo dentro dele:" -ForegroundColor Red
Write-Host "  - registro de imagens $ACR_NAME"
Write-Host "  - conta de armazenamento $STORAGE_NAME (com os dados do banco)"
Write-Host "  - containers $ACI_APP e $ACI_DB"
Write-Host ""

$resposta = Read-Host "Digite APAGAR para confirmar"
if ($resposta -ne "APAGAR") {
    Write-Host ">> Cancelado. Nada foi removido." -ForegroundColor Yellow
    return
}

az group delete --name $RESOURCE_GROUP --yes --no-wait
Write-Host ">> Remocao iniciada. Pode levar alguns minutos para sumir do portal." -ForegroundColor Green
