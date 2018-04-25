%option main

%{
  //variaveis globais
%}

%x     DE
b1     \<tr\>\<td\>
b2     \<\/td\>\<td\>
b3     <\/td\><\/tr\>



%%
    char *a;
    char seccao[100];
    char pt[100];
    char de[100];
    openlatex();

\<title\>Dicionário\ Português-Alemão.*/\<\/title\> {
  //yytext[yyleng-8] = '\0'; //para tirar o </title>
  //tem um / antes de \<\/title\> faz o mesmo que o que fiz na linha acima desta
  
  strcpy(seccao,yytext+38);
  //printf("%s   ", seccao); //debug
  //printf("%s\n", yytext+38);
}

^{b1}.*/{b2}          {strcpy(pt, yytext+8); BEGIN DE;}
<DE>{b2}.*/{b3}      {strcpy(de, yytext+9); BEGIN 0;

  a = strstr(yytext,"</td><td>");
  //a[0] = '\0'; //encontra o </td><td> e mete um \0 para nao ser imprimido. Isto funciona porque pusemos um \0 no yytext onde isso se encontrava. No printf o yytext so e imprimido ate esse \0. Isto nao e elegante mas funciona
  printf("\\term{%s}{DE=%s\\\\Dom=%s}\n", pt, de, seccao);
}

.|\n {} //come um caracter
<<EOF>>    printf("\\end{document}\n"); return 0;
%%

void openlatex(){
  printf("\\documentclass{book}\n\\usepackage[utf8]{inputenc}\n");
  printf("\\def\\term#1#2{\\textbf{#1}-#2\\\\}\\begin{document}\n");
  //printf("\\documentclass{book}\n\\begin{document}\n");
}






