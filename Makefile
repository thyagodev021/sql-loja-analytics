.PHONY: db test queries clean

db:
	rm -f loja.db
	sqlite3 loja.db < init.sql

queries: db
	@for f in queries/*.sql; do echo "\n== $$f"; sqlite3 -header -column loja.db < $$f; done

test: db
	@out=$$(sqlite3 loja.db < tests/checks.sql); \
	if [ -n "$$out" ]; then echo "$$out"; exit 1; fi; echo "OK: integridade dos dados"
	@sqlite3 loja.db "UPDATE itens_pedido SET quantidade = 9 WHERE pedido_id = 1;" 2>&1 | grep -q "ja entregue\|já entregue" \
		&& echo "OK: trigger de pedido entregue" || (echo "FALHA: trigger"; exit 1)

clean:
	rm -f loja.db
