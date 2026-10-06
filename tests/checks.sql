-- Cada SELECT só retorna linha se uma regra for violada (saída vazia = tudo OK)
SELECT 'FALHA: itens com preço diferente do catálogo'
WHERE EXISTS (SELECT 1 FROM itens_pedido i JOIN produtos p ON p.id = i.produto_id
              WHERE i.preco_unitario <> p.preco);

SELECT 'FALHA: pedidos sem nenhum item'
WHERE EXISTS (SELECT 1 FROM pedidos p
              WHERE NOT EXISTS (SELECT 1 FROM itens_pedido i WHERE i.pedido_id = p.id));

SELECT 'FALHA: pedido anterior ao cadastro do cliente'
WHERE EXISTS (SELECT 1 FROM pedidos p JOIN clientes c ON c.id = p.cliente_id
              WHERE p.data_pedido < c.criado_em);

SELECT 'FALHA: receita da view difere da soma dos itens (sem cancelados)'
WHERE ROUND((SELECT SUM(receita) FROM v_vendas), 2) <>
      ROUND((SELECT SUM(i.quantidade * i.preco_unitario)
             FROM itens_pedido i JOIN pedidos p ON p.id = i.pedido_id
             WHERE p.status <> 'cancelado'), 2);

PRAGMA foreign_key_check;   -- lista violações de chave estrangeira (se houver)
