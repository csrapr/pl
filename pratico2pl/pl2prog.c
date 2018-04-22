#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "myscanner.h"

extern int yylex();
extern int yylineno;
extern char* yytext;

typedef struct taglist {
    char* tagname;
    struct taglist* subtag;
    struct taglist* prev;
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

void buildTagStruct(Taglist* tags){
    //ntoken: 1 - tag, 2 - closetag
    int ntoken = yylex();
    
    if(ntoken == 1 && tags->tagname == NULL){
        tags -> tagname = getTagName(yytext);
        buildTagStruct(tags);
    }

    else if(ntoken == 1 && tags->tagname != NULL){
        if(tags -> subtag == NULL){
            tags -> subtag = malloc(sizeof(Taglist));
            Taglist* subtagptr = tags -> subtag;
            subtagptr -> tagname = getTagName(yytext);

            printf("%s -> %s ;\n", tags -> tagname, subtagptr -> tagname);

            subtagptr -> prev = tags;
            buildTagStruct(subtagptr);
        }
        else{
            Taglist* nextptr = tags -> subtag;
            while(nextptr -> next != NULL) nextptr = nextptr -> next;

            nextptr -> next = malloc(sizeof(Taglist));
            nextptr -> next -> prev = tags;
            nextptr -> next -> tagname = getTagName(yytext);

            printf("%s -> %s ;\n", tags -> tagname, nextptr -> next -> tagname);


            buildTagStruct(nextptr -> next);
        }
    }

    else if(ntoken == 2){
        if(tags->prev != NULL){
            tags = tags->prev;
            buildTagStruct(tags);
        }
        else {
            //desnecessario?
            Taglist* ptr = tags;
            while(ptr -> next != NULL) ptr = ptr -> next;
            ptr -> next = malloc(sizeof(Taglist));
            ptr -> next -> prev = tags;
            buildTagStruct(ptr -> next);
        }
    }
}

void printTagStruct(Taglist* tags){
    char* left = tags -> tagname;
    Taglist* subtags = tags -> subtag;

    while(subtags -> next != NULL){
        subtags = subtags -> next;
    }

}

int main(){

    Taglist* tags = malloc(sizeof(Taglist));
    Taglist* head = tags;

    printf("strict digraph g {\n");
    buildTagStruct(tags);
    printf("}\n");
    printf("\n");
    return 0;
}