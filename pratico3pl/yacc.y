%{
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <glib.h>

int yylex();
void yyerror(char* c);
int asprintf(char **strp, const char *fmt, ...);

typedef struct dict{
int numlanguages;
int numinv;
char* baselang;
char* languages[2]; //baselang, outra lang
char* inv[2];
GHashTable *blocktable;// = g_hash_table_new(NULL,NULL);
} *Dict;

typedef struct block{
char* baselangterm;
char* otherlangterm;
int numnarrowterms;
char* narrowterms[4096];
char* broadterm;
char* description;
} *Block;

Dict dict;
Block currentblock;
char* currentlang;

void addLanguage(char** languages, char* lang);
void addInv(char** invs, char* inv);
Block beginBlock(char* baselangterm);
void addNarrowTerm(char* word);
void addBroadTerm(char* word);
void addOtherLangTerm(char* word);
void addTerms(char* term);
void addDescription(char* desc);
%}

%union{char* s;}
%token LANGS BASELANG INV TERM LANG WORD
%type <s> TERM LANG WORD languages invs prog inst words

%%

z : prog { }

prog :  { $$ = "";}
     |  inst prog { asprintf(&$$, "%s%s \n", $1, $2); }
     ;

inst : LANGS languages { asprintf(&$$, "linguas %s", $2);}
     | BASELANG LANG { asprintf(&$$, "baselang %s\n", $2); dict->baselang = strdup($2);}
     | INV invs { asprintf(&$$, "relacoes inversas %s", $2); }
     | TERM          { asprintf(&$$, "termo na baselang %s\n", $1);  currentblock = beginBlock($1);}
     | LANG words    { asprintf(&$$, "Lang - %s, words - %s", $1, $2); currentlang = strdup($1); addTerms($2);}
     ;

languages : LANG languages     { asprintf(&$$, "%s %s", $1, $2); addLanguage(dict->languages, $1);}
          | LANG               { asprintf(&$$, "%s\n", $1); addLanguage(dict->languages, $1);}
          ;

invs : LANG invs     { asprintf(&$$, "%s %s", $1, $2); addInv(dict->inv, $1);}
     | LANG     { asprintf(&$$, "%s\n", $1); addInv(dict->inv, $1);}
     ;

words : WORD words {asprintf(&$$, "%s %s", $1, $2);}
      | WORD       { asprintf(&$$, "%s\n", $1);}
      ;
%%

#include "lex.yy.c"

int main(){
    dict = (Dict) malloc(sizeof(Dict));
    dict -> blocktable = g_hash_table_new(NULL,NULL);
    dict -> numlanguages = 0;
    dict->numinv = 0;
    yyparse();
    return 0;
}

void yyerror(char* s){
    fprintf(stderr, "%s, '%s', line %d \n", s, yytext, yylineno);
}

void addLanguage(char** languages, char* lang){
    languages[dict->numlanguages] = strdup(lang);
    dict->numlanguages++;
}

void addInv(char** invs, char* inv){
    invs[dict->numinv] = strdup(inv);
    dict->numinv++;
}

Block beginBlock(char* baselangterm){
    Block block = (Block) malloc(sizeof(Block));
    block->numnarrowterms = 0;
    block -> baselangterm = strdup(baselangterm);
    g_hash_table_insert(dict->blocktable, block->baselangterm, block);
    return block;
}

void addNarrowTerm(char* word){
    currentblock->narrowterms[currentblock->numnarrowterms] = strdup(word);
    currentblock->numnarrowterms++;

    int i;
    for(i = 0; i < currentblock->numnarrowterms; i++) {
    }
}

void addBroadTerm(char* word){
    currentblock->broadterm = strdup(word);
}

void addOtherLangTerm(char* word){
    currentblock -> otherlangterm = strdup(word);
}

void addTerms(char* term){
    if(!strcmp(currentlang, "BT")) {
        addBroadTerm(term);
    }
    else if(!strcmp(currentlang, "NT")) {
        char *token;

        token = strtok(term, " \n\t");

        while( token != NULL ) {
            addNarrowTerm(token);
            token = strtok(NULL, " \n\t");
        }
    }

    else if(!strcmp(currentlang, "SN")) {
        /*char *token;

        token = strtok(term, " \n\t");

        while( token != NULL ) {
            //printf("%s ", token);
            addDescription(token);
            token = strtok(NULL, " \n\t");
        }
        strcat(currentblock->description, "\0");*/
        addDescription(term);
    }

    else {
        addOtherLangTerm(term);
    }
}

void addDescription(char* desc) {
    if(currentblock -> description == NULL) {
        currentblock -> description = strdup(desc);
    }
    /*else {
        strcat(currentblock -> description, " ");
        strcat(currentblock -> description, strdup(desc));
    }*/
    //printf("%s\n", currentblock->description);
}