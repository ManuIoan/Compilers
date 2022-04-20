

#include <string.h> /* for strdup */
/*#include <stdlib.h> */ /* for atoi */
#include "john.tab.h" /* for token definitions and yylval */
DIGIT [0-9]
ID [a-zA-z][a-zA-Z0-9]*
print		[ -~]
REALI		"0"|{DIGIT}*"."{DIGIT}+
STR		\"{print}*\"

%%
"=>" { return(ASSGNOP); }
{DIGIT}+ { yylval.intval = atoi( yytext );
return(NUMBER); }
executa { return(EXECUTA); }
altfel { return(ALTFEL); }
gata { return(GATA); }
fi { return(FI); }
daca { return(DACA); }
in { return(IN); }
integer { return(INTEGER); }
lcuv { return(STRING); }
real { return(REAL); }
{STR} 		{ yylval.strval = malloc(yyleng * sizeof(char));
				  strcpy(yylval.strval, yytext);  return CUVANT; }
{REALI} 		{ yylval.floatval = atof(yytext); return FLOAT; }
inceput { return(LET); }
citeste { return(CITESTE); }
citeste_str { return(CITESTESTR); }
citeste_real { return(CITESTEREAL); }
scrie_str { return(SCRIESTR); }
scrie_real { return(SCRIEREAL); }
skip { return(SKIP); }
atunci { return(ATUNCI); }
cat_timp { return(CATTIMP); }
scrie { return(SCRIE); }
{ID} { yylval.id = (char *) strdup(yytext);
return(IDENTIFIER); }
[ \t\n]+ /* eat up whitespace */
. { return(yytext[0]);}
%%

int yywrap(void){}
