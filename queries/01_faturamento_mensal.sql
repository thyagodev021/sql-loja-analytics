-- Faturamento mensal com crescimento vs. mês anterior (LAG) e acumulado do ano
-- Técnicas: CTE, window functions (LAG, SUM OVER), agregações
WITH mensal AS (
    SELECT ano_mes,
           COUNT(DISTINCT pedido_id)  AS pedidos,
           ROUND(SUM(receita), 2)     AS receita
    FROM v_vendas
    GROUP BY ano_mes
)
SELECT ano_mes,
       pedidos,
       receita,
       ROUND(receita / pedidos, 2)                                        AS ticket_medio,
       ROUND(100.0 * (receita - LAG(receita) OVER (ORDER BY ano_mes))
                   / LAG(receita) OVER (ORDER BY ano_mes), 1)             AS crescimento_pct,
       ROUND(SUM(receita) OVER (PARTITION BY substr(ano_mes, 1, 4)
                                ORDER BY ano_mes), 2)                     AS acumulado_ano
FROM mensal
ORDER BY ano_mes;
