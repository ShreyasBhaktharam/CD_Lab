#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sym_tab.h"
#define DEFAULT "~"

table* allocate_space_for_table()	
{
	/*
        allocate space for table pointer structure eg (t_name)* t
        initialise head variable eg t->head
        return structure
    	*/
    table* new_t = (table*) malloc(sizeof(table));

    if(!new_t) exit(0);

    new_t->head = NULL;
    return new_t;
}

symbol* allocate_space_for_symbol(char* name, int size, int type, int lineno, int scope) //allocates space for items in the list
{
	/*
        allocate space for entry pointer structure eg (s_name)* s
        initialise all struct variables(name, value, type, scope, length, line number)
        return structure
    	*/
    symbol* new_symbol = (symbol*) malloc(sizeof(symbol));

    new_symbol->name = name;
    new_symbol->size = size;
    new_symbol->type = type;
    new_symbol->line = lineno;
    new_symbol->scope = scope;
    new_symbol->next = NULL;
    new_symbol->val = DEFAULT;

    return new_symbol;
}

void insert_into_table(table* t_name, symbol* s_name)
{
    if(t_name->head == NULL) {
        t_name->head = s_name;
    }

    else{
        symbol* cur = t_name->head;

        while(cur->next){
            cur = cur->next;
        }

        cur->next = s_name;
    }
}

int check_symbol_table(table* t_name, char* s_name) //return a value like integer for checking
{
    if (t_name == NULL) return 0;
    else
    {
        symbol* cur = t_name->head;
        while (cur) {
            if(strcmp(s_name, cur->name) == 0) return 1;
            cur = cur->next;
        }
    }

    return 0;
}

void insert_value_to_name(table* t_name, char* name, char* value)
{
    /*
        if value is default value return back
        check if table is empty
        else traverse the table and find the name
        insert value into the entry structure
    */
    if(strcmp(value, DEFAULT) == 0) return ;
    symbol* cur = t_name->head;

    while(cur){
        if(strcmp(cur->name, name) == 0) {
            cur->val = value;
            break;
        }
        cur = cur->next;
    }
}

void display_symbol_table(table* t_name)
{
    /*
        traverse through table and print every entry
        with its struct variables
    */

    printf("Name\tSize\tType\tLineNo.\tScope.\tValue\n");
    symbol* cur = t_name->head;
    while(cur){
        printf("%s\t%d\t%d\t%d\t%d\t%s\n", cur->name, cur->size, cur->type, cur->line, cur->scope, cur->val);
        cur = cur->next;
    }

}

int get_size(int type){
    int size;
    switch(type){
        case CHAR:
            size = sizeof(char);
            break;
        case INT:
            size = sizeof(int);
            break;
        case FLOAT:
            size = sizeof(float);
            break;
        case DOUBLE:
            size = sizeof(double);
            break;
    }

    return size;
}

symbol* get_symbol(table* t, char* name){
    if (t == NULL) return 0;
    else
    {
        symbol* cur = t->head;
        while (cur) {
            if(strcmp(name, cur->name) == 0) return cur;
            cur = cur->next;
        }
    }

    return NULL;
}

int parse_num_type(char val[]){
// check for occurrence of floating point
    return ((strstr(val, ".")) ? DOUBLE : INT);
}


int get_type(char val[]){
    return ((val[0] == '"') ? CHAR : parse_num_type(val));
}

int is_valid_type(int ltype, int rtype){

    if(ltype == -1) return 1;

	if(
		((ltype == CHAR) && (rtype != CHAR))
		||
		((rtype == CHAR) && (ltype != CHAR))
	)
		return 0;

	if(ltype == rtype) return 1;
    if(ltype == FLOAT && rtype == DOUBLE) return 1;
    if(rtype == FLOAT && ltype == DOUBLE) return 1;

	return 0;
}

