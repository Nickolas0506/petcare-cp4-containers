# =============================================================================
# 00 - Variaveis usadas por todos os scripts do projeto PetCare
#
# Carregue antes de qualquer outro script:
#     . .\scripts\00-variaveis.ps1
#
# A senha do banco NUNCA fica escrita aqui. Ela vem da variavel de ambiente
# DB_PASSWORD (veja o arquivo env.example na raiz).
# =============================================================================

# ---- Identificacao ----------------------------------------------------------
if ($env:RM) { $RM = $env:RM } else { $RM = "rm564099" }

# A assinatura Azure for Students nao libera todas as regioes (brazilsouth,
# por exemplo, costuma recusar). mexicocentral funciona e fica perto.
if ($env:LOCATION) { $LOCATION = $env:LOCATION } else { $LOCATION = "mexicocentral" }

# ---- Recursos na Azure ------------------------------------------------------
$RESOURCE_GROUP = "$RM-cp4-rg"
$ACR_NAME       = "${RM}acr"          # somente letras e numeros, minusculo
$STORAGE_NAME   = "${RM}storage"      # 3 a 24 caracteres, minusculo
$FILE_SHARE     = "petcare-dados"     # volume onde o MySQL guarda os dados

# ---- Imagens (prefixadas com o RM, conforme a regra do CP) ------------------
$IMAGE_APP = "$RM-app"
$IMAGE_DB  = "$RM-db"
$TAG       = "latest"

# ---- Container Instances ----------------------------------------------------
$ACI_APP = "$RM-app"
$ACI_DB  = "$RM-db"
$DNS_APP = "$RM-app"                  # vira $RM-app.<regiao>.azurecontainer.io
$DNS_DB  = "$RM-db"

# ---- Banco ------------------------------------------------------------------
$DB_NAME = "petcare"
$DB_USER = "petcare_user"
$DB_PORT = 3306
$APP_PORT = 8080

# ---- Senha (fora do controle de versao) -------------------------------------
if (-not $env:DB_PASSWORD) {
    Write-Host ""
    Write-Host "A variavel DB_PASSWORD nao esta definida." -ForegroundColor Red
    Write-Host "Defina antes de rodar os scripts, por exemplo:" -ForegroundColor Yellow
    Write-Host '    $env:DB_PASSWORD = "SuaSenhaForte123!"' -ForegroundColor Yellow
    Write-Host ""
    throw "DB_PASSWORD nao definida"
}
$DB_PASSWORD = $env:DB_PASSWORD

if ($env:DB_ROOT_PASSWORD) { $DB_ROOT_PASSWORD = $env:DB_ROOT_PASSWORD }
else                       { $DB_ROOT_PASSWORD = $env:DB_PASSWORD }

Write-Host "Variaveis do PetCare carregadas:" -ForegroundColor Cyan
Write-Host "  RM .............. $RM"
Write-Host "  Grupo ........... $RESOURCE_GROUP"
Write-Host "  Regiao .......... $LOCATION"
Write-Host "  ACR ............. $ACR_NAME"
Write-Host "  Storage ......... $STORAGE_NAME"
Write-Host "  Imagens ......... $IMAGE_APP`:$TAG e $IMAGE_DB`:$TAG"
Write-Host "  Containers ...... $ACI_APP e $ACI_DB"
