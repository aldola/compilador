/*************************************************************************** 
Code Generator 
Author: Anthony A. Aaby
Modified by: Jordi Planes
***************************************************************************/ 

#include <stdio.h>
#include "SM.h"

/*------------------------------------------------------------------------- 
Data Segment 
-------------------------------------------------------------------------*/ 
int data_offset = 0; /* Initial offset */ 
int data_location() /* Reserves a data location */ 
{ 
  return data_offset++; 
} 

/*------------------------------------------------------------------------- 
  Code Segment 
  -------------------------------------------------------------------------*/ 
int code_offset = 0; /* Initial offset */ 
int gen_label() /* Returns current offset */ 
{ 
  return code_offset; 
} 

int reserve_loc() /* Reserves a code location */ 
{ 
  return code_offset++; 
} 

/* Generates code at current location */ 
void gen_code( enum code_ops operation, int arg ) 
{ 
  code[code_offset].op = operation; 
  code[code_offset++].arg = arg; 
} 

/* Generates code at a reserved location */ 
void back_patch( int addr, enum code_ops operation, int arg ) 
{ 
  code[addr].op = operation; 
  code[addr].arg = arg; 
} 

/*------------------------------------------------------------------------- 
Print Code to stdio 
-------------------------------------------------------------------------*/ 
void print_code() 
{ 
  int i = 0; 
  while (i < code_offset) { 
    printf("%3d: %-10s%4d\n",i,op_name[(int) code[i].op], code[i].arg ); 
    i++; 
  } 
} 

/* Reads code from file */

void read_bytecode( char *file_name ) {
  FILE * bytecode_file = fopen( file_name, "r" );
  int file_code[2];
  int i;  

  fread( &code_offset, sizeof( code_offset ), 1, bytecode_file  );
  fread( &data_offset, sizeof( data_offset ), 1, bytecode_file  );
#ifndef NDEBUG
  printf("Offsets: %d %d\n", code_offset, data_offset );
#endif
  for( i = 0; i < MAX_MEMORY && fread( file_code, sizeof( file_code ), 1, bytecode_file  ) != 0; i++ ) {
    back_patch( i, file_code[0], file_code[1] );
  }
  fclose( bytecode_file );
}

/* Writes code to file */

void write_bytecode( char *file_name ) {
  FILE * bytecode_file = fopen( file_name, "w" );
  int file_code[2];
  int i;
  
  fwrite( &code_offset, sizeof( code_offset ), 1, bytecode_file  );
  fwrite( &data_offset, sizeof( data_offset ), 1, bytecode_file  );
  for( i = 0; i < MAX_MEMORY; i++ ) {
    file_code[0] = code[ i ].op;
    file_code[1] = code[ i ].arg;
    fwrite( file_code, sizeof( file_code ), 1, bytecode_file  );
  }
  fclose( bytecode_file );
}

/************************** End Code Generator **************************/ 
