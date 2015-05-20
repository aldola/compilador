/*------------------------------------------------------------------------- 
SYMBOL TABLE RECORD 
-------------------------------------------------------------------------*/ 

struct symrec 
{ 
  char *name; /* name of symbol */ 
  int offset; /* data offset */ 
  struct symrec *next; /* link field */ 
}; 
typedef struct symrec symrec; 

symrec * getsym (char *sym_name);
symrec * putsym (char *sym_name);

