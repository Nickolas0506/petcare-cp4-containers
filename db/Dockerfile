# =============================================================================
# PetCare - imagem do BANCO DE DADOS (MySQL 8)
#
# A imagem ja sai do build com o DDL e a carga inicial embutidos. O entrypoint
# oficial do MySQL executa tudo que estiver em /docker-entrypoint-initdb.d na
# primeira inicializacao, quando o volume ainda esta vazio.
# =============================================================================
FROM mysql:8.0

LABEL projeto="PetCare - CP4 Containers em Nuvem" \
      componente="banco de dados"

# Ajustes de charset, fuso e conexoes
COPY conf/my.cnf /etc/mysql/conf.d/petcare.cnf

# 01 cria as tabelas, 02 popula. O 03 e so material de consulta para o video,
# por isso NAO entra no initdb (nao tem prefixo executavel neste diretorio).
COPY init/01-ddl.sql  /docker-entrypoint-initdb.d/01-ddl.sql
COPY init/02-seed.sql /docker-entrypoint-initdb.d/02-seed.sql

EXPOSE 3306
