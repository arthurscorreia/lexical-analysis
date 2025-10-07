
%{
#include <stdio.h>
#include <string.h>

/* Adriano Maia - Para integração com o Bison/Yacc, os tokens seriam definidos
   em um arquivo de cabeçalho compartilhado (ex: y.tab.h).
   Por enquanto, definimos aqui. */

typedef enum {
    T_IF = 258,
    T_ELSE = 259,
    T_WHILE = 260,
    T_FOR = 261,
    T_ID = 262,
    T_INTEGER = 263,
    T_FLOAT = 264,
    T_RETURN = 265,
    T_OP_SOMA = 265,
    T_OP_ATRIBUICAO = 266,
    T_OP_SUBTRACAO = 267,
    T_OP_MULTIPLICACAO = 268,
    T_OP_DIVISAO = 269,
    T_OP_IGUALDADE = 270,
    T_OP_MAIOR = 271,
    T_OP_MAIOR_IGUAL = 272,
    T_OP_MENOR = 273,
    T_OP_MENOR_IGUAL = 274,
    T_OP_DIFERENTE = 275,
    T_TFLOAT = 276,
    T_TINT = 277,
    T_SEP_PONTOVIRGULA = 277,
    T_SEP_VIRGULA = 278,
    T_SEP_PARENTESES_ESQ = 279,
    T_SEP_PARENTESES_DIR = 280,
    T_SEP_CHAVES_ESQ = 281,
    T_SEP_CHAVES_DIR = 282,
    T_STRING = 283,
    T_EOF = 284,
    T_UNKNOWN = 285
    
} TokenType;

/* yylval é a variável global usada pelo Flex e Bison para trocar
   valores. Em um compilador real, isso seria uma 'union' para
   suportar diferentes tipos de dados (inteiros, strings, etc.). */

int yylval;

/* Tabela de Símbolos (baseada em table.l) */
#define MAX_SYMBOLS 100
char *symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

// Contador de linhas
int line_count = 1;

// Função para obter a posição de um identificador na tabela de símbolos
int get_symbol_position(const char *id) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i], id) == 0) {
            return i;
        }
    }
    // Adiciona o novo identificador se não for encontrado e retorna a nova posição
    symbol_table[symbol_count] = strdup(id);
    return symbol_count++;
}
%}

/* Opções do Flex */
%option noyywrap

/* Definições de Expressões Regulares (apelidos) */
DIGITO         [0-9]
LETRA          [a-zA-Z_]
ID             {LETRA}({LETRA}|{DIGITO})*
INTEIRO        {DIGITO}+
FLOAT          {DIGITO}+\.{DIGITO}*
COMENTARIO_LINHA \/\/[^\n]*
COMENTARIO_BLOCO \/\*([^*]|\*+[^*/])*\*+\/
STRING_LITERAL \"[^"]*\"

/* Seção de Regras */
%%
[ \t]+         { /* Ignorar espaços em branco e tabulações */ }
\n             { line_count++; }
{COMENTARIO_LINHA} { /* Ignora comentário de linha */ }
{COMENTARIO_BLOCO} { /* Ignora comentário de bloco */ }

"if"           { return T_IF; }
"else"         { return T_ELSE; }
"while"        { return T_WHILE; }
"int"          { return T_TINT; }
"float"        { return T_TFLOAT; }
"return"       { return T_RETURN; }

{INTEIRO}      { yylval = atoi(yytext); return T_INTEGER; }
{FLOAT}        { return T_FLOAT; }
{STRING_LITERAL} { return T_STRING; }

{ID}           { yylval = get_symbol_position(yytext); return T_ID; }

"=="           { return T_OP_IGUALDADE; }
"!="           { return T_OP_DIFERENTE; }
"<"            { return T_OP_MENOR; }
">"            { return T_OP_MAIOR; }
"<="           { return T_OP_MENOR_IGUAL; }
">="           { return T_OP_MAIOR_IGUAL; }

"+"            { return T_OP_SOMA; }
"-"            { return T_OP_SUBTRACAO; }
"*"            { return T_OP_MULTIPLICACAO; }
"/"            { return T_OP_DIVISAO; }
"="            { return T_OP_ATRIBUICAO; }

";"            { return T_SEP_PONTOVIRGULA; }
","            { return T_SEP_VIRGULA; }
"("            { return T_SEP_PARENTESES_ESQ; }
")"            { return T_SEP_PARENTESES_DIR; }
"{"            { return T_SEP_CHAVES_ESQ; }
"}"            { return T_SEP_CHAVES_DIR; }

.              { printf("Erro Léxico na linha %d: Caractere inesperado '%s'\n", line_count, yytext); return T_UNKNOWN; }

%%
/* Seção de Código do Usuário */

// Função main para testar o scanner de forma independente
int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (file) {
            yyin = file;
        }
    }

    int token_id;
    while ((token_id = yylex())) {
        printf("Token: %d ", token_id);

        if (token_id == T_IF) {
            printf("(IF) | Lexema: %s\n", yytext);
        } else if (token_id == T_ELSE) {
            printf("(ELSE) | Lexema: %s\n", yytext);
        } else if (token_id == T_WHILE) {
            printf("(WHILE) | Lexema: %s\n", yytext);
        } else if (token_id == T_TINT) {
            printf("(TINT) | Lexema: %s\n", yytext);
        } else if (token_id == T_TFLOAT) {
            printf("(TFLOAT) | Posição na tabela: %d, Lexema: %s\n", yylval, symbol_table[yylval]);
        } else if (token_id == T_RETURN) {
            printf("(RETURN) | Lexema: %s\n", yytext);
        } else if (token_id == T_INTEGER) {
            printf("(Integer) | Valor: %d\n", yylval);
        } else if (token_id == T_FLOAT) {
            printf("(Float)   | Lexema: %s\n", yytext);
        } else if (token_id == T_STRING) {
            printf("(String)  | Lexema: %s\n", yytext);
        } else if (token_id == T_OP_IGUALDADE) {
            printf("(IGUALDADE)| Lexema: %s\n", yytext);
        } else if (token_id == T_OP_DIFERENTE) {
            printf("(DIFERENTE)| Lexema: %s\n", yytext);
        } else if (token_id == T_OP_MENOR) {
            printf("(MENOR)| Lexema: %s\n", yytext);
        } else if (token_id == T_OP_MAIOR) {
            printf("(MAIOR)| Lexema: %s\n", yytext);
        } else if (token_id == T_OP_MENOR_IGUAL) {
            printf("(MENOR_IGUAL)| Lexema: %s\n", yytext);
        } else if (token_id == T_OP_MAIOR_IGUAL) {
            printf("(MAIOR_IGUAL)| Lexema: %s\n", yytext);
        } else if (token_id == T_OP_SOMA) {
            printf("(SOMA)| Lexema: %s\n", yytext);
        } else if (token_id == T_OP_ATRIBUICAO) {
            printf("(ATRIBUIÇÃO)| Lexema: %s\n", yytext);
        }  else if (token_id == T_OP_SUBTRACAO) {
            printf("(SUBTRAÇÃO)| Lexema: %s\n", yytext);
        }  else if (token_id == T_OP_MULTIPLICACAO) {
            printf("(MULTIPLICAÇÃO)| Lexema: %s\n", yytext);
        }  else if (token_id == T_OP_DIVISAO) {
            printf("(DIVISÃO)| Lexema: %s\n", yytext);
        } else if (token_id == T_SEP_PONTOVIRGULA) {
            printf("(PONTO E VIRGULA)| Lexema: %s\n", yytext);
        } else if (token_id == T_SEP_VIRGULA) {
            printf("(VIRGULA)| Lexema: %s\n", yytext);              
	} else if (token_id == T_SEP_PARENTESES_ESQ) {
            printf("(PARENTESES ESQUERDO)| Lexema: %s\n", yytext);
	} else if (token_id == T_SEP_PARENTESES_DIR) {
            printf("(PARENTESES DIREITO)| Lexema: %s\n", yytext);
        } else if (token_id == T_SEP_CHAVES_ESQ) {
            printf("(CHAVES ESQUERDA)| Lexema: %s\n", yytext);
        } else if (token_id == T_SEP_CHAVES_DIR) {
            printf("(CHAVES DIREITA)| Lexema: %s\n", yytext);
        }
    }

    // Adicione este trecho para imprimir a tabela de símbolos
    printf("\n\n--- Tabela de Símbolos Final ---\n");
    printf("Posição | Identificador\n");
    printf("-----------------------------\n");
    for (int i = 0; i < symbol_count; i++) {
        printf("%-7d | %s\n", i, symbol_table[i]);
    }
    printf("-----------------------------\n\n");


    // Libera a memória alocada para a tabela de símbolos
    for (int i = 0; i < symbol_count; i++) {
        free(symbol_table[i]);
    }

    return 0;

}
