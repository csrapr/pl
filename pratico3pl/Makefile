pl3: flex.f yacc.y
	rm -f lex.yy.c
	rm -f y.tab.c
	flex flex.f
	yacc yacc.y
	cc -o pl3 `pkg-config --cflags glib-2.0` y.tab.c `pkg-config --libs glib-2.0`