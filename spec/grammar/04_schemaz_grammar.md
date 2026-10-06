# 04. Schemaz Grammar v0.1

## EBNF Syntax

```antlr
CompilationUnit ::= ImportDirective* Declaration* ;

ImportDirective ::= 'import' StringLiteral ';' ;

Declaration     ::= SchemaDeclaration
                  | FunctionDeclaration
                  | LetDeclaration ;

SchemaDeclaration ::= Annotation? 'schema' Identifier ('extends' Identifier)? '{' PropertyDeclaration* '}' ;

Annotation      ::= '@' Identifier '(' StringLiteral ')' ;

PropertyDeclaration ::= Identifier ':' TypeAnnotation '?'? ';' ;

FunctionDeclaration ::= 'fn' Identifier '(' ParameterList? ')' ('->' TypeAnnotation)? Block ;

ParameterList   ::= Parameter (',' Parameter)* ;

Parameter       ::= TypeAnnotation Identifier ;

TypeAnnotation  ::= Identifier ('<' TypeAnnotation '>')? ;

Block           ::= '{' Statement* '}' ;

Statement       ::= ReturnStatement | ExpressionStatement ;

ReturnStatement ::= 'return' Expression ';' ;

ExpressionStatement ::= Expression ';' ;
```
