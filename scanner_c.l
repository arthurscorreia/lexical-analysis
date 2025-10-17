/* Seção de Definições em C */
%{
#include <stdio.h>
#include <string.h>

/* Enumeração de Tokens Refinada */
typedef enum {
    T_EOF = 0,

    // Palavras-chave
    T_SE = 258, T_SENAO, T_ENQUANTO, T_INTEIRO_KEYWORD, T_DECIMAL_KEYWORD, T_RETORNO,
    T_CARACTERE_KEYWORD,

    // Identificadores e Literais
    T_ID,
    T_INTEIRO,
    T_DECIMAL,
    T_PALAVRA,
    T_LITERAL_CARACTERE,

    // Operadores
    T_OP_IGUALDADE, T_OP_DIFERENTE, T_OP_MENOR, T_OP_MAIOR, T_OP_MENOR_IGUAL,
    T_OP_MAIOR_IGUAL, T_OP_SOMA, T_OP_SUB, T_OP_MULT, T_OP_DIV, T_OP_ATRIBUICAO,

    // Separadores
    T_PONTO_VIRGULA, T_VIRGULA, T_PARENTESES_ESQ, T_PARENTESES_DIR,
    T_CHAVES_ESQ, T_CHAVES_DIR,

    // Erro
    T_ERRO
} TokenType;

int yylval;

#define MAX_SYMBOLS 100
char *symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

int get_symbol_position(const char *id) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i], id) == 0) {
            return i;
        }
    }
    // Adiciona uma verificação para não estourar a tabela de símbolos
    if (symbol_count < MAX_SYMBOLS) {
        symbol_table[symbol_count] = strdup(id);
        return symbol_count++;
    } else {
        fprintf(stderr, "Erro: Tabela de símbolos cheia!\n");
        return -1; // Retorna um índice inválido
    }
}
%}

%option noyywrap

/* Definições de Expressões Regulares (apelidos) */
DIGITO         [0-9]
LETRA          [a-zA-Z_]
ID             {LETRA}({LETRA}|{DIGITO})*
INTEIRO        {DIGITO}+
DECIMAL        {DIGITO}+\.{DIGITO}*
COMENTARIO_LINHA \/\/[^\n]*
COMENTARIO_BLOCO \/\*([^*]|\*+[^*/])*\*+\/
PALAVRA_LITERAL \"[^"]*\"
CARACTERE_LITERAL   '[^']'


/* Seção de Regras */
%%
[ \t]+         { /* Ignorar espaços em branco e tabulações */ }
\n             { /* Apenas consome a nova linha, yylineno é incrementado automaticamente */ }
{COMENTARIO_LINHA} { /* Ignora comentário de linha */ }
{COMENTARIO_BLOCO} { /* Ignora comentário de bloco */ }

"se"           { return T_SE; }
"senao"        { return T_SENAO; }
"enquanto"     { return T_ENQUANTO; }
"inteiro"      { return T_INTEIRO_KEYWORD; }
"decimal"      { return T_DECIMAL_KEYWORD; }
"retorno"      { return T_RETORNO; }
"caractere"    { return T_CARACTERE_KEYWORD; }

{INTEIRO}      { yylval = atoi(yytext); return T_INTEIRO; }
{DECIMAL}        { return T_DECIMAL; }
{PALAVRA_LITERAL} { return T_PALAVRA; }
{CARACTERE_LITERAL} { return T_LITERAL_CARACTERE; }

{ID}           { yylval = get_symbol_position(yytext); if (yylval != -1) return T_ID; /* Ignora o ID se a tabela estiver cheia */ }

"=="           { return T_OP_IGUALDADE; }
"!="           { return T_OP_DIFERENTE; }
"<="           { return T_OP_MENOR_IGUAL; }
">="           { return T_OP_MAIOR_IGUAL; }
"<"            { return T_OP_MENOR; }
">"            { return T_OP_MAIOR; }
"+"            { return T_OP_SOMA; }
"-"            { return T_OP_SUB; }
"*"            { return T_OP_MULT; }
"/"            { return T_OP_DIV; }
"="            { return T_OP_ATRIBUICAO; }

";"            { return T_PONTO_VIRGULA; }
","            { return T_VIRGULA; }
"("            { return T_PARENTESES_ESQ; }
")"            { return T_PARENTESES_DIR; }
"{"            { return T_CHAVES_ESQ; }
"}"            { return T_CHAVES_DIR; }

.              {
                   fprintf(stderr, "Erro Léxico na linha %d: Caractere inesperado '%s'\n", yylineno, yytext);
                   return T_ERRO;
               }
%%
/* Seção de Código do Usuário */

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    } else {
        // Permite ler da entrada padrão se nenhum arquivo for fornecido
        yyin = stdin;
    }

    int token_id;
    while ((token_id = yylex())) {
        // Usando switch para uma saída mais detalhada e correta
        switch (token_id) {
            // Palavras-chave
            case T_SE:            printf("Token: %d (T_SE)          | Lexema: %s\n", token_id, yytext); break;
            case T_SENAO:          printf("Token: %d (T_SENAO)        | Lexema: %s\n", token_id, yytext); break;
            case T_ENQUANTO:         printf("Token: %d (T_ENQUANTO)       | Lexema: %s\n", token_id, yytext); break;
            case T_INTEIRO_KEYWORD:   printf("Token: %d (T_INTEIRO_KEYWORD) | Lexema: %s\n", token_id, yytext); break;
            case T_DECIMAL_KEYWORD: printf("Token: %d (T_DECIMAL_KEYWORD)| Lexema: %s\n", token_id, yytext); break;
            case T_RETORNO:        printf("Token: %d (T_RETORNO)      | Lexema: %s\n", token_id, yytext); break;
            case T_CARACTERE_KEYWORD:  printf("Token: %d (T_CARACTERE_KEYWORD)| Lexema: %s\n", token_id, yytext); break;

            // Identificadores e Literais
            case T_ID:            printf("Token: %d (T_ID)          | Posição: %d, Lexema: %s\n", token_id, yylval, symbol_table[yylval]); break;
            case T_INTEIRO:       printf("Token: %d (T_INTEIRO)     | Valor: %d\n", token_id, yylval); break;
            case T_DECIMAL:         printf("Token: %d (T_DECIMAL)       | Lexema: %s\n", token_id, yytext); break;
            case T_PALAVRA:        printf("Token: %d (T_PALAVRA)      | Lexema: %s\n", token_id, yytext); break;
            case T_LITERAL_CARACTERE:  printf("Token: %d (T_LITERAL_CARACTERE)| Lexema: %s\n", token_id, yytext); break;

            // Operadores
            case T_OP_IGUALDADE:  printf("Token: %d (T_OP_IGUALDADE)| Lexema: %s\n", token_id, yytext); break;
            case T_OP_DIFERENTE:  printf("Token: %d (T_OP_DIFERENTE)| Lexema: %s\n", token_id, yytext); break;
            case T_OP_MENOR:      printf("Token: %d (T_OP_MENOR)    | Lexema: %s\n", token_id, yytext); break;
            case T_OP_MAIOR:      printf("Token: %d (T_OP_MAIOR)    | Lexema: %s\n", token_id, yytext); break;
            case T_OP_MENOR_IGUAL:printf("Token: %d (T_OP_MENOR_IGUAL)| Lexema: %s\n", token_id, yytext); break;
            case T_OP_MAIOR_IGUAL:printf("Token: %d (T_OP_MAIOR_IGUAL)| Lexema: %s\n", token_id, yytext); break;
            case T_OP_SOMA:       printf("Token: %d (T_OP_SOMA)     | Lexema: %s\n", token_id, yytext); break;
            case T_OP_SUB:        printf("Token: %d (T_OP_SUB)      | Lexema: %s\n", token_id, yytext); break;
            case T_OP_MULT:       printf("Token: %d (T_OP_MULT)     | Lexema: %s\n", token_id, yytext); break;
            case T_OP_DIV:        printf("Token: %d (T_OP_DIV)      | Lexema: %s\n", token_id, yytext); break;
            case T_OP_ATRIBUICAO: printf("Token: %d (T_OP_ATRIBUICAO)| Lexema: %s\n", token_id, yytext); break;

            // Separadores
            case T_PONTO_VIRGULA:  printf("Token: %d (T_PONTO_VIRGULA)| Lexema: %s\n", token_id, yytext); break;
            case T_VIRGULA:        printf("Token: %d (T_VIRGULA)      | Lexema: %s\n", token_id, yytext); break;
            case T_PARENTESES_ESQ: printf("Token: %d (T_PARENTESES_ESQ)| Lexema: %s\n", token_id, yytext); break;
            case T_PARENTESES_DIR: printf("Token: %d (T_PARENTESES_DIR)| Lexema: %s\n", token_id, yytext); break;
            case T_CHAVES_ESQ:     printf("Token: %d (T_CHAVES_ESQ)   | Lexema: %s\n", token_id, yytext); break;
            case T_CHAVES_DIR:     printf("Token: %d (T_CHAVES_DIR)   | Lexema: %s\n", token_id, yytext); break;

            case T_ERRO:
                // A mensagem de erro já foi impressa para stderr
                break;
            default:
                // Este caso não deve ocorrer se todos os tokens forem tratados
                printf("Token não reconhecido no main: %d\n", token_id);
                break;
        }
    }

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
    
    // Fecha o arquivo se ele foi aberto
    if (yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}