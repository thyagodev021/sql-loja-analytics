-- ============================================================================
-- 02_seed.sql  |  Dados de exemplo gerados inteiramente em SQL
-- Usa CTEs recursivas + aritmética modular: determinístico (sempre os mesmos
-- dados), sem arquivos CSV e sem milhares de INSERTs.
-- ============================================================================

INSERT INTO categorias (id, nome) VALUES
    (1, 'Eletrônicos'), (2, 'Livros'),  (3, 'Casa'),       (4, 'Esporte'),
    (5, 'Moda'),        (6, 'Games'),   (7, 'Papelaria'),  (8, 'Beleza');

INSERT INTO produtos (id, nome, categoria_id, preco, custo) VALUES
    ( 1, 'Fone Bluetooth',         1,  199.90,  110.00),
    ( 2, 'Smartwatch',             1,  599.00,  390.00),
    ( 3, 'Carregador Turbo',       1,   89.90,   35.00),
    ( 4, 'Romance Clássico',       2,   49.90,   22.00),
    ( 5, 'Guia de SQL',            2,   79.90,   30.00),
    ( 6, 'HQ Edição Especial',     2,   59.90,   28.00),
    ( 7, 'Jogo de Panelas',        3,  349.90,  190.00),
    ( 8, 'Luminária de Mesa',      3,   99.90,   45.00),
    ( 9, 'Cafeteira Elétrica',     3,  229.90,  130.00),
    (10, 'Tênis de Corrida',       4,  389.90,  210.00),
    (11, 'Bola de Futebol',        4,   99.90,   50.00),
    (12, 'Kit Halteres',           4,  159.90,   85.00),
    (13, 'Camiseta Básica',        5,   59.90,   20.00),
    (14, 'Jaqueta Jeans',          5,  249.90,  120.00),
    (15, 'Mochila Urbana',         5,  179.90,   80.00),
    (16, 'Console Portátil',       6, 1999.00, 1550.00),
    (17, 'Controle Sem Fio',       6,  329.90,  210.00),
    (18, 'Jogo de Aventura',       6,  249.90,  150.00),
    (19, 'Caderno Universitário',  7,   34.90,   12.00),
    (20, 'Kit Canetas Gel',        7,   24.90,    8.00),
    (21, 'Agenda 2025',            7,   44.90,   18.00),
    (22, 'Perfume Importado',      8,  299.90,  140.00),
    (23, 'Hidratante Facial',      8,   69.90,   25.00),
    (24, 'Kit Barbear',            8,  119.90,   55.00);

-- 300 clientes (nomes, cidades e datas de cadastro combinados por módulo)
WITH RECURSIVE
n (i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 300),
nomes (id, nome) AS (VALUES
    (0,'Ana'),(1,'Bruno'),(2,'Carla'),(3,'Diego'),(4,'Elisa'),
    (5,'Felipe'),(6,'Gabriela'),(7,'Hugo'),(8,'Isabela'),(9,'Lucas')),
sobrenomes (id, sobrenome) AS (VALUES
    (0,'Silva'),(1,'Souza'),(2,'Oliveira'),(3,'Santos'),(4,'Lima'),
    (5,'Pereira'),(6,'Costa'),(7,'Ribeiro'),(8,'Almeida'),(9,'Carvalho')),
cidades (id, cidade, uf) AS (VALUES
    (0,'Rio de Janeiro','RJ'),(1,'São Paulo','SP'),(2,'Belo Horizonte','MG'),
    (3,'Salvador','BA'),(4,'Curitiba','PR'),(5,'Porto Alegre','RS'),
    (6,'Recife','PE'),(7,'Fortaleza','CE'))
INSERT INTO clientes (id, nome, email, cidade, estado, criado_em)
SELECT  n.i,
        nm.nome || ' ' || sb.sobrenome,
        lower(nm.nome) || '.' || lower(sb.sobrenome) || n.i || '@exemplo.com',
        c.cidade,
        c.uf,
        date('2022-01-01', '+' || ((n.i * 37) % 600) || ' days')
FROM n
JOIN nomes      nm ON nm.id = n.i % 10
JOIN sobrenomes sb ON sb.id = (n.i / 10) % 10
JOIN cidades    c  ON c.id  = (n.i * 3) % 8;

-- 2.000 pedidos em 2024-2025. Os 60 primeiros clientes compram bem mais
-- (distribuição "pareto"), o que deixa as análises de RFM interessantes.
WITH RECURSIVE n (i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 2000)
INSERT INTO pedidos (id, cliente_id, data_pedido, status)
SELECT  i,
        1 + ((i * 7919) % CASE i % 3 WHEN 0 THEN 60 WHEN 1 THEN 150 ELSE 300 END),
        date('2024-01-01', '+' || ((i * 13) % 730) || ' days'),
        CASE WHEN i % 17 = 0 THEN 'cancelado'
             WHEN i % 40 = 0 THEN 'pago'
             WHEN i % 25 = 0 THEN 'enviado'
             ELSE 'entregue' END
FROM n;

-- 1 a 3 itens por pedido
WITH k (n) AS (VALUES (1), (2), (3))
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
SELECT  p.id, pr.id, 1 + ((p.id + k.n) % 3), pr.preco
FROM pedidos p
JOIN k        ON k.n <= 1 + (p.id % 3)
JOIN produtos pr ON pr.id = 1 + ((p.id * 31 + k.n * 17) % 24);
