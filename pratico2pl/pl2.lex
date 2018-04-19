%{
#include "myscanner.h"
#include <string.h>
%}

%%
\<[a-zA-Z0-9]*[ =]*[a-zA-Z0-9]*\>       return TAG;
\<\/[a-zA-Z0-9]*[ =]*[a-zA-Z0-9]*\>     return CLOSETAG;
[ \t\n]                                 ;
%%


int yywrap(void){
    return 1;
}
