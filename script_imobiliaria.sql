-- =====================================================================
-- Projeto de Banco de Dados - C07 - 2ª Entrega
-- Tema: Sistema de Gestão Comercial Imobiliária
-- Turma: L2
--
-- Integrantes: Gabriel Westin Generoso Pontes - 635/L2
--              Leonardo Oliveira Gomes - 662/L2
-- =====================================================================
--
-- OBSERVAÇÕES
-- 1) Executar o script inteiro com um usuário administrador (ex.: root),
--    pois ele cria usuários e role.
-- 2) O script apaga e recria o banco "projeto_imobiliaria", então pode ser
--    executado mais de uma vez.
-- 3) A explicação de cada parte está no README.md do repositório.

-- =====================================================================
-- 1. CRIAÇÃO DO BANCO E DAS TABELAS
-- =====================================================================

DROP DATABASE IF EXISTS projeto_imobiliaria;
CREATE DATABASE projeto_imobiliaria;
USE projeto_imobiliaria;

SET SQL_SAFE_UPDATES = 0;

-- idgerente aponta para outro corretor (autorrelacionamento 1:N)
CREATE TABLE corretor (
	idCorretor INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	nome VARCHAR(100) NOT NULL,
	creci VARCHAR(20) NOT NULL UNIQUE,
	idgerente INT NULL,
	FOREIGN KEY (idgerente) REFERENCES corretor(idCorretor) ON DELETE SET NULL
);

CREATE TABLE cliente (
	idCliente INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	nome VARCHAR(100) NOT NULL,
	cpf CHAR(11) NOT NULL,
	telefone VARCHAR(15) NULL,
	limite_credito DECIMAL(10,2) DEFAULT 0.00
);

-- 1:N -> um corretor tem vários imóveis
CREATE TABLE imovel (
	idImovel INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	endereco VARCHAR(200) NOT NULL,
	valor DECIMAL(12,2) NOT NULL,
	tipo ENUM('Casa', 'Apartamento', 'Terreno'),
	idCorretor INT NOT NULL,
	FOREIGN KEY (idCorretor) REFERENCES corretor(idCorretor) ON UPDATE CASCADE
);

-- 1:1 -> o UNIQUE em idImovel garante um contrato por imóvel
CREATE TABLE contrato (
	idContrato INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	valor_fechado DECIMAL(12,2) NOT NULL,
	data_assinatura DATE NOT NULL,
	idImovel INT NOT NULL UNIQUE,
	idCliente INT NOT NULL,
	FOREIGN KEY (idImovel) REFERENCES imovel(idImovel),
	FOREIGN KEY (idCliente) REFERENCES cliente(idCliente)
);

-- N:M -> tabela associativa entre cliente e imovel
CREATE TABLE agenda_visita (
	idVisita INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	idCliente INT NOT NULL,
	idImovel INT NOT NULL,
	data_visita DATETIME NOT NULL,
	status_visita ENUM('Agendada', 'Realizada', 'Cancelada') DEFAULT 'Agendada',
	FOREIGN KEY (idCliente) REFERENCES cliente(idCliente) ON DELETE CASCADE,
	FOREIGN KEY (idImovel) REFERENCES imovel(idImovel) ON DELETE CASCADE
);

-- =====================================================================
-- 2. INSERÇÃO DOS DADOS
-- =====================================================================

-- Corretores 1 e 2 são gerentes
INSERT INTO corretor (nome, creci, idgerente) VALUES
('Ricardo Almeida', 'MG-10001', NULL),
('Fernanda Costa', 'MG-10002', NULL),
('Bruno Ribeiro', 'MG-10003', 1),
('Camila Souza', 'MG-10004', 1),
('Diego Martins', 'MG-10005', 2),
('Juliana Ferreira', 'MG-10006', 2);

INSERT INTO cliente (nome, cpf, telefone, limite_credito) VALUES
('Ana Paula Mendes', '12345678901', '(35)99811-2233', 800000.00),
('Carlos Eduardo Lima', '23456789012', '(35)99722-3344', 450000.00),
('Mariana Rocha', '34567890123', '(35)99633-4455', 1200000.00),
('João Pedro Santos', '45678901234', '(35)99544-5566', 300000.00),
('Beatriz Carvalho', '56789012345', '(35)99455-6677', 650000.00),
('Rafael Nogueira', '67890123456', '(35)99366-7788', 200000.00),
('Larissa Pereira', '78901234567', NULL, 0.00);

INSERT INTO imovel (endereco, valor, tipo, idCorretor) VALUES
('Rua Coronel Rennó, 120 - Centro, Itajubá/MG', 450000.00, 'Casa', 3),
('Av. BPS, 1500 - Pinheirinho, Itajubá/MG', 320000.00, 'Apartamento', 3),
('Rua Dr. Pereira Cabral, 45 - Centro, Itajubá/MG', 280000.00, 'Apartamento', 4),
('Rua Antônio Simão Mauad, 300 - Morro Chic, Itajubá/MG', 780000.00, 'Casa', 4),
('Estrada do Anhumas, km 3 - Zona Rural, Itajubá/MG', 150000.00, 'Terreno', 5),
('Rua Cel. Erasmo Cabral, 210 - Centro, Santa Rita do Sapucaí/MG', 390000.00, 'Casa', 5),
('Av. Delfim Moreira, 870 - Centro, Santa Rita do Sapucaí/MG', 250000.00, 'Apartamento', 6),
('Rua João de Camargo, 55 - Santa Rita do Sapucaí/MG', 120000.00, 'Terreno', 6),
('Rua Xavier Lisboa, 90 - Varginha, Itajubá/MG', 600000.00, 'Casa', 1);

INSERT INTO contrato (valor_fechado, data_assinatura, idImovel, idCliente) VALUES
(440000.00, '2026-03-10', 1, 1),
(275000.00, '2026-04-22', 3, 2),
(760000.00, '2026-05-15', 4, 3),
(145000.00, '2026-06-02', 5, 4),
(245000.00, '2026-08-19', 7, 5);

INSERT INTO agenda_visita (idCliente, idImovel, data_visita, status_visita) VALUES
(1, 1, '2026-02-20 10:00:00', 'Realizada'),
(1, 9, '2026-02-25 14:00:00', 'Realizada'),
(2, 3, '2026-04-05 09:30:00', 'Realizada'),
(2, 2, '2026-04-10 16:00:00', 'Realizada'),
(3, 4, '2026-05-02 11:00:00', 'Realizada'),
(3, 9, '2026-05-03 15:00:00', 'Cancelada'),
(4, 5, '2026-05-28 08:30:00', 'Realizada'),
(5, 7, '2026-08-10 10:00:00', 'Realizada'),
(6, 2, '2026-12-05 10:00:00', 'Agendada'),
(6, 8, '2026-12-06 14:00:00', 'Agendada'),
(5, 6, '2026-12-10 09:00:00', 'Agendada'),
(7, 9, '2026-12-12 17:00:00', 'Agendada'),
(2, 6, '2026-12-15 11:00:00', 'Agendada');

-- =====================================================================
-- 3. COMANDOS DML
-- =====================================================================

-- 3.1) Reajuste de 5% apenas nos imóveis que ainda não têm contrato
UPDATE imovel SET valor = valor * 1.05
WHERE idImovel NOT IN (SELECT idImovel FROM contrato);

-- 3.2) Aumento do limite de crédito do cliente 6 (financiamento aprovado)
UPDATE cliente SET limite_credito = 500000.00 WHERE idCliente = 6;

-- 3.3) Atualização do telefone do cliente 4
UPDATE cliente SET telefone = '(35)98877-1122' WHERE idCliente = 4;

-- 3.4) Corretora 4 transferida para a equipe da gerente 2
UPDATE corretor SET idgerente = 2 WHERE idCorretor = 4;

-- 3.5) Remove as visitas canceladas que já passaram
DELETE FROM agenda_visita WHERE status_visita = 'Cancelada' AND data_visita < NOW();

-- 3.6) Exclui o cliente 7 a pedido dele (LGPD).
-- As visitas dele são apagadas junto por causa do ON DELETE CASCADE.
DELETE FROM cliente WHERE idCliente = 7;

-- 3.7) Conferindo as alterações
SELECT * FROM imovel;
SELECT * FROM cliente;
SELECT * FROM agenda_visita;

-- =====================================================================
-- 4. USUÁRIOS E ROLE
-- =====================================================================

-- Remove usuários e role criados em execuções anteriores
DROP USER IF EXISTS 'usr_leonardo'@'localhost';
DROP USER IF EXISTS 'usr_gabriel'@'localhost';
DROP ROLE IF EXISTS 'role_corretor';

-- A role concentra as permissões do corretor (sem DELETE)
CREATE ROLE 'role_corretor';
GRANT SELECT, INSERT, UPDATE, EXECUTE ON projeto_imobiliaria.* TO 'role_corretor';

CREATE USER 'usr_leonardo'@'localhost' IDENTIFIED BY 'Leonardo@2026';
CREATE USER 'usr_gabriel'@'localhost' IDENTIFIED BY 'Gabriel@2026';

-- Os dois usuários ficam relacionados pela mesma role
GRANT 'role_corretor' TO 'usr_leonardo'@'localhost', 'usr_gabriel'@'localhost';
SET DEFAULT ROLE 'role_corretor' TO 'usr_leonardo'@'localhost', 'usr_gabriel'@'localhost';

SHOW GRANTS FOR 'role_corretor';
SHOW GRANTS FOR 'usr_leonardo'@'localhost' USING 'role_corretor';
SHOW GRANTS FOR 'usr_gabriel'@'localhost' USING 'role_corretor';

-- =====================================================================
-- 5. FUNCTION, PROCEDURE, TRIGGER E VIEW
-- =====================================================================

DELIMITER $$

-- 5.1) Function: calcula a comissão do corretor (6% do valor fechado)
CREATE FUNCTION fn_calcula_comissao(p_valor DECIMAL(12,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
	RETURN ROUND(p_valor * 0.06, 2);
END $$

-- 5.2) Function (extra): quantidade de visitas não canceladas de um imóvel
CREATE FUNCTION fn_total_visitas(p_idImovel INT)
RETURNS INT
READS SQL DATA
BEGIN
	DECLARE total INT;
	SELECT COUNT(*) INTO total FROM agenda_visita
	WHERE idImovel = p_idImovel AND status_visita <> 'Cancelada';
	RETURN total;
END $$

-- 5.3) Procedure: agenda uma visita depois de validar as regras
CREATE PROCEDURE sp_agendar_visita(IN p_idCliente INT, IN p_idImovel INT, IN p_data DATETIME)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM cliente WHERE idCliente = p_idCliente) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente não encontrado.';
	END IF;

	IF NOT EXISTS (SELECT 1 FROM imovel WHERE idImovel = p_idImovel) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Imóvel não encontrado.';
	END IF;

	IF EXISTS (SELECT 1 FROM contrato WHERE idImovel = p_idImovel) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Imóvel já possui contrato.';
	END IF;

	IF p_data <= NOW() THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A data da visita precisa ser futura.';
	END IF;

	IF EXISTS (SELECT 1 FROM agenda_visita
	           WHERE idImovel = p_idImovel AND data_visita = p_data
	           AND status_visita = 'Agendada') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já existe visita neste imóvel e horário.';
	END IF;

	INSERT INTO agenda_visita (idCliente, idImovel, data_visita, status_visita)
	VALUES (p_idCliente, p_idImovel, p_data, 'Agendada');

	SELECT 'Visita agendada!' AS Resultado;
END $$

-- 5.4) Trigger: ANTES de inserir um contrato, verifica se o valor é válido
-- e se não passa do limite de crédito do cliente
CREATE TRIGGER trg_valida_contrato
BEFORE INSERT ON contrato
FOR EACH ROW
BEGIN
	DECLARE limite DECIMAL(10,2);

	IF NEW.valor_fechado <= 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O valor fechado deve ser maior que zero.';
	END IF;

	SELECT limite_credito INTO limite FROM cliente WHERE idCliente = NEW.idCliente;

	IF NEW.valor_fechado > IFNULL(limite, 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor excede o limite de crédito do cliente.';
	END IF;
END $$

-- 5.5) Trigger (extra): DEPOIS de inserir um contrato, cancela as visitas
-- que ainda estavam agendadas para aquele imóvel
CREATE TRIGGER trg_cancela_visitas_apos_contrato
AFTER INSERT ON contrato
FOR EACH ROW
BEGIN
	UPDATE agenda_visita SET status_visita = 'Cancelada'
	WHERE idImovel = NEW.idImovel AND status_visita = 'Agendada';
END $$

DELIMITER ;

-- 5.6) View: relatório dos contratos com cliente, imóvel, corretor e comissão
CREATE VIEW vw_contratos_detalhados AS
SELECT ct.idContrato, ct.data_assinatura, cl.nome AS cliente, im.endereco AS imovel,
       im.tipo, im.valor AS valor_anunciado, ct.valor_fechado, co.nome AS corretor,
       fn_calcula_comissao(ct.valor_fechado) AS comissao_corretor
FROM contrato ct
JOIN imovel im ON im.idImovel = ct.idImovel
JOIN cliente cl ON cl.idCliente = ct.idCliente
JOIN corretor co ON co.idCorretor = im.idCorretor;

-- 5.7) View (extra): imóveis que ainda não têm contrato
CREATE VIEW vw_imoveis_disponiveis AS
SELECT im.idImovel, im.endereco, im.tipo, im.valor, co.nome AS corretor_responsavel,
       fn_total_visitas(im.idImovel) AS total_visitas
FROM imovel im
JOIN corretor co ON co.idCorretor = im.idCorretor
LEFT JOIN contrato ct ON ct.idImovel = im.idImovel
WHERE ct.idContrato IS NULL;

-- 5.8) Testes

-- Functions
SELECT fn_calcula_comissao(500000.00) AS comissao;
SELECT idImovel, fn_total_visitas(idImovel) AS visitas FROM imovel;

-- Procedure: cliente 6 visita o imóvel 9 daqui a 7 dias, às 10h
CALL sp_agendar_visita(6, 9, DATE_ADD(CURDATE(), INTERVAL 7 DAY) + INTERVAL 10 HOUR);

-- Teste de erro (descomente para testar): o imóvel 1 já tem contrato
-- CALL sp_agendar_visita(6, 1, DATE_ADD(NOW(), INTERVAL 7 DAY));

-- Views
SELECT * FROM vw_contratos_detalhados;
SELECT * FROM vw_imoveis_disponiveis;

-- Triggers: novo contrato do imóvel 6 para o cliente 5.
-- As visitas agendadas do imóvel 6 devem passar para 'Cancelada'.
SELECT * FROM agenda_visita WHERE idImovel = 6;

INSERT INTO contrato (valor_fechado, data_assinatura, idImovel, idCliente) VALUES
(395000.00, CURDATE(), 6, 5);

SELECT * FROM agenda_visita WHERE idImovel = 6;

-- Teste de erro (descomente para testar): o cliente 6 tem limite de 500 mil
-- INSERT INTO contrato (valor_fechado, data_assinatura, idImovel, idCliente) VALUES
-- (900000.00, CURDATE(), 8, 6);

-- =====================================================================
-- 6. CONSULTAS COM JOIN
-- =====================================================================

-- 6.1) 1:1 - Contrato com o seu imóvel e o desconto negociado (%)
SELECT ct.idContrato, im.endereco, im.valor AS valor_anunciado, ct.valor_fechado,
       ROUND((1 - ct.valor_fechado / im.valor) * 100, 2) AS desconto_pct
FROM contrato ct
INNER JOIN imovel im ON im.idImovel = ct.idImovel
ORDER BY desconto_pct DESC;

-- 6.2) 1:N - Carteira de cada corretor (corretores sem imóvel aparecem com 0)
SELECT co.nome AS corretor, COUNT(im.idImovel) AS qtd_imoveis,
       COUNT(ct.idContrato) AS qtd_fechados,
       IFNULL(SUM(im.valor), 0) AS valor_carteira,
       IFNULL(SUM(fn_calcula_comissao(ct.valor_fechado)), 0) AS comissao_total
FROM corretor co
LEFT JOIN imovel im ON im.idCorretor = co.idCorretor
LEFT JOIN contrato ct ON ct.idImovel = im.idImovel
GROUP BY co.idCorretor, co.nome
ORDER BY comissao_total DESC;

-- 6.3) 1:N (autorrelacionamento) - Equipe de cada gerente
SELECT g.nome AS gerente, c.nome AS corretor, c.creci
FROM corretor c
INNER JOIN corretor g ON g.idCorretor = c.idgerente
ORDER BY g.nome, c.nome;

-- 6.4) N:M - Histórico de visitas e se a visita virou contrato
SELECT cl.nome AS cliente, im.endereco AS imovel, av.data_visita, av.status_visita,
       co.nome AS corretor,
       CASE WHEN ct.idContrato IS NOT NULL THEN 'Sim' ELSE 'Não' END AS fechou_contrato
FROM agenda_visita av
INNER JOIN cliente cl ON cl.idCliente = av.idCliente
INNER JOIN imovel im ON im.idImovel = av.idImovel
INNER JOIN corretor co ON co.idCorretor = im.idCorretor
LEFT JOIN contrato ct ON ct.idImovel = av.idImovel AND ct.idCliente = av.idCliente
ORDER BY av.data_visita;

-- 6.5) N:M - Taxa de conversão de visitas realizadas em contratos, por corretor
SELECT co.nome AS corretor, COUNT(av.idVisita) AS visitas_realizadas,
       COUNT(ct.idContrato) AS convertidas,
       ROUND(COUNT(ct.idContrato) / COUNT(av.idVisita) * 100, 1) AS taxa_pct
FROM corretor co
INNER JOIN imovel im ON im.idCorretor = co.idCorretor
INNER JOIN agenda_visita av ON av.idImovel = im.idImovel AND av.status_visita = 'Realizada'
LEFT JOIN contrato ct ON ct.idImovel = av.idImovel AND ct.idCliente = av.idCliente
GROUP BY co.idCorretor, co.nome
ORDER BY taxa_pct DESC;

-- 6.6) N:M - Clientes que visitaram imóveis mas ainda não fecharam contrato
SELECT DISTINCT cl.nome, cl.telefone, cl.limite_credito
FROM cliente cl
INNER JOIN agenda_visita av ON av.idCliente = cl.idCliente
WHERE cl.idCliente NOT IN (SELECT idCliente FROM contrato);

-- =====================================================================
-- 7. EXTRAS
-- =====================================================================

-- 7.1) Transação: o UPDATE é desfeito pelo ROLLBACK
START TRANSACTION;
UPDATE imovel SET valor = valor * 2;
SELECT idImovel, valor FROM imovel;
ROLLBACK;
SELECT idImovel, valor FROM imovel;

-- 7.2) Índice para a busca por tipo e faixa de preço
CREATE INDEX idx_imovel_tipo_valor ON imovel (tipo, valor);

EXPLAIN SELECT * FROM imovel WHERE tipo = 'Casa' AND valor BETWEEN 300000 AND 700000;

SET SQL_SAFE_UPDATES = 1;