-- Clientes que já compraram, mas estão há mais de 180 dias sem comprar
-- (data de referência: 2025-12-31). Útil para campanhas de reativação.
-- Técnicas: view, HAVING, cálculo de datas
SELECT id,
       nome,
       estado,
       pedidos,
       total_gasto,
       ultima_compra,
       CAST(julianday('2025-12-31') - julianday(ultima_compra) AS INTEGER) AS dias_sem_comprar
FROM v_clientes_resumo
WHERE pedidos > 0
  AND julianday('2025-12-31') - julianday(ultima_compra) > 180
ORDER BY total_gasto DESC
LIMIT 10;
