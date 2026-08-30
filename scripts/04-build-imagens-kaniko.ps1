# =============================================================================
# 04 - Constroi as duas imagens e publica no ACR
#
# Por que kaniko e nao "docker build":
#   - esta maquina nao tem Docker instalado; e
#   - a assinatura Azure for Students bloqueia o ACR Tasks (az acr build),
#     respondendo "TasksOperationsNotAllowed".
#
# Entao o build acontece dentro da propria Azure:
#   1. o codigo e enviado para um File Share temporario;
#   2. um container do kaniko sobe no ACI com esse share montado;
#   3. o kaniko monta a imagem e empurra direto para o ACR.
# =============================================================================
. "$PSScriptRoot\00-variaveis.ps1"

$RAIZ         = Split-Path -Parent $PSScriptRoot
$SHARE_BUILD  = "contexto-build"
$KANIKO       = "gcr.io/kaniko-project/executor:latest"
$loginServer  = az acr show --name $ACR_NAME --query loginServer --output tsv

# ---- Share temporario do contexto ------------------------------------------
Write-Host "`n>> Preparando o compartilhamento $SHARE_BUILD ..." -ForegroundColor Green
az storage share-rm create `
    --resource-group $RESOURCE_GROUP `
    --storage-account $STORAGE_NAME `
    --name $SHARE_BUILD `
    --quota 5 `
    --output none

$chave = az storage account keys list `
            --resource-group $RESOURCE_GROUP `
            --account-name $STORAGE_NAME `
            --query "[0].value" --output tsv

# ---- Monta o contexto local (sem target/, sem .git) -------------------------
$ctx = Join-Path ([IO.Path]::GetTempPath()) "petcare-ctx"
if (Test-Path $ctx) { Remove-Item $ctx -Recurse -Force }
New-Item -ItemType Directory -Force -Path "$ctx\app", "$ctx\db", "$ctx\.docker" | Out-Null

Copy-Item "$RAIZ\app\Dockerfile", "$RAIZ\app\pom.xml", "$RAIZ\app\.dockerignore" "$ctx\app\"
Copy-Item "$RAIZ\app\src"  "$ctx\app\src"  -Recurse
Copy-Item "$RAIZ\db\Dockerfile" "$ctx\db\"
Copy-Item "$RAIZ\db\conf" "$ctx\db\conf" -Recurse
Copy-Item "$RAIZ\db\init" "$ctx\db\init" -Recurse

# ---- Credencial do ACR no formato que o kaniko entende ----------------------
$acrUser = az acr credential show --name $ACR_NAME --query username --output tsv
$acrPass = az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv
$auth    = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("$acrUser`:$acrPass"))
[IO.File]::WriteAllText("$ctx\.docker\config.json",
    '{"auths":{"' + $loginServer + '":{"auth":"' + $auth + '"}}}')

Write-Host ">> Enviando o codigo para a Azure ..." -ForegroundColor Green
az storage file upload-batch `
    --account-name $STORAGE_NAME `
    --account-key $chave `
    --destination $SHARE_BUILD `
    --source $ctx `
    --no-progress `
    --output none

# ---- Um ACI de kaniko por imagem -------------------------------------------
function Construir($pasta, $imagem) {
    $nome = "$RM-build-$pasta"

    az container delete --resource-group $RESOURCE_GROUP --name $nome --yes --output none 2>$null

    Write-Host "`n>> Construindo $imagem`:$TAG (container $nome) ..." -ForegroundColor Green
    az container create `
        --resource-group $RESOURCE_GROUP `
        --name $nome `
        --image $KANIKO `
        --location $LOCATION `
        --os-type Linux `
        --restart-policy Never `
        --cpu 2 --memory 4 `
        --environment-variables DOCKER_CONFIG=/workspace/.docker `
        --azure-file-volume-account-name $STORAGE_NAME `
        --azure-file-volume-account-key $chave `
        --azure-file-volume-share-name $SHARE_BUILD `
        --azure-file-volume-mount-path /workspace `
        --command-line "/kaniko/executor --context=dir:///workspace/$pasta --dockerfile=/workspace/$pasta/Dockerfile --destination=$loginServer/$imagem`:$TAG --ignore-path=/workspace --single-snapshot" `
        --no-wait `
        --output none

    # O estagio Maven da aplicacao leva alguns minutos; espera ate 30 min.
    for ($i = 0; $i -lt 90; $i++) {
        $estado = az container show --resource-group $RESOURCE_GROUP --name $nome `
                      --query "containers[0].instanceView.currentState.state" --output tsv 2>$null
        if ($estado -eq "Terminated") { break }
        Start-Sleep -Seconds 20
    }

    $codigo = az container show --resource-group $RESOURCE_GROUP --name $nome `
                  --query "containers[0].instanceView.currentState.exitCode" --output tsv

    if ($codigo -ne "0") {
        Write-Host "`n>> O build falhou. Log do kaniko:" -ForegroundColor Red
        az container logs --resource-group $RESOURCE_GROUP --name $nome
        throw "Falha ao construir $imagem (codigo de saida $codigo)."
    }

    Write-Host ">> $imagem`:$TAG publicada no ACR." -ForegroundColor Green
    az container delete --resource-group $RESOURCE_GROUP --name $nome --yes --output none
}

Construir "db"  $IMAGE_DB
Construir "app" $IMAGE_APP

Write-Host "`n>> Imagens disponiveis no registro:" -ForegroundColor Green
az acr repository list --name $ACR_NAME --output table
