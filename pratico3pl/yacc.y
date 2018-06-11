%{
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <glib.h>

int yylex();
void yyerror(char* c);
int asprintf(char **strp, const char *fmt, ...);

typedef struct dict{
int numlanguages;
int numinv;
char* baselang;
char* languages[20]; //baselang, outra lang
char* inv[20];
} *Dict;

typedef struct block{
char* baselangterm;
char* otherlangterm;
int numnarrowterms;
char* narrowterms[4096];
char* broadterm;
char* description;
} *Block;

GHashTable *blocktable;


Dict dict = NULL;
Block currentblock = NULL;
char* currentlang;
FILE* f;
void addLanguage(char* lang);
void addInvs(char* inv);
Block beginBlock(char* baselangterm);
void addNarrowTerm(char* word);
void addBroadTerm(char* word);
void addOtherLangTerm(char* word);
void addTerms(char* term);
void addDescription(char* desc);
void doHtml();
%}

%union{char* s;}
%token LANGS BASELANG INV TERM LANG WORD 
%type <s> TERM LANG WORD languages invs prog inst words
%%
z : prog { }

prog :  { }
     |  inst prog { }
     ;

inst : LANGS languages { addLanguage(strdup($2));}
     | BASELANG LANG   { dict->baselang = strdup($2);}
     | INV invs        { addInvs(strdup($2)); }
     | TERM            { currentblock = beginBlock(strdup($1));}
     | LANG words      { currentlang = strdup($1); addTerms(strdup($2));}
     ;

languages : LANG languages     { asprintf(&$$, "%s %s", $1, $2);}
          | LANG               { asprintf(&$$, "%s\n", $1);}
          ;

invs : LANG invs     { asprintf(&$$, "%s %s", $1, $2);}
     | LANG          { asprintf(&$$, "%s\n", $1);     }
     ;

words : WORD words {asprintf(&$$, "%s %s", $1, $2);}
      | WORD       { asprintf(&$$, "%s\n", $1);}
      ;
%%

#include "lex.yy.c"


int main(){
    dict = (Dict) malloc(sizeof(Dict));
    blocktable = g_hash_table_new(NULL,NULL);
    dict -> numlanguages = 0;
    dict -> numinv = 0;
    yyparse();
    doHtml();
    return 0;
}

void yyerror(char* s){
    fprintf(stderr, "%s, '%s', line %d \n", s, yytext, yylineno);
}

void addLanguage(char* lang){

    char *token;

    token = strtok(lang, " \n\t");

    while( token != NULL ) {
        dict->languages[dict->numlanguages] = strdup(token);
        dict->numlanguages++;
        token = strtok(NULL, " \n\t");
    }
}

void addInvs(char* inv){

    char *token;

    token = strtok(inv, " \n\t");

    while( token != NULL ) {
        dict->inv[dict->numinv] = strdup(token);
        dict->numinv++;
        token = strtok(NULL, " \n\t");
    }
}

Block beginBlock(char* baselangterm){

    Block block = (Block) malloc(sizeof(Block));
    block->numnarrowterms = 0;
    block -> baselangterm = baselangterm;

    g_hash_table_insert(blocktable, g_strdup(baselangterm), block);
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

    char* newbt = strdup(word);
    newbt[strcspn(newbt, "\n")] = 0;
    currentblock -> broadterm = strdup(newbt);
}

void addOtherLangTerm(char* word){
    currentblock -> otherlangterm = strtok(strdup(word), "\n\t ");
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

    char* newdesc = strdup(desc);
    newdesc[strcspn(newdesc, "\n")] = 0;
    currentblock -> description = strdup(newdesc);

    /*else {
        strcat(currentblock -> description, " ");
        strcat(currentblock -> description, strdup(desc));
    }*/
    //printf("%s\n", currentblock->description);
}

void aux(void* k, void* val, void* userdata){
    Block value = (Block) val;
    printf("%s  \n", value->baselangterm);

    printf("%s  \n", value->narrowterms[0]);

    printf("%s  \n", value->description);

}

void auxIndex(void* k, void* val, void* userdata){
    Block value = (Block) val;
    // <li>Unclickable text <a href="page.html">clickable text</a>
    fprintf(f, "<li> <a href=%s.html> %s </a> </li>", value->baselangterm, value->baselangterm);

}

void auxBaselangs(void* k, void* val, void* userdata){
    Block value = (Block) val;
    char* tmpname = value->baselangterm;
    char* pagename = strcat(tmpname, ".html");
    f = fopen(pagename, "w");
    if (f == NULL) {
        printf("Error opening file!\n");
        exit(1);
    }

    fprintf(f, "<html>\n<body>\n");
    fprintf(f, "<p>Translation: %s</p>\n", value->otherlangterm);

    if(value->description != NULL){
        fprintf(f, "<p>Description: %s</p>\n", value->description);
    }

    if(value->numnarrowterms > 0){
        fprintf(f, "<p>Narrow terms:</p>\n");
        fprintf(f, "<ul>\n");
        int i = 0;
        for(i = 0; i < value->numnarrowterms; i++){
            fprintf(f, "<li> <a href=%s.html> %s </a> </li>\n", value->narrowterms[i], value->narrowterms[i]);
        }
        fprintf(f, "</ul>\n");
    }

    if(value->broadterm != NULL){
        fprintf(f, "<p>Broad term:</p>\n");
        fprintf(f, "<ul>\n");
        fprintf(f, "<li> <a href='%s.html'> %s </a> </li>\n", value->broadterm, value->broadterm);
        fprintf(f, "</ul>\n");
    }
    fprintf(f, "</body>\n</html>\n");
}

void doIndex(){
    f = fopen("index.html", "w");
    if (f == NULL) {
        printf("Error opening file!\n");
        exit(1);
    }
    fprintf(f, "<html>\n<body>\n<ul>\n");
    g_hash_table_foreach (blocktable, auxIndex, NULL);
    fprintf(f, "</ul>\n</body>\n</html>\n");
    fclose(f);
}

void doBaselangTerms(){
    g_hash_table_foreach (blocktable, auxBaselangs, NULL);
}

void auxBroadTermsSecondPass(void* k, void* val, void* userdata){
    char* bt = (char*) userdata;
    Block value = (Block) val;

    if(!strcmp(value->broadterm, bt)){
        int i = 0;
        for(i = 0; i < value->numnarrowterms; i++){
            fprintf(f, "<li><a href=%s.html>%s</a></li>\n", value->narrowterms[i], value->narrowterms[i]);
        }
    }
}

void auxBroadTermsFirstPass(void* k, void* val, void* userdata){
    Block value = (Block) val;
    char* bt;
    if(value -> broadterm != NULL){
        bt = strdup(value -> broadterm);
        char* pagename = strcat(strdup(bt), ".html");
        f = fopen(pagename, "w");
        if (f == NULL) {
            printf("Error opening file!\n");
            exit(1);
        }
        fprintf(f, "<html>\n<body>\n");
        fprintf(f, "<p>Broad term: %s</p>\n", bt);
        fprintf(f, "<ul>\n");
        g_hash_table_foreach (blocktable, auxBroadTermsSecondPass, bt);
        fprintf(f, "</ul>\n");
        fprintf(f, "</body>\n</hhtml>\n");
    }
}

void doBroadTerms(){
    g_hash_table_foreach (blocktable, auxBroadTermsFirstPass, NULL);
}

void doHtml(){
    //g_hash_table_foreach (blocktable, aux, NULL);
    doIndex();
    doBaselangTerms();
    doBroadTerms();
}