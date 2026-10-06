-- Os 3 produtos mais vendidos (em receita) de cada categoria
-- Técnicas: ROW_NUMBER() com PARTITION BY, subconsulta em CTE
WITH ranking AS (
    SELECT categoria,
           produto,
           SUM(quantidade)       AS unidades,
           ROUND(SUM(receita),2) AS receita,
           ROW_NUMBER() OVER (PARTITION BY categoria
                              ORDER BY SUM(receita) DESC) AS posicao
    FROM v_vendas
    GROUP BY categoria, produto
)
SELECT categoria, posicao, produto, unidades, receita
FROM ranking
WHERE posicao <= 3
ORDER BY categoria, posicao;
