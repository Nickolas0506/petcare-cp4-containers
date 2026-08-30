# =============================================================================
# 08 - Roda o CRUD completo nas duas tabelas contra a API publicada
#
# Serve para conferir que esta tudo funcionando ANTES de gravar o video.
# Ao final o script apaga o que criou, deixando o banco como estava.
# =============================================================================
. "$PSScriptRoot\00-variaveis.ps1"

$fqdn = az container show --resource-group $RESOURCE_GROUP --name $ACI_APP `
            --query ipAddress.fqdn --output tsv
if (-not $fqdn) { throw "A aplicacao ($ACI_APP) nao esta no ar." }

$base = "http://$fqdn`:$APP_PORT"
Write-Host "`n>> Testando $base" -ForegroundColor Cyan

function Passo($titulo) { Write-Host "`n--- $titulo ---" -ForegroundColor Green }

# ---------------------------------------------------------------- TUTOR -----
Passo "CREATE tutor"
$novoTutor = @{
    nomeCompleto = "Tutor de Teste Automatico"
    documento    = "99988877766"
    email        = "teste@petcare.com.br"
    celular      = "11900000000"
    cidade       = "Sao Paulo"
} | ConvertTo-Json

$tutor = Invoke-RestMethod -Method Post -Uri "$base/api/v1/tutores" `
             -ContentType "application/json; charset=utf-8" -Body $novoTutor
$tutor | Format-List
$idTutor = $tutor.id

Passo "READ tutor $idTutor"
Invoke-RestMethod -Uri "$base/api/v1/tutores/$idTutor" | Format-List

Passo "UPDATE tutor $idTutor"
$alterado = @{
    nomeCompleto = "Tutor de Teste Automatico"
    documento    = "99988877766"
    email        = "teste.alterado@petcare.com.br"
    celular      = "11911111111"
    cidade       = "Guarulhos"
} | ConvertTo-Json
Invoke-RestMethod -Method Put -Uri "$base/api/v1/tutores/$idTutor" `
    -ContentType "application/json; charset=utf-8" -Body $alterado | Format-List

# ------------------------------------------------------------------ PET -----
Passo "CREATE pet"
$novoPet = @{
    nome            = "Pet de Teste"
    especie         = "CACHORRO"
    raca            = "SRD"
    pesoKg          = 9.80
    dataNascimento  = "2022-01-10"
    castrado        = $false
    tutorId         = $idTutor
} | ConvertTo-Json

$pet = Invoke-RestMethod -Method Post -Uri "$base/api/v1/pets" `
           -ContentType "application/json; charset=utf-8" -Body $novoPet
$pet | Format-List
$idPet = $pet.id

Passo "READ pet $idPet"
Invoke-RestMethod -Uri "$base/api/v1/pets/$idPet" | Format-List

Passo "UPDATE pet $idPet"
$petAlterado = @{
    nome            = "Pet de Teste"
    especie         = "CACHORRO"
    raca            = "SRD"
    pesoKg          = 11.20
    dataNascimento  = "2022-01-10"
    castrado        = $true
    tutorId         = $idTutor
} | ConvertTo-Json
Invoke-RestMethod -Method Put -Uri "$base/api/v1/pets/$idPet" `
    -ContentType "application/json; charset=utf-8" -Body $petAlterado | Format-List

# --------------------------------------------------------------- LIMPEZA ----
Passo "DELETE pet $idPet"
Invoke-RestMethod -Method Delete -Uri "$base/api/v1/pets/$idPet"
Write-Host "pet removido"

Passo "DELETE tutor $idTutor"
Invoke-RestMethod -Method Delete -Uri "$base/api/v1/tutores/$idTutor"
Write-Host "tutor removido"

Write-Host "`n>> CRUD completo funcionando nas duas tabelas." -ForegroundColor Green
Write-Host ">> O banco voltou ao estado anterior ao teste." -ForegroundColor Green
