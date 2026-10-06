# Schemaz Language Syntax & Grammar

```ebnf
Program ::= Statement* ;

Statement ::= SchemaDecl
            | InstanceDecl
            | FunctionDecl
            | LetDecl
            | ImportDecl
            | Expression ;

SchemaDecl ::= "schema" Identifier ("extends" Identifier)? "{" PropertyDecl* "}" ;
PropertyDecl ::= Identifier ":" Identifier ;

InstanceDecl ::= Identifier Identifier "{" PropertyInitializer* "}" ;
PropertyInitializer ::= Identifier ":" Expression ;

FunctionDecl ::= "function" Identifier "(" ParameterList? ")" ("->" Identifier)? "{" Statement* "}" ;
LetDecl ::= "let" Identifier "=" Expression ;
ImportDecl ::= "import" "dart"? StringLiteral ;
```
