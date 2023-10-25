%option yylineno

%{
    #include<stdio.h>
    #include<stdlib.h>  
    #include<string.h> 
    #include"tree.h"
    #define YYSTYPE Node*
    #include"syntax.tab.h"
    int cnt = 0; 
    int lexError = 0;
    int yycolumn = 1;
    #define YY_USER_ACTION \
    	yylloc.first_line = yylloc.last_line = yylineno; \
    	yylloc.first_column = yycolumn; \
    	yylloc.last_column = yycolumn + yyleng - 1; \
    	yycolumn = yycolumn + yyleng; 
    int oct2int(char* num);
    int hex2int(char* num);
    int string2int(char* num);
%}

 // int类型
digit [0-9]
non_zero_digit [1-9]
int ({non_zero_digit}{digit}+)|{digit}

 // 八进制
oct "0"[0-7]+

 // 十六进制
hex_num [0-9a-fA-F]
hex "0"[xX]{hex_num}+

 // float类型
normal_float {digit}+"."{digit}+
efloat ({digit}*"."{digit}+|{digit}+".")[eE][+-]?{digit}+
float {normal_float}|{efloat}
 // float ({digit}+"."{digit}+) | (({digit}*"."{digit}+ | {digit}+".")[eE][+-]?{digit}+)

 // 标识符
id [_a-zA-Z][a-zA-Z0-9_]*

 // 各种符号
semi ";"
comma ","
assignop "="
relop ">"|"<"|">="|"<="|"=="|"!="
plus "+"
minus "-"
dot "."
star "*"
div "/"
and "&&"
or "||"
not "!"
type "int"|"float"
lp "("
rp ")"
lb "["
rb "]"
lc "{"
rc "}"
struct "struct"
return "return"
if "if"
else "else"
while "while"
whitespace [ \t]
line \n
line_annotation "//"
block_annotation "/*"

%%
{line} { yycolumn = 1; }

{line_annotation} {
    char ch = input();
    while(ch != '\n') {
        ch = input();
    }
}

{block_annotation} {
    char start = input();
    char end = input();
    int cnt = 0;
    int check = 0;
    while(start != '*' || end != '/') {
        start = end;
        end = input();
	// printf("%c%c %d%d\n", start, end, start, end);
	if(start == end && end == 0) {
	    check = 0;
	    cnt++;
	} else {
	    check = 1;
	    cnt = 0;
	}
	if(cnt == 10000 && !check) {
	    printf("Error type A at Line %d: Mysterious characters \"*/\"\n", yylineno);
    	    lexError++;
	    break;
	}
    }
}

{whitespace} { ; }

{semi} { 
    yylval = createNode("SEMI", enumLexOther, yylineno, 0, NULL);
    return SEMI; 
}

{comma} { 
    yylval = createNode("COMMA", enumLexOther, yylineno, 0, NULL);
    return COMMA; 
}

{assignop} { 
    yylval = createNode("ASSIGNOP", enumLexOther, yylineno, 0, NULL);
    return ASSIGNOP; 
}

{relop} { 
    yylval = createNode("RELOP", enumLexOther, yylineno, 0, NULL);
    return RELOP; 
}

{plus} { 
    yylval = createNode("PLUS", enumLexOther, yylineno, 0, NULL);
    return PLUS; 
}

{minus} {
    yylval = createNode("MINUS", enumLexOther, yylineno, 0, NULL); 
    return MINUS; 
}

{star} { 
    yylval = createNode("STAR", enumLexOther, yylineno, 0, NULL);
    return STAR; 
}

{dot} { 
    yylval = createNode("DOT", enumLexOther, yylineno, 0, NULL);
    return DOT; 
}

{div} { 
    yylval = createNode("DIV", enumLexOther, yylineno, 0, NULL);
    return DIV; 
}

{and} { 
    yylval = createNode("AND", enumLexOther, yylineno, 0, NULL);
    return AND; 
}

{or} { 
    yylval = createNode("OR", enumLexOther, yylineno, 0, NULL);
    return OR; 
}

{not} { 
    yylval = createNode("NOT", enumLexOther, yylineno, 0, NULL);
    return NOT; 
}

{type} { 
    yylval = createNode("TYPE", enumLexType, yylineno, 0, NULL);
    strcpy(yylval->strVal, yytext);
    return TYPE; 
}

{lp} { 
    yylval = createNode("LP", enumLexOther, yylineno, 0, NULL);
    return LP; 
}

{rp} { 
    yylval = createNode("RP", enumLexOther, yylineno, 0, NULL);
    return RP; 
}

{lb} { 
    yylval = createNode("LB", enumLexOther, yylineno, 0, NULL);
    return LB; 
}

{rb} { 
    yylval = createNode("RB", enumLexOther, yylineno, 0, NULL);
    return RB; 
}

{lc} { 
    yylval = createNode("LC", enumLexOther, yylineno, 0, NULL);
    return LC; 
}

{rc} { 
    yylval = createNode("RC", enumLexOther, yylineno, 0, NULL);
    return RC; 
}

{struct} { 
    yylval = createNode("STRUCT", enumLexOther, yylineno, 0, NULL);
    return STRUCT; 
}

{return} { 
    yylval = createNode("RETURN", enumLexOther, yylineno, 0, NULL);
    return RETURN; 
}
 
{if} { 
    yylval = createNode("IF", enumLexOther, yylineno, 0, NULL);
    return IF; 
}

{else} { 
    yylval = createNode("ELSE", enumLexOther, yylineno, 0, NULL);
    return ELSE; 
}

{while} { 
    yylval = createNode("WHILE", enumLexOther, yylineno, 0, NULL);
    return WHILE; 
}

{id} {
    // printf("%s\n", yytext); 
    yylval = createNode("ID", enumLexId, yylineno, 0, NULL);
    strcpy(yylval->strVal, yytext);
    return ID;
}

{float} {
    yylval = createNode("FLOAT", enumLexFloat, yylineno, 0, NULL);
    yylval -> floatVal = atof(yytext);
    // printf("%s %f %f\n", yytext, tmp, yylval->floatVal);
    return FLOAT;
}

{hex} { 
    yylval = createNode("INT", enumLexInt, yylineno, 0, NULL);
    yylval->intVal = hex2int(yytext);
    return INT;
}

{oct} { 
    yylval = createNode("INT", enumLexInt, yylineno, 0, NULL);
    yylval->intVal = oct2int(yytext);
    return INT;
}

{int} { 
    yylval = createNode("INT", enumLexInt, yylineno, 0, NULL);
    int a = string2int(yytext);
    // printf("int %d\n", a); 
    yylval->intVal = a;
    return INT;
}

. { 
    printf("Error type A at Line %d: Mysterious characters \"%s\"\n", yylineno, yytext); 
    lexError++;
    // yylval = createNode("Error", enumLexError, yylineno, 0, NULL);
    // return ERROR;
}

%%
int string2int(char* num) {
    int sum=0;
    for(int i=0; i<strlen(num); i++) {
        sum = sum*10 + num[i] - '0';
    }
    return sum;
}

int oct2int(char *num) {
    int sum = 0;
    for(int i=1; i<strlen(num); i++) {
        int tmp=0;
        if('0' <= num[i] && num[i] <= '7')
            tmp = num[i] - '0';
        sum = sum * 8 + tmp;
    }
    return sum;
}

int hex2int(char *num) {
    int sum = 0;
    for(int i=2; i<strlen(num); i++) {
        int tmp=0;
        if('0' <= num[i] && num[i] <= '9')
            tmp = num[i] - '0';
        else
        if('a' <= num[i] && num[i] <= 'f')
            tmp = num[i] - 'a' + 10;
        else
        if('A' <= num[i] && num[i] <= 'F')
            tmp = num[i] - 'F' + 10;
        sum = sum * 16 + tmp;
    }
    return sum;
}