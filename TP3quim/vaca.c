#include <stdio.h>
#include <stdlib.h>
#include "putas.h"

extern int yylex();

int main(void){

	int rena;
	int c = 0;

	rena = yylex();
	while(rena){
		printf("%d", c++);
		rena = yylex();
	}
	return 0;

}