-- Margem de lucro por categoria e participação no lucro total
-- Técnicas: agregação, window function sobre agregados
SELECT categoria,
       ROUND(SUM(receita), 2)                              AS receita,
       ROUND(SUM(lucro), 2)                                AS lucro,
       ROUND(100.0 * SUM(lucro) / SUM(receita), 1)         AS margem_pct,
       ROUND(100.0 * SUM(lucro) / SUM(SUM(lucro)) OVER (), 1) AS pct_do_lucro_total
FROM v_vendas
GROUP BY categoria
ORDER BY lucro DESC;
