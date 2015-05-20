/*************************************************************************** 
Virtual Machine 
Author: Anthony A. Aaby
Modified by: Jordi Planes
***************************************************************************/ 

#include <stdio.h>
#include "SM.h"
#include "CG.h"

int main( int argc, char *argv[] ) {
  if ( argc < 2 ) {
    printf( "usage: %s <bytecode-file>\n", argv[0] );
    return 1;
  }
  
  read_bytecode( argv[1] );
  fetch_execute_cycle();

  return 0;
}
