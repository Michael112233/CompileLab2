#ifndef SEMANTIC_H
#define SEMANTIC_H

#include <stdio.h>
#include <stdlib.h>
#include "tree.h"

#define INT_TYPE 0
#define FLOAT_TYPE 1

#define HASH_SIZE 1024

typedef struct Type_d Type_;
typedef Type_* Type;
typedef struct FieldList_d FieldList_;
typedef FieldList_* FieldList;
typedef struct Structure_d Structure_;
typedef Structure_* Structure;
typedef struct Function_d Function_;
typedef Function_* Function;
typedef struct Entry_d Entry_;
typedef Entry_* Entry;

typedef enum {
    enumBasic,
    enumArray,
    enumStruct,
    enumStructDef,
    enumFunc,
} Kind;

typedef enum {
    enumVar,
    enumField,
} IdType;

struct Type_d {
    Kind kind;
    union {
    	int basic; // int or float?
	
        struct {
            Type elem;
            int size;
        } array;

        Structure structure; // struct
        Function func; // func
    };
};

struct FieldList_d {
    char name[32];
    Type type;
    FieldList next;
};

struct Structure_d {
    char name[32];
    FieldList head;
};

struct Function_d {
    char name[32];
    Type returnType;
    int paramNum;
    FieldList head;
    int hasDefined;
    int lineno;
};

struct Entry_d {
    char name[32];
    Type type;
    Entry hashNext;
    Entry layerNext;
};

void initSymbolTable();
unsigned int hash_pjw(char* name);
void insertSymbol(Entry symbol);
Entry findSymbolAll(char* name);
Entry findSymbolLayer(char* name);
Entry findSymbolFunc(char* name);
void delSymbol(char* name);
void pushLayer();
void popLayer();
int typeEqual(Type a, Type b);
void semantic_analysis(Node* root);
void Program(Node* root);
void ExtDefList(Node* root);
void ExtDef(Node* root);
Type Specifier(Node* root);
void ExtDecList(Node* root, Type type);
Function FunDec(Node* root);
void CompSt(Node* root, char* funcName, Type returnType);
Type StructSpecifier(Node* root);
FieldList DefList(Node* root, IdType idtype);
FieldList Def(Node* root, IdType idtype);
FieldList DecList(Node* root, Type type, IdType idtype);
FieldList Dec(Node* root, Type type, IdType idtype);
FieldList VarDec(Node* root, Type type, IdType idtype);
FieldList VarList(Node* root);
FieldList ParamDec(Node* root);
void StmtList(Node* root, Type type);
void Stmt(Node* root, Type type);
Type Exp(Node* root);
FieldList Args(Node* root);
void printArgs(FieldList args);
void printType(Type type);
void checkFunc();

#endif