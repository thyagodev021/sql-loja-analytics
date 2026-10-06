-- ============================================================================
-- 01_schema.sql  |  Estrutura do banco: tabelas, restrições e índices
-- ============================================================================
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS itens_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS categorias;

CREATE TABLE categorias (
    id    INTEGER PRIMARY KEY,
    nome  TEXT NOT NULL UNIQUE
);

CREATE TABLE produtos (
    id            INTEGER PRIMARY KEY,
    nome          TEXT NOT NULL,
    categoria_id  INTEGER NOT NULL REFERENCES categorias (id),
    preco         REAL NOT NULL CHECK (preco > 0),
    custo         REAL NOT NULL CHECK (custo >= 0),
    CHECK (custo <= preco)
);

CREATE TABLE clientes (
    id         INTEGER PRIMARY KEY,
    nome       TEXT NOT NULL,
    email      TEXT NOT NULL UNIQUE,
    cidade     TEXT NOT NULL,
    estado     TEXT NOT NULL CHECK (length(estado) = 2),
    criado_em  DATE NOT NULL
);

CREATE TABLE pedidos (
    id           INTEGER PRIMARY KEY,
    cliente_id   INTEGER NOT NULL REFERENCES clientes (id),
    data_pedido  DATE NOT NULL,
    status       TEXT NOT NULL
                 CHECK (status IN ('pago', 'enviado', 'entregue', 'cancelado'))
);

CREATE TABLE itens_pedido (
    pedido_id       INTEGER NOT NULL REFERENCES pedidos (id) ON DELETE CASCADE,
    produto_id      INTEGER NOT NULL REFERENCES produtos (id),
    quantidade      INTEGER NOT NULL CHECK (quantidade > 0),
    preco_unitario  REAL NOT NULL CHECK (preco_unitario > 0),
    PRIMARY KEY (pedido_id, produto_id)
);

CREATE INDEX idx_pedidos_cliente ON pedidos (cliente_id);
CREATE INDEX idx_pedidos_data    ON pedidos (data_pedido);
CREATE INDEX idx_itens_produto   ON itens_pedido (produto_id);
