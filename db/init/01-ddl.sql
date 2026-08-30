-- ============================================================================
-- PetCare - DDL do banco de dados (MySQL 8)
-- CP4 - Imagem e Containers em Nuvem (ACR / ACI)
-- FIAP - DevOps Tools & Cloud Computing
--
-- Este arquivo fica embutido na imagem do banco, em /docker-entrypoint-initdb.d.
-- O MySQL executa o diretorio inteiro sozinho na PRIMEIRA subida do container,
-- enquanto o volume de dados ainda estiver vazio.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS petcare
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE petcare;

-- ----------------------------------------------------------------------------
-- tb_tutor : pessoa responsavel pelo animal
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_tutor (
    tutor_id       BIGINT       NOT NULL AUTO_INCREMENT,
    nome_completo  VARCHAR(120) NOT NULL,
    documento      VARCHAR(11)  NOT NULL,
    email          VARCHAR(150) NOT NULL,
    celular        VARCHAR(15)  NULL,
    cidade         VARCHAR(80)  NULL,
    data_cadastro  DATE         NOT NULL,
    PRIMARY KEY (tutor_id),
    UNIQUE KEY uq_tutor_documento (documento)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- tb_pet : animal atendido pela clinica
-- Relacionamento 1:N -> um tutor tem varios pets (FK tutor_id)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_pet (
    pet_id           BIGINT       NOT NULL AUTO_INCREMENT,
    nome             VARCHAR(60)  NOT NULL,
    especie          VARCHAR(20)  NOT NULL,
    raca             VARCHAR(60)  NULL,
    peso_kg          DECIMAL(5,2) NULL,
    data_nascimento  DATE         NULL,
    castrado         BOOLEAN      NOT NULL DEFAULT FALSE,
    tutor_id         BIGINT       NOT NULL,
    PRIMARY KEY (pet_id),
    KEY ix_pet_tutor (tutor_id),
    CONSTRAINT fk_pet_tutor FOREIGN KEY (tutor_id)
        REFERENCES tb_tutor (tutor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT ck_pet_especie
        CHECK (especie IN ('CACHORRO','GATO','AVE','ROEDOR','REPTIL'))
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
