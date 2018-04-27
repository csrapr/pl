2: apl3.lex
	flex apl3.lex
	gcc -o 2 lex.yy.c -ll
	@echo "Programa:"
grafico:
	rm DIGRAPH.ps
	dot -Tps output.dot -o DIGRAPH.ps
	xdg-open DIGRAPH.ps
