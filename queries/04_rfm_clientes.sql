-- Segmentação RFM (Recência, Frequência, Valor) com NTILE
-- Data de referência fixa para o resultado ser reprodutível.
-- Técnicas: CTEs encadeadas, NTILE, CASE, agregação por segmento
WITH base AS (
    SELECT cliente_id,
           CAST(julianday('2025-12-31') - julianday(MAX(data_pedido)) AS INTEGER) AS recencia_dias,
           COUNT(DISTINCT pedido_id) AS frequencia,
           SUM(receita)              AS valor
    FROM v_vendas
    GROUP BY cliente_id
),
pontos AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY recencia_dias DESC) AS r,  -- 4 = comprou há pouco
           NTILE(4) OVER (ORDER BY frequencia)         AS f,  -- 4 = compra muito
           NTILE(4) OVER (ORDER BY valor)              AS m   -- 4 = gasta muito
    FROM base
),
segmentos AS (
    SELECT *,
           CASE WHEN r + f + m >= 10 THEN '1. Campeões'
                WHEN r + f + m >= 8  THEN '2. Leais'
                WHEN r + f + m >= 6  THEN '3. Potenciais'
                WHEN r >= 3          THEN '4. Novos / ocasionais'
                ELSE                      '5. Em risco' END AS segmento
    FROM pontos
)
SELECT segmento,
       COUNT(*)                        AS clientes,
       ROUND(AVG(recencia_dias), 0)    AS recencia_media_dias,
       ROUND(AVG(frequencia), 1)       AS pedidos_medios,
       ROUND(SUM(valor), 2)            AS receita_total
FROM segmentos
GROUP BY segmento
ORDER BY segmento;
