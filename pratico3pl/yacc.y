%{
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>

int yylex();
void yyerror(char* c);
int asprintf(char **strp, const char *fmt, ...);
%}

%union{char* s;}
%token LANGS BASELANG INV DESC TERM LANG WORD
%type <s> TERM LANG WORD languages prog inst

%%
z : prog { printf("%s\n", $1); }

prog :  { $$ = "";}
     |  inst prog { asprintf(&$$, "%s%s \n", $1, $2); }
     ;

inst : LANGS languages { asprintf(&$$, "linguas %s", $2); }
     | BASELANG LANG { asprintf(&$$, "baselang %s\n", $2);}
     | INV languages { asprintf(&$$, "relacoes inversas %s", $2); } //languages funciona para isto
     | TERM          { asprintf(&$$, "termo na baselang %s", $1);  }
     ;

languages : LANG languages     { asprintf(&$$, "%s %s", $1, $2); }
          | LANG               { asprintf(&$$, "%s\n", $1);      }
          ;
%%

#include "lex.yy.c"

int main(){
    yyparse();
    return 0;
}

void yyerror(char* s){
    fprintf(stderr, "%s, '%s', line %d \n", s, yytext, yylineno);
}