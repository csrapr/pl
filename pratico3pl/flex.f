%option noyywrap yylineno

%%
\%language      return LANGS;
\%baselang      return BASELANG;
\%inv           return INV;
SN              return DESC;
^[a-z]+$        { yylval.s = strdup(yytext); return TERM; }
[A-Z]+          { yylval.s = strdup(yytext); return LANG; }
[a-z]+          { yylval.s = strdup(yytext); return WORD; }
[ \t\n]+        ;
\#.*            ;
%%