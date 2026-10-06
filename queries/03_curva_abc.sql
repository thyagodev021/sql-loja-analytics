-- Curva ABC de produtos: A = 80% da receita, B = próximos 15%, C = restante
-- Técnicas: soma acumulada com window function, CASE
WITH receita AS (
    SELECT produto, SUM(receita) AS receita
    FROM v_vendas
    GROUP BY produto
),
acumulado AS (
    SELECT produto,
           receita,
           SUM(receita) OVER (ORDER BY receita DESC
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
             / SUM(receita) OVER () AS pct_acumulado
    FROM receita
)
SELECT produto,
       ROUND(receita, 2)            AS receita,
       ROUND(100 * pct_acumulado, 1) AS pct_acumulado,
       CASE WHEN pct_acumulado <= 0.80 THEN 'A'
            WHEN pct_acumulado <= 0.95 THEN 'B'
            ELSE 'C' END            AS classe
FROM acumulado
ORDER BY receita DESC;
