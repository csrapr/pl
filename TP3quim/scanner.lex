%{
#include "putas.h"
#include <stdio.h>
#include <stdlib.h>
%}

%%

"%language" 											{printf("language \n");return language;}
"%baselang" 											{printf("bsaelang \n"); return baselangdir;}
"%inv"													{printf("inv \n");return inv;}
,														{printf("%c \n", yytext[0]);return yytext[0];}
[ \t\n]													;					
[A-Z]{2}												{/*flag = yytext;*/ printf("flag \n"); return flag;}
[A-Za-z0-9][a-z0-9"("")"]+([ ]["("")"A-Za-z0-9]+)*		{/*text = yytext;*/ printf("text \n"); return text;}
.														printf("unexpected character \n");
%%

int yywrap() {return 1;}
