-- ============================================================================
-- PetCare - consultas de EVIDENCIA do CRUD
-- Use estas consultas no video, sempre logo depois de cada operacao da API.
-- Nao sao executadas automaticamente: sao para rodar a mao no MySQL.
-- ============================================================================
USE petcare;

-- ---- Estrutura (mostrar no inicio do video) --------------------------------
SHOW TABLES;
DESCRIBE tb_tutor;
DESCRIBE tb_pet;

-- ---- Evidencias da tabela tb_tutor -----------------------------------------
-- depois do CREATE / do DELETE (lista inteira)
SELECT * FROM tb_tutor ORDER BY tutor_id;

-- depois do READ / do UPDATE (registro especifico - troque o 1 pelo id certo)
SELECT * FROM tb_tutor WHERE tutor_id = 1;

-- ---- Evidencias da tabela tb_pet -------------------------------------------
SELECT * FROM tb_pet ORDER BY pet_id;

SELECT * FROM tb_pet WHERE pet_id = 1;

-- ---- Relacionamento 1:N (fechamento do video) ------------------------------
SELECT t.tutor_id,
       t.nome_completo          AS tutor,
       p.pet_id,
       p.nome                   AS pet,
       p.especie,
       p.peso_kg
  FROM tb_tutor t
  LEFT JOIN tb_pet p ON p.tutor_id = t.tutor_id
 ORDER BY t.tutor_id, p.pet_id;

-- ---- Contagem por tutor -----------------------------------------------------
SELECT t.nome_completo AS tutor,
       COUNT(p.pet_id) AS qtd_pets
  FROM tb_tutor t
  LEFT JOIN tb_pet p ON p.tutor_id = t.tutor_id
 GROUP BY t.tutor_id, t.nome_completo
 ORDER BY qtd_pets DESC;
