#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "myscanner.h"

extern int yylex();
extern int yylineno;
extern char* yytext;

typedef struct taglist {
    char tagname[64];
    struct taglist* subtag;
    struct taglist* next;
} Taglist;

char* getTagName(char* text){
    char * pch;
    char* name = NULL;

    pch = strtok (text,"<> ="); //mais expressoes regulares ;D <x=123> -> x
    if(!strstr(pch, "/")) {
        //printf("Can't get the name of a close tag");
        name = malloc(sizeof(char) * strlen(pch));
        name = strcpy(name, pch);
    }
    return name;
}


int main(){
    int ntoken, vtoken;

    ntoken = yylex();

    while(ntoken) {
        //imprime 1 se e uma tag nova, 2 se e para fechar uma tag - debugk
        printf("%d  -- %s\n", ntoken, getTagName(yytext));
        //vai buscar outro token
        ntoken = yylex();
    }

    return 0;
}