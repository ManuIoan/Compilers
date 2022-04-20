%{

#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include "ST.h" 
#include "SM.h" 
#include "CG.h" 
#define YYDEBUG 1 
int errors; 

struct lbs 
{
int for_goto;
int for_jmp_false;

};
struct lbs * newlblrec() 
{
return (struct lbs *) malloc(sizeof(struct lbs));
}

install ( char *sym_name )
{
symrec *s;
s = getsym (sym_name);
if (s == 0)
s = putsym (sym_name);
else { errors++;
printf( "%s is already defined\n", sym_name );
}
}

context_check( enum code_ops operation, char *sym_name )
{ symrec *identifier;
identifier = getsym( sym_name );
if ( identifier == 0 )
{ errors++;
printf( "%s", sym_name );
printf( "%s\n", " is an undeclared identifier" );
}
else gen_code( operation, identifier->offset,"NULL",0 );
}

%}
%union semrec /* Recordurile semantice */
{
int intval; 
float floatval;
char* strval;
char *id; 
struct lbs *lbls; 
}
%start program


%token <intval> NUMBER 
%token <strval> CUVANT
%token <floatval> FLOAT
%token <id> IDENTIFIER 
%token <lbls> DACA CATTIMP 
%token SKIP ATUNCI ALTFEL FI EXECUTA GATA
%token INTEGER STRING REAL CITESTE SCRIE LET IN CITESTESTR SCRIESTR CITESTEREAL SCRIEREAL
%token ASSGNOP
%left '-' '+';
%left '|' '&'  '<' '>' '=' '!';
%left '*' '/';
%right '^';


%%
program : LET
declarations
IN { gen_code( DATA, data_location() - 1,"NULL",0 ); }
commands
GATA { gen_code( HALT, 0,"NULL",0 ); YYACCEPT; }
;


declarations : 
| INTEGER id_seq IDENTIFIER '.' declarations  { install( $3 ); }
| STRING id_seq IDENTIFIER '.' declarations  { install( $3 ); }
| REAL id_seq IDENTIFIER '.' declarations  { install( $3 ); }

;

id_seq : 
| id_seq IDENTIFIER ',' { install( $2 ); }
;

commands : 
| commands command ';'
;

command : SKIP
| CITESTE IDENTIFIER { context_check( READ_INT, $2 ); }
| CITESTESTR IDENTIFIER { context_check( READ_STR, $2 ); }
| CITESTEREAL IDENTIFIER { context_check( READ_REAL, $2 ); }
| SCRIE exp { gen_code( WRITE_INT, 0,"NULL",0 ); }
| SCRIESTR exp { gen_code( WRITE_STR, 0,"NULL",0 ); }
| SCRIEREAL exp { gen_code( WRITE_REAL, 0,"NULL",0 ); }
| IDENTIFIER ASSGNOP exp { context_check( STORE, $1 ); }
| DACA exp { $1 = (struct lbs *) newlblrec();
$1->for_jmp_false = reserve_loc(); }
ATUNCI commands { $1->for_goto = reserve_loc(); }
ALTFEL { back_patch( $1->for_jmp_false,
JMP_FALSE,
gen_label(), "NULL", gen_label() ); }
commands
FI { back_patch( $1->for_goto, GOTO, gen_label(), "NULL", gen_label() ); }

| CATTIMP { $1 = (struct lbs *) newlblrec();
$1->for_goto = gen_label(); }
exp { $1->for_jmp_false = reserve_loc(); }
EXECUTA
commands
GATA { gen_code( GOTO, $1->for_goto,"NULL",0 );
back_patch( $1->for_jmp_false,
JMP_FALSE,
gen_label(),"NULL", gen_label() ); }
;



exp : NUMBER { gen_code( LD_INT, $1,"NULL",0 ); }
| CUVANT { gen_code( LD_STR, 5, $1,0 ); }
| FLOAT { gen_code( LD_REAL, 5, "NULL", $1 ); }
| IDENTIFIER { context_check( LD_VAR, $1 ); }
| exp '<' exp { gen_code( LT, 0,"NULL",0 ); }
| exp '=' exp { gen_code( EQ, 0,"NULL",0 ); }
| exp "!" exp { gen_code( NEQ, 0,"NULL",0 ); }
| exp '>' exp { gen_code( GT, 0,"NULL",0 ); }
| exp '+' exp { gen_code( ADD, 0,"NULL",0 ); }
| exp '-' exp { gen_code( SUB, 0,"NULL",0 ); }
| exp '*' exp { gen_code( MULT, 0,"NULL",0 ); }
| exp '%' exp { gen_code( LAS, 0,"NULL",0 ); }
| exp '/' exp { gen_code( DIV, 0,"NULL",0 ); }
| exp '^' exp { gen_code( PWR, 0,"NULL",0 ); }
| exp '|' exp { gen_code( SAU, 0,"NULL",0 ); }
| exp '&' exp { gen_code( SI, 0,"NULL",0 ); }
| '(' exp ')'
;

%%

main( int argc, char *argv[] )
{ 
    extern FILE *yyin;
++argv; --argc;
yyin = fopen( argv[0], "r" );
/*yydebug = 1;*/
errors = 0;
yyparse ();
printf ( "Parse Completed\n" );
if ( errors == 0 )
{ print_code ();
fetch_execute_cycle();
}
}

yyerror ( char *s ) /* Called by yyparse on error */
{
errors++;
printf ("%s\n", s);
}
