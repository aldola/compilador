/*************************************************************************** 
  Code Generator
***************************************************************************/ 

#ifndef __CG_H
#define __CG_H

#include "SM.h"

extern int code_offset;

int data_location();
void gen_code( enum code_ops operation, int arg );
int reserve_loc();
void back_patch( int addr, enum code_ops operation, int arg );
int gen_label();
void print_code();
void read_bytecode( char *file_name );
void write_bytecode( char *file_name );

#endif
