2: pl2.lex pl2prog.c
	flex pl2.lex
	gcc -o 2 pl2prog.c lex.yy.c -ll
	#./2 < input.xml > output.dot
	#dot -Tps output.dot -o DIGRAPH.ps
	#xdg-open DIGRAPH.ps
	@echo ""
	@echo ""
