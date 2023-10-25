#include "tree.h"
#include <stdlib.h>

/*
createNode func
name: Node name
NodeType: lex or syn? type?
lineno: the no of the line
childNum: how many children of the node
children: child List
*/
Node* createNode(char* name, NodeType nodeType, int lineno, int childNum, Node** children) {
    Node* currentNode = (Node*)malloc(sizeof(Node));
    currentNode -> name = name;
    currentNode -> nodeType = nodeType;
    currentNode -> lineno = lineno;
    currentNode -> childNum = childNum;
    currentNode -> children = children;
    return currentNode;
}

void printTree(Node* root, int depth) {
    if(root->nodeType == enumSynNull) {
	return;
    }
    // printf("depth: %d    ", depth);
    for(int i=0; i<depth; i++) 
	printf("  ");
    switch(root->nodeType) {
        case enumSynNotNull:
            printf("%s (%d)\n", root->name, root->lineno);
            break;
        case enumLexId:
            printf("%s: %s\n", root->name, root->strVal);
            break;
        case enumLexType:
            printf("%s: %s\n", root->name, root->strVal);
            break;
        case enumLexInt:
            printf("%s: %d\n", root->name, root->intVal);
            break;
        case enumLexFloat:
            printf("%s: %f\n", root->name, root->floatVal);
            break;
        case enumLexOther:
            printf("%s\n", root->name);
            break;
        default:
            break;
    }
    for(int i=0; i<root->childNum; i++) {
        printTree(root->children[i], depth+1);
    }
}