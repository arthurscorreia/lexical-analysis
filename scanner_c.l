/* Seção de Definições em C */
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Enumeração de Tokens Refinada */
typedef enum {
    T_EOF = 0,

    // Palavras-chave
    T_SE_KEYWORD = 258, T_SENAO_KEYWORD, T_ENQUANTO_KEYWORD, T_ATE_KEYWORD, T_INTEIRO_KEYWORD, T_DECIMAL_KEYWORD, T_DEVOLVA_KEYWORD,
    T_CARACTERE_KEYWORD, T_PALAVRA_KEYWORD, T_VAZIO_KEYWORD, T_IMPRIMA_KEYWORD, T_RECEBA_KEYWORD, 
    T_E_KEYWORD, T_OU_KEYWORD, T_NAO_KEYWORD,

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
char yyltext[256]; // Auxiliar

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
DECIMAL        {DIGITO}+\.{DIGITO}+
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

"se"           { return T_SE_KEYWORD; }
"senao"        { return T_SENAO_KEYWORD; }
"enquanto"     { return T_ENQUANTO_KEYWORD; }
"ate"          { return T_ATE_KEYWORD; }
"inteiro"      { return T_INTEIRO_KEYWORD; }
"decimal"      { return T_DECIMAL_KEYWORD; }
"devolva"      { return T_DEVOLVA_KEYWORD; }
"caractere"    { return T_CARACTERE_KEYWORD; }
"palavra"      { return T_PALAVRA_KEYWORD; }
"vazio"        { return T_VAZIO_KEYWORD; }
"imprima"      { return T_IMPRIMA_KEYWORD; }
"receba"       { return T_RECEBA_KEYWORD; }

"e"            { return T_E_KEYWORD; }
"ou"           { return T_OU_KEYWORD; }
"nao"          { return T_NAO_KEYWORD; }

{INTEIRO}      { yylval = atoi(yytext); return T_INTEIRO; }
{DECIMAL}      { strcpy(yyltext, yytext); return T_DECIMAL; } // Copia de yytext para o auxiliar yyltext
{PALAVRA_LITERAL} { strcpy(yyltext, yytext); return T_PALAVRA; }
{CARACTERE_LITERAL} { strcpy(yyltext, yytext); return T_LITERAL_CARACTERE; }

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
                   fprintf(stderr, "Erro Léxico: Caractere inesperado '%s'\n", yytext);
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
            case T_SE_KEYWORD:        printf("<se> "); break;
            case T_SENAO_KEYWORD:     printf("<senao> "); break;
            case T_ENQUANTO_KEYWORD:  printf("<enquanto> "); break;
            case T_ATE_KEYWORD:       printf("<ate> "); break;
            case T_INTEIRO_KEYWORD:   printf("<inteiro> "); break;
            case T_DECIMAL_KEYWORD:   printf("<decimal> "); break;
            case T_DEVOLVA_KEYWORD:   printf("<devolva> "); break;
            case T_CARACTERE_KEYWORD: printf("<caractere> "); break;
            case T_PALAVRA_KEYWORD:   printf("<palavra> "); break;
            case T_VAZIO_KEYWORD:     printf("<vazio> "); break;
            case T_IMPRIMA_KEYWORD:   printf("<imprima> "); break;
            case T_RECEBA_KEYWORD:    printf("<receba> "); break;
            case T_E_KEYWORD:         printf("<e> "); break;
            case T_OU_KEYWORD:        printf("<ou> "); break;
            case T_NAO_KEYWORD:       printf("<nao> "); break;

            // Identificadores e Literais
            case T_ID:                printf("<id, %d> ", yylval); break;
            case T_INTEIRO:           printf("<inteiro, %d> ", yylval); break;
            case T_DECIMAL:           printf("<decimal, %s> ", yyltext); break;
            case T_PALAVRA:           printf("<palavra, %s> ", yyltext); break;
            case T_LITERAL_CARACTERE: printf("<caractere, %s> ", yyltext); break;

            // Operadores e separadores
            case T_OP_IGUALDADE:      printf("<==> "); break;
            case T_OP_DIFERENTE:      printf("<!=> "); break;
            case T_OP_MENOR:          printf("<<> "); break;
            case T_OP_MAIOR:          printf("<>> "); break;
            case T_OP_MENOR_IGUAL:    printf("<= "); break;
            case T_OP_MAIOR_IGUAL:    printf(">= "); break;
            case T_OP_SOMA:           printf("<+> "); break;
            case T_OP_SUB:            printf("<-> "); break;
            case T_OP_MULT:           printf("<*> "); break;
            case T_OP_DIV:            printf("</> "); break;
            case T_OP_ATRIBUICAO:     printf("<=> "); break;

            case T_PONTO_VIRGULA:     printf("<;> "); break;
            case T_VIRGULA:           printf("<,> "); break;
            case T_PARENTESES_ESQ:    printf("<(> "); break;
            case T_PARENTESES_DIR:    printf("<)> "); break;
            case T_CHAVES_ESQ:        printf("<{> "); break;
            case T_CHAVES_DIR:        printf("<}> "); break;

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

    if (yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}
