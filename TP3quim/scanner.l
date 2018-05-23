%{
#include "yy.tab.h"
%}

%%

"%language" 						{return language;}
"%baselang" 						{return baselangdir;}
"%inv"								{return inv;}
,									{return yytext[0];}
[ \t\n]								;					
[A-Z][A-Z]							{flag = yytext; return flag;}
[A-Za-z0-9]+( [A-Za-z0-9]+)*		{text = yytext; return text;}

%%

int yywrap (void) {return 1;}
