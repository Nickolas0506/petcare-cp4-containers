# Roteiro do vídeo — PetCare

> O vídeo é a prova entregue. Grave em **720p ou mais**, com **áudio**, narrando
> o que está fazendo. Duração alvo: **8 a 12 minutos**.
> Não corte as telas de SELECT — é ali que está a evidência do CRUD.

---

## 1. Abertura (~30s)

- Diga seu nome, RM e turma.
- Explique a solução em uma frase: *"API de uma clínica veterinária, com cadastro
  de tutores e pets, containerizada e rodando na Azure com ACR e ACI."*

## 2. Recursos criados na Azure (~1min30) — **comece por aqui**

É exigência do enunciado abrir mostrando o que foi provisionado. No Portal Azure,
dentro do grupo `rm564099-cp4-rg`, mostre item por item:

- Container Registry `rm564099acr`
- Storage Account `rm564099storage` → File Shares → `petcare-dados`
- Container Instance `rm564099-app`
- Container Instance `rm564099-db`

Complemente no terminal:

```powershell
az resource list  --resource-group rm564099-cp4-rg --output table
az container list --resource-group rm564099-cp4-rg --output table
```

## 3. Imagens no ACR (~1min)

```powershell
az acr repository list --name rm564099acr --output table
az acr repository show-tags --name rm564099acr --repository rm564099-app --output table
az acr repository show-tags --name rm564099acr --repository rm564099-db  --output table
```

Aponte que **o RM é o prefixo das duas imagens**, como o CP exige.

## 4. Código e Dockerfiles (~1min30)

- Abra `app/Dockerfile`. Destaque o build em dois estágios (o Maven fica só no
  primeiro, a imagem final leva apenas o JRE e o JAR) e a linha `USER petcare`.
- Prove em execução que não é root:
  ```powershell
  az container exec -g rm564099-cp4-rg -n rm564099-app --exec-command "id"
  ```
  A saída tem que mostrar `uid=1001(petcare)` — e não `uid=0(root)`.
- Abra `db/Dockerfile` e mostre o `01-ddl.sql` sendo copiado para
  `/docker-entrypoint-initdb.d`, ou seja, o DDL vai embutido na imagem.

## 5. Estrutura do banco (~1min)

```powershell
.\scripts\07-evidencias-banco.ps1
```

Já dentro do MySQL:

```sql
USE petcare;
SHOW TABLES;
DESCRIBE tb_tutor;
DESCRIBE tb_pet;
```

**Deixe essa janela aberta** — você volta nela depois de cada operação.

## 6. CRUD com evidência — `tb_tutor` (~2min)

Para **cada** operação: chama a API → volta no MySQL → roda o SELECT → narra o
que mudou.

| # | Operação | Chamada | SELECT de prova |
|---|---|---|---|
| 1 | **CREATE** | `POST /api/v1/tutores` com `tests/tutor/01-post-tutor.json` | `SELECT * FROM tb_tutor;` — mostre a linha nova |
| 2 | **READ** | `GET /api/v1/tutores` e `GET /api/v1/tutores/{id}` | `SELECT * FROM tb_tutor WHERE tutor_id = {id};` |
| 3 | **UPDATE** | `PUT /api/v1/tutores/{id}` com `03-put-tutor.json` | `SELECT * FROM tb_tutor WHERE tutor_id = {id};` — mostre o campo alterado |
| 4 | **DELETE** | `DELETE /api/v1/tutores/{id}` | `SELECT * FROM tb_tutor;` — mostre que sumiu |

> **Atenção ao id:** use sempre o `id` que voltou no JSON do POST. O
> AUTO_INCREMENT do MySQL não reaproveita números — depois de um teste anterior,
> o novo registro pode nascer como 5, 7, 9… e não 3. Se chutar o id, o GET e o
> PUT devolvem 404 no meio da gravação.

> Só é possível apagar um tutor que **não tem pets**. Se der `409`, apague os
> pets dele antes — e aproveite: esse erro é uma boa hora para mostrar que a
> chave estrangeira está funcionando de verdade.

## 7. CRUD com evidência — `tb_pet` (~2min)

Mesma dinâmica, agora com os arquivos de `tests/pet/`:

| # | Operação | Chamada | SELECT de prova |
|---|---|---|---|
| 1 | **CREATE** | `POST /api/v1/pets` | `SELECT * FROM tb_pet;` |
| 2 | **READ** | `GET /api/v1/pets/{id}` | `SELECT * FROM tb_pet WHERE pet_id = {id};` |
| 3 | **UPDATE** | `PUT /api/v1/pets/{id}` | `SELECT * FROM tb_pet WHERE pet_id = {id};` |
| 4 | **DELETE** | `DELETE /api/v1/pets/{id}` | `SELECT * FROM tb_pet;` |

Feche mostrando o relacionamento:

```sql
SELECT t.nome_completo AS tutor, p.nome AS pet, p.especie, p.peso_kg
  FROM tb_tutor t
  LEFT JOIN tb_pet p ON p.tutor_id = t.tutor_id
 ORDER BY t.tutor_id;
```

## 8. Persistência no volume (~1min) — diferencial

Prove que o dado não vive dentro do container:

```powershell
# cadastre um registro pela API, depois reinicie o banco
az container restart --resource-group rm564099-cp4-rg --name rm564099-db
```

Espere subir, consulte de novo e mostre que o registro continua lá — os dados
estão no **Azure File Share**, não no container.

## 9. Encerramento (~30s)

- Mostre o repositório no GitHub: README, DDL, scripts, JSONs.
- Informe o link do repositório e agradeça.

---

## Checklist antes de enviar

- [ ] Vídeo em 720p ou mais, com áudio e narração
- [ ] Começa mostrando os recursos criados na Azure
- [ ] As 4 operações do CRUD demonstradas **individualmente** nas **duas** tabelas
- [ ] Cada operação seguida do SELECT no banco
- [ ] Prova de que a aplicação não roda como root
- [ ] Repositório público (ou com acesso para o professor)
- [ ] `db/init/01-ddl.sql` no repositório
- [ ] JSONs de teste no repositório
- [ ] Scripts da Azure CLI no repositório
- [ ] Nenhuma senha ou token no código
- [ ] PDF da folha de rosto com nome, RM e links
- [ ] Upload feito dentro do prazo
