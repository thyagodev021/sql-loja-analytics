-- Retenção por coorte: % de clientes que voltam a comprar 1, 2 e 3 meses
-- depois do mês da primeira compra.
-- Técnicas: CTEs, aritmética de datas, agregação condicional
WITH primeira AS (
    SELECT cliente_id, MIN(ano_mes) AS coorte
    FROM v_vendas
    GROUP BY cliente_id
),
atividade AS (
    SELECT DISTINCT cliente_id, ano_mes FROM v_vendas
),
distancia AS (
    SELECT p.coorte,
           a.cliente_id,
           (CAST(substr(a.ano_mes, 1, 4) AS INTEGER) * 12 + CAST(substr(a.ano_mes, 6, 2) AS INTEGER))
         - (CAST(substr(p.coorte, 1, 4)  AS INTEGER) * 12 + CAST(substr(p.coorte, 6, 2)  AS INTEGER)) AS meses_depois
    FROM primeira p
    JOIN atividade a USING (cliente_id)
)
SELECT coorte,
       COUNT(DISTINCT CASE WHEN meses_depois = 0 THEN cliente_id END) AS clientes,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN meses_depois = 1 THEN cliente_id END)
             / COUNT(DISTINCT CASE WHEN meses_depois = 0 THEN cliente_id END), 1) AS "M+1 %",
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN meses_depois = 2 THEN cliente_id END)
             / COUNT(DISTINCT CASE WHEN meses_depois = 0 THEN cliente_id END), 1) AS "M+2 %",
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN meses_depois = 3 THEN cliente_id END)
             / COUNT(DISTINCT CASE WHEN meses_depois = 0 THEN cliente_id END), 1) AS "M+3 %"
FROM distancia
GROUP BY coorte
ORDER BY coorte
LIMIT 12;
