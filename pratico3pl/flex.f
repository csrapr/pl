%option noyywrap yylineno

%{
#include <stdio.h>
#include <stdlib.h>
%}

%%

\%language      return LANGS;
\%baselang      return BASELANG;
\%inv           return INV;
^[a-z]+$        { yylval.s = strdup(yytext); return TERM; }
[A-Z]+          { yylval.s = strdup(yytext); return LANG; }
[a-z()-]+       { yylval.s = strdup(yytext); return WORD; }
[ \t\n,]+       ;
\#.*            ;
%%