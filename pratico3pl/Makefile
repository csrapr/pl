pl3: yacc.y flex.f
	rm -f lex.yy.c
	rm -f y.tab.c
	flex flex.f
	yacc yacc.y
	cc -o pl3 y.tab.c