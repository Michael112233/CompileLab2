#include<stdio.h>
#include<string.h>

typedef enum {
    enumSynNotNull,
    enumSynNull,
    enumLexId,
    enumLexType,
    enumLexInt,
    enumLexFloat,
    enumLexOther,
    enumLexError,
} NodeType;

typedef struct Node_d {
    char* name;
    NodeType nodeType;
    int lineno;
    union {
        char strVal[32];
        int intVal;
        double floatVal;
    };
    int childNum;
    struct Node_d** children;
} Node;

Node* createNode(char* name, NodeType nodeType, int lineno, int childNum, Node** children);
void printNode(Node* root, int depth);