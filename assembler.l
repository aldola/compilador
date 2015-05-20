/*************************************************************************** 
Assembler 
Author: Jordi Planes
***************************************************************************/ 

%option nounput

%{
#include <stdio.h>
#include "SM.h"
#include "ST.h"
#include "CG.h"

int line_num = 1;

void print_error( char * message ) {
   printf("%d : %s\n", line_num, message );
}

// Label storing

struct { 
   char name[ 255 ];
   int address;
   int back_patches[ 15 ];
   int num_back_patches;
} labels[ 15 ];
int num_labels = 0;

void new_label( char *name, int address ) {
   int i, j;
   for( i = 0; i < num_labels; i++ ) {
      if ( strcmp( name, labels[ i ].name ) == 0 ) {
#ifndef NDEBUG
         printf("Number of BP: %d\n", labels[ i ].num_back_patches );
#endif
         for( j = 0; j < labels[ i ].num_back_patches; j++ )
            code[ labels[ i ].back_patches[ labels[ i ].num_back_patches ] ].arg = address;
         return;
      }
   }   
   strcpy( labels[ num_labels ].name, name );
   labels[ num_labels ].address = address;
   labels[ num_labels ].num_back_patches = 0;
   num_labels++;
}

char* remove_colon( char* string ) {
   char * temp = malloc( strlen( string ) );
   strncpy( temp, string, strlen( string ) - 1 );
   return temp;
}

int get_address( char* name ) {
   int i;
   for( i = 0; i < num_labels; i++ ) {
      if ( strcmp( name, labels[ i ].name ) == 0 ) {
         return labels[ i ].address;
      }
   }   
   return -1;
}

void add_backpatch_to_label( char *name, int address ) {
   int i;
   for( i = 0; i < num_labels; i++ ) {
      if ( strcmp( name, labels[ i ].name ) == 0 ) {
         labels[ i ].back_patches[  labels[ i ].num_back_patches++ ] = address;
      }
   }   
}

int command;

void create_command( char * text ) {
   int i;
   for( i = 0; op_name[ i ] != NULL; i++ ) {
      if( strcmp( text, op_name[ i ] ) == 0 ) {
         command = i; return;
      }
   }
   char message[ 50 ];
   sprintf( message, "Command %s not found\n", text );
   print_error( message );
   exit(-1);
}

%}

Identifier [a-zA-Z][a-zA-Z0-9]*
Command [a-z_]+
Integer [0-9]+

%x PARAM

%%

{Identifier}":"       { new_label( remove_colon( yytext ), gen_label() ); } 
{Command}             { create_command( yytext ); BEGIN( PARAM ); }
<PARAM>{Integer}      { gen_code( command, atoi( yytext ) ); BEGIN( INITIAL ); }
<PARAM>{Identifier}   { if ( get_address( yytext ) != -1 ) gen_code( command, get_address( yytext ) ); 
                        else { gen_code( command, -1 ); new_label( yytext, -1 ); add_backpatch_to_label( yytext, gen_label() ); }
                        BEGIN( INITIAL ); 
                      }
<INITIAL,PARAM>[ ]  ;
<INITIAL,PARAM>\n   line_num++;

%%

int yywrap() { return 1; }

int main( int argc, char *argv[] ) {
   if ( argc > 1 ) 
      yyin = fopen( argv[1], "r" );
   yylex();
   if ( argc > 2 )
      write_bytecode( argv[2] );
   printf("Finished\n");
   return 0;
}
