{%
#include<stdio.h>
#include<stdlib.h>

typedef struct thesaurus{
	Directive directive;
	ConceptTable concepts;
	int pos;
} Thesaurus;

typedef Concepts *ConceptTable;

typedef struct stringlist{
	char **list;
	int pos;
} StringList;

typedef struct directive{
	char *baselang;
	char *langs[];
	char *invs[]; /*podemos colocar vários invariantes na mesma lista, sabendo que são pares*/
} Directive;

typedef struct concept{
char *name;
StringList translations;
char *bt;
StringList nt;
char *sn;
} Concept;

%}

%start thesaurus
%token language
%token baselangdir
%token inv
%token <Thesaurus> thesaurus
%token <Concept> concept
%token <char*> baselang flag text scope
%token <StringList> langs terms invs
%token <Directive> directive

%%

thesaurus	: directive concept 	{$$ = loadDirective($2); loadConcept($$,$3);}
			| thesaurus concept 	{loadConcept($$,$3);}	

directive 	: langs baselang invs {$$ = addlangs($1); addbaselang($$,$2); addInvs($$,$3);}
		  	| directive invs {addInvs($$,$2);}


langs		: language flag {$$ = createStringList($2);}
			| langs flag {addToStringList($$,$2);}

baselang	:  baselangdir flag {$$ = $2}

invs		: inv flag flag {$$ = createStringList($2,$3);}
			| invs inv flag flag {addToStringList($$,$3,$4);}

concept		: text {$$ = CreateConcept($1);}
			| concept flag terms {addTermsToConcept($$, $2, $3);} /*falta a tradução. Como relacionar conceitos com diretivas?*/

terms 		: text {$$ = createStringList($1);}
			| terms "," text {addToStringList($$,$3);}


%%

Thesaurus loadDirective(Directive dir){
	
	Thesaurus th = (Thesaurus) malloc(sizeof(struct thesaurus));

	th.directive = dir;
	th.concepts = (ConceptTable) malloc(49157 * sizeof(struct concept));
	th.pos = 0;
}

void loadConcept(Thesaurus th, Concept c){
	th.concepts[th.pos] = c;
	th.pos++;
}


Directive addLangs(StringList langs){

	Directive dir = (Directive) malloc(sizeof(struct directive));
	dir.langs = langs;
	return dir;
}

void addbaselang(Directive dir, char *baselang){
	dir.baselang = baselang;
}

void addInvs(Directive dir, char **invs){
	dir.invs = invs;
}

StringList createStringList(char *cont){

	StringList sl = (StringList) malloc(sizeof(struct stringlist));

	sl.list[0] = cont;
	sl.pos = 1;
}

char *getStringFromSL(StringList l, int n){
	if(n == -1)
		return l.list[l.pos];
	else return l.list[n];
}

void addToStringList(StringList sl, char *cont){
	
	sl.list[pos] = cont;
	sl.pos++;
}

Concept createConcept(char *name){
	
	Concept c = (Concept) malloc(sizeof(struct concept));
	c.name = name;

	return c;
}

void addTermsToConcept(Concept c, char *flag, StringList terms){
	
	if(flag == "BT")
		c.bt = terms.list[0];

	else if(flag == "NT"){
		if(terms.pos == 1){
			StringList tmp = createStringList(terms.list[0]);
			c.nt = tmp;
			tmp = NULL;
			free tmp;
		}
		else 
			addToStringList(c.nt, getStringFromSL(terms, -1));
	}

	else if(flag == "SN") 
		c.sn = terms.list[0];
}


int main(){
	yyparse();
	return 0;
}






