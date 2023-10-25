#include<stdio.h>
#include<string.h>
#include "semantic.h"

extern int yyrestart(FILE* f);
extern int yyparse();
extern Node* root;
extern void printTree(Node* root, int depth);
extern int lexError;
extern int synError;

int main(int argc, char** argv) {
    if(argc <= 1)
        return 1;
    // printf("%s\n", argv[1]);
    for(int i=1; i<argc; i++) {
    	FILE* f = fopen(argv[i], "r");
    	// printf("%s\n", argv[i]);
	if (!f) {
            perror(argv[i]);
            return 1;
    	}
    	yyrestart(f);
    	yyparse();
//	printTree(root, 0);
    	if(root != NULL && lexError == 0 && synError == 0)
            // printTree(root, 0);
	    semantic_analysis(root);
	root = NULL;
    }
}