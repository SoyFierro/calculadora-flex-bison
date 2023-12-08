%{
#include "calc.tab.h"
%}

%%

"<<"        { return SHIFT_LEFT; }
">>"        { return SHIFT_RIGHT; }
"sqrt"      { return SQRT; }
[0-9]+      { yylval = atoi(yytext); return NUM; }
[-+\n()]    { return *yytext; }
[ \t]       ;
"%"         { return MOD; }
.           { return *yytext; }

%%

int yywrap() {
    return 1;
}
