enum code_ops { HALT, STORE, JMP_FALSE, GOTO,
DATA, LD_INT,LD_STR, LD_VAR,LD_REAL,
READ_INT,READ_STR,READ_REAL, WRITE_INT,WRITE_STR,WRITE_REAL,
LT, EQ, NEQ, GT,SI,SAU,LAS, ADD, SUB, MULT, DIV, PWR };

char *op_name[] = {"halt", "store", "jmp_false", "goto",
"data", "ld_int","ld_str",  "ld_var","ld_real",
"in_int","in_str","in_real", "out_int","out_str","out.real",
"lt", "eq","neq", "gt", "si", "sau","las", "add", "sub", "mult", "div", "pwr" };
struct instruction
{
enum code_ops op;
int arg;
char scr[100];
float flo;
};

struct instruction code[999];

int stack[999];
char vb[999][100];
float fl[1000];

int pc = 0;
struct instruction ir;
int ar = 0;
int top = 0;
char ch;

void fetch_execute_cycle()
{ do { 
ir = code[pc++];

switch (ir.op) {
case HALT : printf( "halt\n" ); break;
case READ_INT : printf( "Input: " );
scanf( "%ld", &stack[ar+ir.arg] ); break;
case READ_STR : printf( "Input: " );
scanf( "%s", &vb[ar+ir.arg] ); break;
case READ_REAL : printf( "Input: " );
scanf( "%f", &fl[ar+ir.arg] ); break;
case WRITE_INT : printf( "Output: %d\n", stack[top--] ); break;
case WRITE_STR : printf( "Output: %s\n", vb[top--] ); break;
case WRITE_REAL : printf( "Output: %f\n", fl[top--] ); break;
case STORE : stack[ir.arg] = stack[top--];fl[ir.arg] = fl[top+1];strcpy(vb[ir.arg], vb[top+1]); break;
case JMP_FALSE : if ( stack[top--] == 0 )
pc = ir.arg;
if ( fl[top+1] == 0 )
pc = ir.arg;
break;
case GOTO : pc = ir.arg; break;
case DATA : top = top + ir.arg; break;

case LD_INT : stack[++top] = ir.arg;fl[top] = ir.flo;strcpy(vb[top], ir.scr); break;
case LD_STR : stack[++top] = ir.arg;strcpy(vb[top], ir.scr);fl[top] = ir.flo; break;
case LD_REAL : stack[++top] = ir.arg;fl[top] = ir.flo;strcpy(vb[top], ir.scr); break;
case LD_VAR : stack[++top] = stack[ar+ir.arg];fl[top] = fl[ar+ir.arg]; strcpy(vb[top], vb[ar+ir.arg]); break;
case LT : if ( stack[top-1] < stack[top] )stack[--top] = 1;
else stack[--top] = 0;
if ( fl[top-1] < fl[top] )fl[top] = 1;
else fl[top] = 0;
break;
case EQ : if ( stack[top-1] == stack[top] )
stack[--top] = 1;
else stack[--top] = 0;
if ( fl[top-1] == fl[top] )fl[top] = 1;
else fl[top] = 0;
break;
case NEQ : if ( stack[top-1] != stack[top] )
stack[--top] = 1;
else stack[--top] = 0;
if ( fl[top-1] != fl[top]) fl[top] = 1;
else fl[top] = 0;
break;
case GT : if ( stack[top-1] > stack[top] )
stack[--top] = 1;
else stack[--top] = 0;
if ( fl[top-1] > fl[top] )fl[top] = 1;
else fl[top] = 0;
break;
case SI : if ( stack[top-1] && stack[top] )stack[--top] = 1;
else stack[--top] = 0;
if ( fl[top-1] && fl[top] )fl[top] = 1;
else fl[top] = 0;
break;
case SAU : if ( stack[top-1] || stack[top] )stack[--top] = 1;
else stack[--top] = 0;
if ( fl[top-1] || fl[top] )fl[top] = 1;
else fl[top] = 0;
break;
case LAS : stack[top-1] = stack[top-1] % stack[top];
top--;
break;
case ADD : stack[top-1] = stack[top-1] + stack[top];
 fl[top-1] = fl[top-1] + fl[top];
top--;
break;
case SUB : stack[top-1] = stack[top-1] - stack[top];
fl[top-1] = fl[top-1] - fl[top];
top--;
break;
case MULT : stack[top-1] = stack[top-1] * stack[top];
fl[top-1] = fl[top-1] * fl[top];
top--;
break;
case DIV : stack[top-1] = stack[top-1] / stack[top];
fl[top-1] = fl[top-1] / fl[top];
top--;
break;
case PWR : stack[top-1] = stack[top-1] * stack[top];
fl[top-1] = fl[top-1] * fl[top];
top--;
break;
default : printf( "%sInternal Error: Memory Dump\n" );
break;
}
}
while (ir.op != HALT);
}
