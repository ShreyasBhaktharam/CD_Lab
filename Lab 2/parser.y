%{
	#include "sym_tab.c"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#define YYSTYPE char*
	/*
		declare variables to help you keep track or store properties
		scope can be default value for this lab(implementation in the next lab)
	*/

	static int CUR_TYPE;
	extern char* yytext;
	extern table* t;
	static int scope;
	static relop cur_rel_op;

	void yyerror(char* s); // error handling function
	int yylex(); // declare the function performing lexical analysis
	extern int yylineno; // track the line number

%}

%token T_INT T_CHAR T_DOUBLE T_WHILE  T_INC T_DEC   T_OROR T_ANDAND T_EQCOMP T_NOTEQUAL T_GREATEREQ T_LESSEREQ T_LEFTSHIFT T_RIGHTSHIFT T_PRINTLN T_STRING  T_FLOAT T_BOOLEAN T_IF T_ELSE T_STRLITERAL T_DO T_INCLUDE T_HEADER T_MAIN T_ID T_NUM

%start START


%%
START	: PROG { printf("Valid syntax\n"); YYACCEPT; }
		;
	  
PROG 	:  MAIN PROG
		|  DECLR ';' PROG
		|  ASSGN ';' PROG
		|
		;

DECLR 	: TYPE LISTVAR {CUR_TYPE = -1;} //unset CUR_TYPE after declaration has ended.
		;


LISTVAR : LISTVAR ',' VAR 
		| VAR
		;

VAR: T_ID '=' EXPR 	{

			if(check_symbol_table(t, $1)){
	// 					// symbol exists. raise error
				printf("Variable %s already decalred\n", $1);
				yyerror($1);
			}
			else{
				// symbol does not exist, create new entry
				int size = get_size(CUR_TYPE);
				int type = get_type($3);

				symbol* new_symbol = allocate_space_for_symbol($1, size, CUR_TYPE, yylineno, scope);
				insert_into_table(t, new_symbol);
				insert_value_to_name(t, $1, $3);
			}
		}
	| T_ID 		{
				/*
                   			check if symbol is in table
                    			if it is then print error for redeclared variable
                    			else make an entry and insert into the table
                    			revert variables to default values:type
				*/

					int size=get_size(CUR_TYPE);

					if(!check_symbol_table(t, $1)){
						symbol* new_symbol = allocate_space_for_symbol($1, size, CUR_TYPE, yylineno, scope);
						insert_into_table(t, new_symbol);
					}
					else {
						printf("Variable %s already declared\n", $1);
						yyerror($1);
					}
			}	 

//assign type here to be returned to the declaration grammar
TYPE : T_INT {CUR_TYPE=INT;}
       | T_FLOAT  {CUR_TYPE=FLOAT;}
       | T_DOUBLE {CUR_TYPE=DOUBLE;}
       | T_CHAR {CUR_TYPE=CHAR;}
       ;
    
/* Grammar for assignment */   
ASSGN : T_ID '=' EXPR 	{

				if(check_symbol_table(t, $1)){
					// symbol exists.
					int ltype = get_symbol(t, $1)->type;
					int rtype = get_type($3);
					if(is_valid_type(ltype, rtype))
						insert_value_to_name(t, $1, $3);
					else{
						printf("Mismatch type\n");
						yyerror($3);
					}
				}
				else{
					// symbol does not exist, raise error
					printf("Variable %s not declared\n", $1);
					yyerror($1);
				}
			}
	;

EXPR : EXPR REL_OP E
       | E { $$ = strdup($1); }
       ;
	   
E   : E '+' T {
			if(CUR_TYPE == INT)
				sprintf($$, "%d", atoi($3) + atoi($1));
			else
				sprintf($$, "%f", atof($3) + atof($1));
		}
    | E '-' T {
			if(CUR_TYPE == INT)
				sprintf($$, "%d", atoi($1) - atoi($3));
			else
				sprintf($$, "%f", atof($1) - atof($3));
		  
     }
    | T {$$ = strdup($1);}
    ;


T :   T '*' F {
			if(CUR_TYPE == INT)
				sprintf($$, "%d", atoi($1) * atoi($3));
			else
				sprintf($$, "%f", atof($1) * atof($3));
		}
    | T '/' F {
			if(CUR_TYPE == INT)
				sprintf($$, "%d", atoi($1) / atoi($3));
			else
				sprintf($$, "%f", atof($1) / atof($3));
		}
    | F {$$ = strdup($1);}
    ;

F : '(' EXPR ')' {$$ = strdup($2);}
    | T_ID {
			if(!check_symbol_table(t, $1)) {
				printf("Variable %s not declared\n", $1);
				yyerror($1);
			}
			else{
				symbol* sym = get_symbol(t, $1);
				$$ = strdup(sym->val);

				if(!is_valid_type(CUR_TYPE, sym->type)){
					printf("Mismatch type\n");
					yyerror($1);
				}
			}

		}
    | T_NUM {
			$$ = strdup($1);
			if(!is_valid_type(CUR_TYPE, get_type($1))){
				printf("Mismatch type\n");
				yyerror($1);
			}
		}

    |   T_STRLITERAL {
			$$ = strdup($1);
			if(!is_valid_type(CUR_TYPE, get_type($1))){
				printf("Mismatch type\n");
				yyerror($1);
			}
		}
    ;

REL_OP : T_LESSEREQ {cur_rel_op = LE;}
	   | T_GREATEREQ {cur_rel_op = GE;}
	   | '<' {cur_rel_op = LT;}
	   | '>' {cur_rel_op = GT;}
	   | T_EQCOMP {cur_rel_op = EQ;}
	   | T_NOTEQUAL {cur_rel_op = NE;}
	   ;	


/* Grammar for main function */
MAIN : TYPE T_MAIN '(' EMPTY_LISTVAR ')' '{' {scope++;} STMT '}' {scope--;} ;

EMPTY_LISTVAR : LISTVAR
		|	
		;

STMT : STMT_NO_BLOCK STMT
       | BLOCK STMT
       |
       ;


STMT_NO_BLOCK : DECLR ';'
       | ASSGN ';' 
       ;

BLOCK : '{' {scope++;} STMT '}' {scope--;} ;

COND : EXPR 
       | ASSGN
       ;


%%


/* error handling function */
void yyerror(char* s)
{
	printf("Error :%s at %d \n",s,yylineno);
}


int main(int argc, char* argv[])
{
	/* initialise table here */
	t = allocate_space_for_table();
	yyparse();
	/* display final symbol table*/
	display_symbol_table(t);
	return 0;

}

