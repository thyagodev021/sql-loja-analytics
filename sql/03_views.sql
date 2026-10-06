-- ============================================================================
-- 03_views.sql  |  Views reutilizadas pelas consultas analíticas
-- ============================================================================
DROP VIEW IF EXISTS v_vendas;
DROP VIEW IF EXISTS v_clientes_resumo;

-- Uma linha por item vendido (pedidos cancelados ficam de fora)
CREATE VIEW v_vendas AS
SELECT  p.id                                         AS pedido_id,
        p.cliente_id,
        p.data_pedido,
        strftime('%Y-%m', p.data_pedido)             AS ano_mes,
        pr.id                                        AS produto_id,
        pr.nome                                      AS produto,
        c.nome                                       AS categoria,
        i.quantidade,
        i.quantidade * i.preco_unitario              AS receita,
        i.quantidade * pr.custo                      AS custo_total,
        i.quantidade * (i.preco_unitario - pr.custo) AS lucro
FROM itens_pedido i
JOIN pedidos    p  ON p.id  = i.pedido_id
JOIN produtos   pr ON pr.id = i.produto_id
JOIN categorias c  ON c.id  = pr.categoria_id
WHERE p.status <> 'cancelado';

-- Resumo por cliente (inclui quem nunca comprou)
CREATE VIEW v_clientes_resumo AS
SELECT  cl.id,
        cl.nome,
        cl.estado,
        COUNT(DISTINCT v.pedido_id)            AS pedidos,
        ROUND(COALESCE(SUM(v.receita), 0), 2)  AS total_gasto,
        MAX(v.data_pedido)                     AS ultima_compra
FROM clientes cl
LEFT JOIN v_vendas v ON v.cliente_id = cl.id
GROUP BY cl.id;
