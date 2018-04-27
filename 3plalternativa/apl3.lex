%option main

%{
    #include <string.h>

    typedef struct taglist {
    char* tagname;
    struct taglist* subtag;
    struct taglist* prev;
    struct taglist* next;
    } Taglist;

    Taglist* tags;
%}

%x tag
%x closetag

%%
    tags = malloc(sizeof(Taglist));
    printf("strict digraph g {\n");

\<\?xml.*   ;
\<          BEGIN(tag);
\<\/        BEGIN(closetag);

<tag>[a-zA-Z0-9]+ {
    if(tags -> tagname == NULL){
        tags -> tagname = strdup(yytext);
    }
    else {
        if(tags -> subtag == NULL){
            tags -> subtag = malloc(sizeof(Taglist));
            Taglist* subtagptr = tags -> subtag;
            subtagptr -> tagname = strdup(yytext);

            if(tags-> tagname != NULL && subtagptr -> tagname != NULL) 
                printf("%s -> %s ;\n", tags -> tagname, subtagptr -> tagname);

            subtagptr -> prev = tags;
            tags = subtagptr;
        }
        else{
            Taglist* nextptr = tags -> subtag;
            while(nextptr -> next != NULL) nextptr = nextptr -> next;

            nextptr -> next = malloc(sizeof(Taglist));
            nextptr -> next -> prev = tags;
            nextptr -> next -> tagname = strdup(yytext);

            if(tags -> tagname != NULL && nextptr -> next -> tagname != NULL)
                printf("%s -> %s ;\n", tags -> tagname, nextptr -> next -> tagname);
            tags = nextptr -> next;
        }
    }
}
    /*<tag>\/.*\> BEGIN(closetag);*/

    /* limpeza do resto da linha */
<tag>\/\> BEGIN(closetag);
<tag>[ ].*\>[^\<]+   BEGIN 0;
<tag>\>[^\<]+        BEGIN 0;
<closetag>.* { 
    if(tags->prev != NULL){
            tags = tags->prev;
    }
    BEGIN 0;
}


<<EOF>> printf("}\n"); return 0;
%%

