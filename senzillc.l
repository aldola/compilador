/*************************************************************************** 
Scanner for the Simple language 
Author: Anthony A. Aaby
Modified by: Jordi Planes
***************************************************************************/ 

%option nounput
%option noinput

%{ 
/*========================================================================= 
C-libraries and Token definitions 
=========================================================================*/ 
#include <string.h> /* for strdup */ 
#include <stdlib.h> /* for atoi */ 
#include "senzillc.tab.h" /* for token definitions and yylval */ 


	int i;
	int j;
	char includes[100][100];
	char* file;
	char* in;
	char* out;
	int includecont = 0;
	int boolean; 
%} 

/*========================================================================= 
label Definitions 
=========================================================================*/ 
%x C_COMMENTA I_include C_COMMENTB
/*========================================================================= 
TOKEN Definitions 
=========================================================================*/ 
DIGIT [0-9] 
ID [a-z][a-z0-9]* 
inc #include 

/*========================================================================= 
REGULAR EXPRESSIONS defining the tokens for the Simple language 
=========================================================================*/ 
%% 

":=" { return(ASSGNOP); } 
{DIGIT}+ { yylval.intval = atoi( yytext ); 
return(NUMBER); } 
do { return(DO); } 
else { return(ELSE); } 
end { return(END); } 
fi { return(FI); } 
if { return(IF); } 
in { return(IN); } 
integer { return(INTEGER); } 
let { return(LET); } 
read { return(READ); } 
skip { return(SKIP); } 
then { return(THEN); } 
while { return(WHILE); } 
write { return(WRITE); } 
{ID} { yylval.id = (char *) strdup(yytext); return(IDENTIFIER); } 
[ \t\n]+ /* eat up whitespace */ 


{inc} { BEGIN(I_include); } 
"/*"  { BEGIN(C_COMMENTA); }

"//"  { BEGIN(C_COMMENTB); }
.   {return(yytext[0]);}
<C_COMMENTA>"*/" { BEGIN(INITIAL); }
<C_COMMENTA>.    { }
<C_COMMENTB>[\n] { BEGIN(INITIAL); }
<C_COMMENTB>.    { }
<I_include>[ \t]*
<I_include>[^ \t\n]+ {
	//Funciona fins que es troba que ha d'incloure el /usr/include/bits/types.h
	boolean=0;
 	in = yytext;
	out = malloc(strlen(in) - 2);
	i = 0;
	j = 0;
	while (strlen(in)> i) {
		if (in[i] != '<' && in[i] != '>' ){
			out[j] = in[i];
			j++;
		}
		i++;
	}
	i=0;
	j=0;
	while (i<includecont && boolean ==0){
		while (out[j] == includes[includecont][j] && boolean ==0) {
			j++;
			if (strlen(out)== j){
				boolean=1;
			}
		}
		j=0;
		i++;
	}
	if(boolean==0){
		j = 0;
		while (strlen(out)> j) {
			includes[includecont][j]=out[j];
			j++;
		}
		includecont++;
		file = malloc(strlen(yytext)+13);
		strcpy(file, "/usr/include/");
		strcat(file, out);
		if(access( file, F_OK ) != -1){
			yyin = fopen( file, "r" );
			file="";
			if ( ! yyin )
			printf("error" );
		
			yypush_buffer_state(yy_create_buffer( yyin, YY_BUF_SIZE ));
		}
     	}		
	BEGIN(INITIAL);
}
<<EOF>> {
				
	yypop_buffer_state();
	if ( !YY_CURRENT_BUFFER ){
        	yyterminate();
		printf("Acabem de sortir del tot \n" );
	}
        
}


%% 

int yywrap(void){ 
   return 1; 
} 

/************************** End Scanner File *****************************/ 

