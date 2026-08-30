-- ============================================================================
-- PetCare - carga inicial de demonstracao
-- Dois tutores e dois pets, so para a tela nao comecar vazia no video.
-- ============================================================================
USE petcare;

INSERT INTO tb_tutor (nome_completo, documento, email, celular, cidade, data_cadastro) VALUES
    ('Renata Aguiar Prado', '30945178200', 'renata.prado@petcare.com.br', '11987650011', 'Sao Paulo', CURDATE()),
    ('Tiago Nunes Barreto', '41822630977', 'tiago.barreto@petcare.com.br', '11996320088', 'Osasco', CURDATE());

INSERT INTO tb_pet (nome, especie, raca, peso_kg, data_nascimento, castrado, tutor_id) VALUES
    ('Amora', 'CACHORRO', 'Golden Retriever', 28.40, '2021-03-14', TRUE,  1),
    ('Pistache', 'GATO',   'Siames',            4.15, '2022-09-02', FALSE, 2);
