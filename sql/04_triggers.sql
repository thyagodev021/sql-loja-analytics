-- ============================================================================
-- 04_triggers.sql  |  Regras de negócio garantidas pelo próprio banco
-- ============================================================================
DROP TRIGGER IF EXISTS trg_bloqueia_item_pedido_entregue;
DROP TRIGGER IF EXISTS trg_bloqueia_item_pedido_cancelado;

-- Não é permitido alterar itens de pedidos já entregues
CREATE TRIGGER trg_bloqueia_item_pedido_entregue
BEFORE UPDATE ON itens_pedido
WHEN (SELECT status FROM pedidos WHERE id = OLD.pedido_id) = 'entregue'
BEGIN
    SELECT RAISE(ABORT, 'Pedido já entregue: itens não podem ser alterados');
END;

-- Não é permitido adicionar itens a pedidos cancelados
CREATE TRIGGER trg_bloqueia_item_pedido_cancelado
BEFORE INSERT ON itens_pedido
WHEN (SELECT status FROM pedidos WHERE id = NEW.pedido_id) = 'cancelado'
BEGIN
    SELECT RAISE(ABORT, 'Pedido cancelado: não é possível adicionar itens');
END;
