# PetCare — Clínica Veterinária em Containers (ACR + ACI)

**FIAP — DevOps Tools & Cloud Computing**
1º Checkpoint do 2º Semestre — Imagem e Containers em Nuvem

---

## O que é

API REST de uma clínica veterinária: cadastro de **tutores** e dos **pets** que
eles levam para atendimento. A aplicação e o banco rodam cada um em seu próprio
container na Azure, no formato PaaS — as imagens ficam no **Azure Container
Registry (ACR)** e são executadas em **Azure Container Instances (ACI)**.

| Camada | Tecnologia | Imagem | Container |
|---|---|---|---|
| Aplicação | Java 21 · Spring Boot 3.3 | `rm564099-app:latest` | `rm564099-app` |
| Banco | MySQL 8 | `rm564099-db:latest` | `rm564099-db` |

Os dados do MySQL ficam em um **Azure File Share**, montado em `/var/lib/mysql`.
É isso que faz o banco sobreviver à recriação do container.

### Como as peças se conectam

```
   máquina local                       Azure — grupo rm564099-cp4-rg
 +----------------+
 | código-fonte   |                 +--------------------------------------+
 | Dockerfiles    |   contexto      |   ACR  rm564099acr                   |
 | scripts CLI    | --------------> |   +-- rm564099-app:latest            |
 +--------+-------+   via kaniko    |   +-- rm564099-db:latest             |
          |                         +------------------+-------------------+
          |                                            | pull
          |                         +------------------v-------------------+
          |                         |  ACI rm564099-app --> ACI rm564099-db|
          |     Azure CLI           |  Spring Boot 8080      MySQL 3306    |
          +-----------------------> |  usuário não-root           |        |
                                    +-----------------------------+--------+
                                                                  | volume
                                                     +------------v-------------+
                                                     | Storage rm564099storage  |
                                                     | share petcare-dados      |
                                                     +--------------------------+
```

---

## Modelo de dados

Duas tabelas com relacionamento **1:N** — um tutor tem vários pets.

**`tb_tutor`**

| coluna | tipo | observação |
|---|---|---|
| `tutor_id` | BIGINT | chave primária, auto incremento |
| `nome_completo` | VARCHAR(120) | obrigatório |
| `documento` | VARCHAR(11) | CPF, **único** |
| `email` | VARCHAR(150) | obrigatório |
| `celular` | VARCHAR(15) | |
| `cidade` | VARCHAR(80) | |
| `data_cadastro` | DATE | preenchido pela aplicação |

**`tb_pet`**

| coluna | tipo | observação |
|---|---|---|
| `pet_id` | BIGINT | chave primária, auto incremento |
| `nome` | VARCHAR(60) | obrigatório |
| `especie` | VARCHAR(20) | CACHORRO, GATO, AVE, ROEDOR ou REPTIL |
| `raca` | VARCHAR(60) | |
| `peso_kg` | DECIMAL(5,2) | |
| `data_nascimento` | DATE | |
| `castrado` | BOOLEAN | padrão `false` |
| `tutor_id` | BIGINT | **chave estrangeira** para `tb_tutor` |

O DDL completo está em `db/init/01-ddl.sql` e fica embutido na imagem do banco.

---

## Endpoints

| Método | Rota | O que faz |
|---|---|---|
| GET | `/api/v1/tutores` | lista todos os tutores |
| GET | `/api/v1/tutores/{id}` | busca um tutor |
| GET | `/api/v1/tutores/{id}/pets` | pets daquele tutor (prova do 1:N) |
| POST | `/api/v1/tutores` | cadastra tutor |
| PUT | `/api/v1/tutores/{id}` | altera tutor |
| DELETE | `/api/v1/tutores/{id}` | remove tutor |
| GET | `/api/v1/pets` | lista todos os pets |
| GET | `/api/v1/pets/{id}` | busca um pet |
| POST | `/api/v1/pets` | cadastra pet |
| PUT | `/api/v1/pets/{id}` | altera pet |
| DELETE | `/api/v1/pets/{id}` | remove pet |
| GET | `/` | painel visual |
| GET | `/info` | dados da API |
| GET | `/actuator/health` | saúde da aplicação e do banco |

### Regras de negócio implementadas

- **CPF único**: cadastrar ou alterar um tutor com documento já usado devolve
  `409 Conflict`.
- **Tutor com pet não é apagado**: o `DELETE` de um tutor que ainda tem pets
  devolve `409` explicando quantos pets existem. É preciso remover os pets antes.
- **Pet sempre tem dono**: criar um pet apontando para um `tutorId` inexistente
  devolve `404`.
- **Validação de entrada**: campos obrigatórios, formato de e-mail, CPF com 11
  dígitos e data de nascimento que não pode estar no futuro. Erros voltam no
  formato `ProblemDetail`, com a lista de campos inválidos.

---

## Estrutura do repositório

```
.
├── app/                          Aplicação Java
│   ├── Dockerfile                imagem multi-stage, usuário não-root
│   ├── pom.xml
│   └── src/main/
│       ├── java/br/com/fiap/petcare/
│       │   ├── controller/       camada HTTP (fina)
│       │   ├── service/          regras de negócio
│       │   ├── repository/       acesso ao banco (Spring Data JPA)
│       │   ├── entity/           Tutor, Pet, Especie
│       │   ├── dto/              records de entrada e saída
│       │   └── exception/        erros no formato ProblemDetail
│       └── resources/
│           ├── application.properties
│           └── static/index.html painel visual
├── db/                           Banco de dados
│   ├── Dockerfile                MySQL 8 com o DDL embutido
│   ├── conf/my.cnf
│   └── init/
│       ├── 01-ddl.sql            DDL DAS TABELAS (entrega obrigatória)
│       ├── 02-seed.sql           carga inicial de demonstração
│       └── 03-consultas-evidencia.sql   SELECTs para usar no vídeo
├── scripts/                      todos os recursos criados via Azure CLI
│   ├── 00-variaveis.ps1
│   ├── 01-grupo-recursos.ps1
│   ├── 02-registro-acr.ps1
│   ├── 03-armazenamento.ps1
│   ├── 04-build-imagens-kaniko.ps1
│   ├── 05-subir-banco.ps1
│   ├── 06-subir-aplicacao.ps1
│   ├── 07-evidencias-banco.ps1
│   ├── 08-testar-api.ps1
│   └── 99-remover-tudo.ps1
├── deploy/                       YAMLs dos dois ACIs
├── tests/                        JSONs de teste do CRUD das duas tabelas
├── docs/                         folha de rosto e roteiro do vídeo
├── docker-compose.yml            execução local
└── env.example                   modelo das variáveis (senha nunca no Git)
```

---

## Como executar

### Pré-requisitos

- Azure CLI (`az`) instalado e autenticado — `az login`
- Assinatura Azure for Students ativa
- PowerShell (os scripts são `.ps1`)

Docker **não** é necessário: o build acontece dentro da própria Azure.

### Passo a passo

```powershell
# 1. senha do banco (não fica em arquivo nenhum)
$env:DB_PASSWORD = "SuaSenhaForte123!"

# 2. carrega as variáveis
. .\scripts\00-variaveis.ps1

# 3. cria a infraestrutura
.\scripts\01-grupo-recursos.ps1
.\scripts\02-registro-acr.ps1
.\scripts\03-armazenamento.ps1

# 4. constrói as duas imagens e publica no ACR (leva alguns minutos)
.\scripts\04-build-imagens-kaniko.ps1

# 5. sobe os containers — banco primeiro
.\scripts\05-subir-banco.ps1
#    espere cerca de 1 minuto
.\scripts\06-subir-aplicacao.ps1

# 6. confere que o CRUD funciona antes de gravar
.\scripts\08-testar-api.ps1
```

Conferindo os recursos criados (útil para mostrar no vídeo):

```powershell
az resource list  --resource-group rm564099-cp4-rg --output table
az container list --resource-group rm564099-cp4-rg --output table
az acr repository list --name rm564099acr --output table
```

### Limpeza — só depois de gravar o vídeo

```powershell
.\scripts\99-remover-tudo.ps1
```

---

## Decisões técnicas

**Por que kaniko em vez de `docker build`.** A máquina usada não tem Docker
instalado, e a assinatura Azure for Students bloqueia o ACR Tasks
(`az acr build` responde `TasksOperationsNotAllowed`). A saída foi enviar o
código para um File Share e rodar o kaniko em um container efêmero no ACI, que
constrói a imagem e faz o push direto para o ACR. O script `04` faz isso e
apaga o container de build no final.

**Por que `mexicocentral`.** A Azure for Students recusa várias regiões para
ACI, incluindo `brazilsouth`. `mexicocentral` aceita e é a mais próxima.

**Segurança.** O container da aplicação roda com o usuário `petcare` (uid 1001),
sem privilégio administrativo — dá para conferir com
`az container exec -g rm564099-cp4-rg -n rm564099-app --exec-command "id"`.
As senhas entram por `--secure-environment-variables`, que não aparecem no
`az container show` nem no portal, e nenhuma credencial está versionada.

**Por que o Hibernate não cria as tabelas.** `spring.jpa.hibernate.ddl-auto` está
em `none` de propósito: o schema vem do DDL embutido na imagem do banco, que é
o artefato exigido na entrega. Assim o `01-ddl.sql` é a fonte da verdade, e não
um efeito colateral do mapeamento das entidades.
