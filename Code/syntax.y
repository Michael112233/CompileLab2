%locations

%{
    #include<stdio.h>
    #include<stdarg.h>
    #include "lex.yy.c"
    Node* root = NULL;
    Node** package(int childNum, Node* child1, ...);
    void yyerror(char* msg);
    int synError = 0; 
    int check[100000] = {0};  
%}

/* declare types */

%token SEMI COMMA ID TYPE INT FLOAT ASSIGNOP RELOP
%token IF WHILE ELSE STRUCT RETURN PLUS MINUS STAR DIV DOT AND OR NOT LP RP LB RB LC RC 

%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%left LB RB LP RP DOT

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%nonassoc EXT
%nonassoc FUNC

%nonassoc LOWER
%nonassoc UPPER

%%
// High-level Definitions
Program : ExtDefList                            {
						    // printf("ExtDefList\n");
						    $$ = createNode("Program", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                    root = $$;
                                                }
    ;
ExtDefList : ExtDef ExtDefList                  {
	   					    // printf("ExtDef ExtDefList\n");
                                                    $$ = createNode("ExtDefList", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    |                                           {
						    // printf("ExtDefList Empty\n");
                                                    $$ = createNode("ExtDefList", enumSynNull, @$.first_line, 0, NULL);
                                                }
    ;
ExtDef : Specifier ExtDecList SEMI              {
       				 	   	    // printf("Spe Ext SEMI %d\n", yylineno);
                                       	   	    $$ = createNode("ExtDef", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                       		}
    | Specifier SEMI                            {
						    // printf("Spe SEMI %d\n", yylineno);
                                                    $$ = createNode("ExtDef", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    | Specifier FunDec CompSt  			{
						    // printf("Specifier FunDec CompSt\n");
                                                    $$ = createNode("ExtDef", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Specifier FunDec SEMI                     { 
    						    $$ = createNode("ExtDef", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3)); 
    						}
    | error Specifier ExtDecList SEMI           {
						    // printf("err Spe Ext SEMI %d\n", yylineno);
						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
						    yyerrok;
						}
    | error Specifier FunDec CompSt 	   	{
						    // printf("err Spe Fun SEMI %d\n", yylineno);	
						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
                                                    yyerrok;
						}
    | error SEMI                                {
						    // printf("error SEMI %d\n", yylineno);
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
                                                    yyerrok;
                                                }
    ;
ExtDecList : VarDec             %prec UPPER     {
	   					    // printf("Ext VarDec\n");
                                                    $$ = createNode("ExtDecList", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | VarDec COMMA ExtDecList                   {
						    // printf("Var COMMA Ext\n");
                                                    $$ = createNode("ExtDecList", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | VarDec error COMMA ExtDecList     	{ 
  						    // printf("Var err COMMA Ext\n");
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
                                                }
    | VarDec error 	        %prec LOWER	{
						    // printf("VarDec error!\n");
						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
                                                }	
    ;

// Specifiers
Specifier : TYPE                                {
	  					    // printf("TYPE\n");
                                                    $$ = createNode("Specifier", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | StructSpecifier                           {
						    // printf("Spe Struct %d\n", yylineno);
                                                    $$ = createNode("Specifier", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    ;

StructSpecifier : STRUCT OptTag LC DefList RC   {
						    // printf("LC DefList RC\n");
                                                    $$ = createNode("StructSpecifier", enumSynNotNull, @$.first_line, 5, package(5, $1, $2, $3, $4, $5));
                                                }
    | STRUCT Tag                                {
						    // printf("Tag\n");
                                                    $$ = createNode("StructSpecifier", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    | STRUCT error LC DefList RC   		{ 
						    // printf("error LC\n");
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
    						}
    | STRUCT OptTag LC error RC                 { 
						    // printf("error RC\n");
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
    						}
    | STRUCT OptTag LC error                    {
						    // printf("LC error\n"); 
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
    						}
    ;

OptTag : ID                                     {
       						    // printf("OptTag ID\n");
                                                    $$ = createNode("OptTag", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    |                                           {
						    // printf("OptTag empty\n");
                                                    $$ = createNode("OptTag", enumSynNull, @$.first_line, 0, NULL);
                                                }
    ;

Tag : ID                                        {
    						    // printf("Tag ID\n");
                                                    $$ = createNode("Tag", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    ;

// Declartors 
VarDec : ID                                     {
       						    // printf("Var ID %d\n", yylineno);
                                                    $$ = createNode("VarDec", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | VarDec LB INT RB                          {
						    // printf("Var LB int RB\n");
                                                    $$ = createNode("VarDec", enumSynNotNull, @$.first_line, 4, package(4, $1, $2, $3, $4));
                                                }
    | VarDec LB error RB			{ 
						    // printf("Var LB error RB\n");
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
    						}
    | VarDec LB error				{ 
						    // printf("Var LB error\n");
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
                                                    yyerrok;
                                                }
    ;

FunDec : ID LP VarList RP                       {
       						    // printf("ID LP Var RP\n");
                                                    $$ = createNode("FunDec", enumSynNotNull, @$.first_line, 4, package(4, $1, $2, $3, $4));
                                                }                                             
    | ID LP RP                                  {
						    // printf("ID LP RP\n");
                                                    $$ = createNode("FunDec", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | ID LP error RP				{ 
						    // printf("ID LP error RP\n");
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
    						}
    | ID LP error				{ 
						    // printf("ID LP error\n");
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
    						}
    ;

VarList : ParamDec COMMA VarList                {
						    // printf("ParamDec COMMA Var\n");
                                                    $$ = createNode("VarList", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | ParamDec                                  {
						    // printf("varList Param\n");
                                                    $$ = createNode("VarList", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
 	
    ;

ParamDec : Specifier VarDec                     {
	 					    // printf("Param Spe Var\n");
                                                    $$ = createNode("ParamDec", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
	 | error VarDec				{
						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
						    yyerrok;
						}
    ;

// Local Definitions
DefList : Def DefList                           {
						    // printf("Def DefList %d\n", yylineno);
                                                    $$ = createNode("DefList", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    |                                           {
						    // printf("Param error\n");
                                                    $$ = createNode("DefList", enumSynNull, @$.first_line, 0, NULL);
                                                }

    ;

Def : Specifier DecList SEMI                    {
    						    // printf("Def Specifier Dec SEMI\n");
                                                    $$ = createNode("Def", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Specifier error SEMI			{
                                                    // printf("Specifier err SEMI\n");
                                                    $$ = createNode("Def", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    ;
DecList : Dec                                   {
						    // printf("DecList Dec %d\n", yylineno);
                                                    $$ = createNode("DecList", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | Dec COMMA DecList                         {
						    // printf("Dec COMMA DecList\n");
                                                    $$ = createNode("DecList", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Dec error DecList				{ 
						    // printf("Dec error DecList\n");
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
    						}
    ;

Dec : VarDec                                    {
    						    // printf("Dec Var %d\n", yylineno);
                                                    $$ = createNode("Dec", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | VarDec ASSIGNOP Exp                       {
						    // printf("Var = Exp\n");
                                                    $$ = createNode("Dec", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | VarDec ASSIGNOP error			{
						    // printf("var = err\n");
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
                                                    yyerrok;
						}
    | error ASSIGNOP Exp                        { 
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
                                                    yyerrok;
                                                }						
    ;

// Expressions
Exp : Exp ASSIGNOP Exp                          {
    						    // printf("exp = exp\n");
    						    // printf("%s %s %s\n", $1->name, $2->name, $3->name);
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp AND Exp                               {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp OR Exp                                {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp RELOP Exp                             {
						    // printf("Exp RELOP Exp\n");
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp PLUS Exp                              {
						    // printf("%s %s %s\n", $1->name, $2->name, $3->name);
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp MINUS Exp                             {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp STAR Exp                              {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp DIV Exp                               {
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | LP Exp RP					{
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | MINUS Exp					{
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    | NOT Exp					{
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                }
    | ID LP Args RP				{
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 4, package(4, $1, $2, $3, $4));
                                                }
    | ID LP RP					{
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp LB Exp RB				{
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 4, package(4, $1, $2, $3, $4));
                                                }
    | Exp DOT ID				{
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | ID					{
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | INT					{
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | FLOAT					{
                                                    $$ = createNode("Exp", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | Exp ASSIGNOP error			{
						    // printf("exp = err\n");
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
						}
    | Exp AND error				{
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
						}
    | Exp OR error				{
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
						    yyerrok;
                                                }
    | Exp RELOP error				{
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
                                                }
    | Exp PLUS error				{
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
                                                }
    | Exp MINUS error				{
						    // printf("exp minus error\n");
						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
						}
    | Exp STAR error				{
						    // printf("exp STAR error\n");
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
                                                }
    | Exp DIV error				{ 
						    // printf("exp div error\n");
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
                                                }
    | ID LP error RP				{
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
                                                }
    | Exp LB error RB				{
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
                                                }
    | ID LP Args error				{
						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, package(0, NULL));
                                                    yyerrok;
						}
    ;

Args : Exp COMMA Args                           {
                                                    $$ = createNode("Args", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | Exp                                       {
                                                    $$ = createNode("Args", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    ;

// Statements
CompSt : LC DefList StmtList RC                 {
						    $$ = createNode("CompSt", enumSynNotNull, @$.first_line, 4, package(4, $1, $2, $3, $4));
						}
    ;

StmtList : Stmt StmtList                        {
	 					    //Node** children = package(2, $1, $2);
                                                    $$ = createNode("StmtList", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
                                                    //for(int i=0; i<2; i++)
						    //     printf("%s\n", children[i] -> name);
						}
    |                                           {
                                                    $$ = createNode("StmtList", enumSynNull, @$.first_line, 0, NULL);
                                                }
    ;

Stmt : Exp SEMI                                 {
						    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 2, package(2, $1, $2));
						}
    | Exp error					{ 
						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
    						}
    | CompSt                                    {
                                                    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 1, package(1, $1));
                                                }
    | RETURN Exp SEMI                           {
                                                    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 3, package(3, $1, $2, $3));
                                                }
    | RETURN Exp error 				{ 
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
    						}
    | IF LP Exp RP Stmt  %prec LOWER_THAN_ELSE  {
						    // Node** children = package(5, $1, $2, $3, $4, $5);
                                                    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 5, package(5, $1, $2, $3, $4, $5));
                                                    // for(int i=0; i<5; i++)
						    //    printf("%s\n", children[i] -> name);
						}
    | IF LP Exp RP Stmt ELSE Stmt               {
                                                    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 7, package(7, $1, $2, $3, $4, $5, $6, $7));
                                                }
    | IF LP error RP Stmt %prec LOWER_THAN_ELSE { 
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
                                                    yyerrok; 
                                                }
    | IF LP error Stmt %prec LOWER_THAN_ELSE    {
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
                                                    yyerrok;
                                                }					    
    | IF LP Exp RP error ELSE Stmt              { 
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
                                                }
    | IF LP error RP ELSE Stmt              	{ 
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
                                                }
    | error LP Exp RP Stmt                      { 
    						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL); 
    						    yyerrok; 
                                                }
    | WHILE LP Exp RP Stmt                      {
                                                    $$ = createNode("Stmt", enumSynNotNull, @$.first_line, 5, package(5, $1, $2, $3, $4, $5));
                                                }
    | WHILE LP error RP Stmt	 		{
						    // printf("while LP error RP %d\n", yylineno);
						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
                                                    yyerrok;
						}
    | WHILE LP error Stmt			{
						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
                                                    yyerrok;
						}
    | error SEMI			        {
						    // printf("Stmt error SEMI %d\n", yylineno);
                                                    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
                                                    yyerrok;
                                                }
    | error CompSt				{
						    // printf("error CompSt %d\n", yylineno);
						    $$ = createNode("Error", enumSynNull, @$.first_line, 0, NULL);
                                                    yyerrok;
						}

%%

Node** package(int childNum, Node* child1, ...) {
    va_list ap;
    va_start(ap, child1);
    Node** children = (Node**)malloc(sizeof(Node*) * childNum);
    children[0] = child1;
    for(int i=1; i<childNum; i++) 
        children[i] = va_arg(ap, Node*);
    return children;
}

void yyerror(char* msg) {
    if(msg == "" || check[yylineno] == 1)
	return;
    synError++;
    fprintf(stderr, "Error type B at symbol %s at line %d: %s\n", yytext, yylineno, msg);
    check[yylineno] = 1;
}   