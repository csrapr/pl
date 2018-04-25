%option main

%{
    //variaveis globais
    //^\<[^\/\>\?]+\> BEGIN TAG;

    #include <string.h>
    #include <stdlib.h>
    char* getTagName(char* yytext);
    void openDigraph();

    typedef struct taglist {
    char* tagname;
    struct taglist* subtag;
    struct taglist* prev;
    struct taglist* next;
    } Taglist;

    Taglist* tags;
%}

%x  TAG

%%
  openDigraph();
  tags = malloc(sizeof(Taglist));
\<[\?]+[^\>]+\> BEGIN TAG;
\<[^\/\>\?]+\> BEGIN TAG;

<TAG>\<[^\/\>\?]+\> {

    if(tags -> tagname == NULL){
        tags -> tagname = getTagName(yytext);
    }
    else {
        if(tags -> subtag == NULL){
            tags -> subtag = malloc(sizeof(Taglist));
            Taglist* subtagptr = tags -> subtag;
            subtagptr -> tagname = getTagName(yytext);

            if(tags-> tagname != NULL && subtagptr -> tagname != NULL) 
                printf("%s -> %s ;\n", tags -> tagname, subtagptr -> tagname);

            subtagptr -> prev = tags;
        }
        else{
            Taglist* nextptr = tags -> subtag;
            while(nextptr -> next != NULL) nextptr = nextptr -> next;

            nextptr -> next = malloc(sizeof(Taglist));
            nextptr -> next -> prev = tags;
            nextptr -> next -> tagname = getTagName(yytext);

            if(tags -> tagname != NULL && nextptr -> next -> tagname != NULL)
                printf("%s -> %s ;\n", tags -> tagname, nextptr -> next -> tagname);
        }
    }
}
<TAG>\<\/[^\>]+\>   {

    if(tags->prev != NULL){
            tags = tags->prev;
    }
    else {
        //desnecessario?
        Taglist* ptr = tags;
        while(ptr -> next != NULL) ptr = ptr -> next;
        ptr -> next = malloc(sizeof(Taglist));
        ptr -> next -> prev = tags;
    }
}

<TAG>[^\<] ;

<<EOF>> printf("}\n"); return 0;
%%

char* getTagName(char* yytext){
    char *token = strtok(yytext, " =");
    int length = strlen(token);
    char* text = token+1;
    if(token[length-1] == '>'){
        text[length-2] = '\0';
    }
    return text;
}

void openDigraph(){
    printf("strict digraph g {\n");
}