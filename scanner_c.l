/* Seção de Definições em C */
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Enumeração de Tokens Refinada */
typedef enum {
    T_EOF = 0,

    // Palavras-chave
    T_SE_KEYWORD = 258, T_SENAO_KEYWORD, T_ENQUANTO_KEYWORD, T_ATE_KEYWORD, T_INTEIRO_KEYWORD, T_QUEBRADO_KEYWORD, T_DEVOLVA_KEYWORD,
    T_CARACTERE_KEYWORD, T_TEXTO_KEYWORD, T_VAZIO_KEYWORD, T_IMPRIMA_KEYWORD, T_RECEBA_KEYWORD, 
    T_E_KEYWORD, T_OU_KEYWORD, T_NAO_KEYWORD, T_FATO_KEYWORD, T_SERPENTE_KEYWORD,

    // Identificadores e Literais
    T_ID,
    T_INTEIRO_LITERAL,
    T_QUEBRADO_LITERAL,
    T_TEXTO_LITERAL,
    T_CARACTERE_LITERAL,
    T_FATO_LITERAL,

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
QUEBRADO        {DIGITO}+\.{DIGITO}+
COMENTARIO_LINHA \/\/[^\n]*
COMENTARIO_BLOCO \/\*([^*]|\*+[^*/])*\*+\/
TEXTO_LITERAL \"[^"]*\"
CARACTERE_LITERAL   '[^']'

/* Seção de Regras */
%%
[ \t]+         { /* Ignorar espaços em branco e tabulações */ }
\n             { printf("\n"); } // Melhora a saída
{COMENTARIO_LINHA} { /* Ignora comentário de linha */ }
{COMENTARIO_BLOCO} { /* Ignora comentário de bloco */ }

"se"           { return T_SE_KEYWORD; }
"senao"        { return T_SENAO_KEYWORD; }
"enquanto"     { return T_ENQUANTO_KEYWORD; }
"ate"          { return T_ATE_KEYWORD; }
"inteiro"      { return T_INTEIRO_KEYWORD; }
"quebrado"      { return T_QUEBRADO_KEYWORD; }
"devolva"      { return T_DEVOLVA_KEYWORD; }
"caractere"    { return T_CARACTERE_KEYWORD; }
"texto"      { return T_TEXTO_KEYWORD; }
"vazio"        { return T_VAZIO_KEYWORD; }
"imprima"      { return T_IMPRIMA_KEYWORD; }
"receba"       { return T_RECEBA_KEYWORD; }
"serpente"     { return T_SERPENTE_KEYWORD; }

"e"            { return T_E_KEYWORD; }
"ou"           { return T_OU_KEYWORD; }
"nao"          { return T_NAO_KEYWORD; }

"fato"         { return T_FATO_KEYWORD; }

{INTEIRO}      { yylval = atoi(yytext); return T_INTEIRO_LITERAL; }
{QUEBRADO}      { strcpy(yyltext, yytext); return T_QUEBRADO_LITERAL; } // Copia de yytext para o auxiliar yyltext
{TEXTO_LITERAL} { strcpy(yyltext, yytext); return T_TEXTO_LITERAL; }
{CARACTERE_LITERAL} { strcpy(yyltext, yytext); return T_CARACTERE_LITERAL; }
"real"         { strcpy(yyltext, yytext); return T_FATO_LITERAL; }
"fake"         { strcpy(yyltext, yytext); return T_FATO_LITERAL; }

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

    // Buffer para armazenar toda a saída antes de imprimir
    char output_buffer[65536] = ""; 
    char temp[512];

    int token_id;
    while ((token_id = yylex())) {
        // Em vez de imprimir direto, salvamos em 'temp' e depois concatenamos em 'output_buffer'
        switch (token_id) {
            // Usando switch para uma saída mais detalhada e correta
            // Palavras-chave
            case T_SE_KEYWORD:        sprintf(temp, "<se> "); break;
            case T_SENAO_KEYWORD:     sprintf(temp, "<senao> "); break;
            case T_ENQUANTO_KEYWORD:  sprintf(temp, "<enquanto> "); break;
            case T_ATE_KEYWORD:       sprintf(temp, "<ate> "); break;
            case T_INTEIRO_KEYWORD:   sprintf(temp, "<inteiro> "); break;
            case T_QUEBRADO_KEYWORD:  sprintf(temp, "<quebrado> "); break;
            case T_DEVOLVA_KEYWORD:   sprintf(temp, "<devolva> "); break;
            case T_CARACTERE_KEYWORD: sprintf(temp, "<caractere> "); break;
            case T_TEXTO_KEYWORD:     sprintf(temp, "<texto> "); break;
            case T_VAZIO_KEYWORD:     sprintf(temp, "<vazio> "); break;
            case T_IMPRIMA_KEYWORD:   sprintf(temp, "<imprima> "); break;
            case T_RECEBA_KEYWORD:    sprintf(temp, "<receba> "); break;
            case T_E_KEYWORD:         sprintf(temp, "<e> "); break;
            case T_OU_KEYWORD:        sprintf(temp, "<ou> "); break;
            case T_NAO_KEYWORD:       sprintf(temp, "<nao> "); break;
            case T_FATO_KEYWORD:      sprintf(temp, "<fato> "); break;
            case T_SERPENTE_KEYWORD:  sprintf(temp, "<serpente> "); break;

            // Identificadores e Literais
            case T_ID:                sprintf(temp, "<id, %d> ", yylval); break;
            case T_INTEIRO_LITERAL:   sprintf(temp, "<inteiro, %d> ", yylval); break;
            case T_QUEBRADO_LITERAL:  sprintf(temp, "<quebrado, %s> ", yyltext); break;
            case T_TEXTO_LITERAL:     sprintf(temp, "<texto, %s> ", yyltext); break;
            case T_CARACTERE_LITERAL: sprintf(temp, "<caractere, %s> ", yyltext); break;
            case T_FATO_LITERAL:      sprintf(temp, "<fato, %s> ", yyltext); break;

            // Operadores e separadores
            case T_OP_IGUALDADE:      sprintf(temp, "<==> "); break;
            case T_OP_DIFERENTE:      sprintf(temp, "<!=> "); break;
            case T_OP_MENOR:          sprintf(temp, "<<> "); break;
            case T_OP_MAIOR:          sprintf(temp, "<>> "); break;
            case T_OP_MENOR_IGUAL:    sprintf(temp, "<<= > "); break;
            case T_OP_MAIOR_IGUAL:    sprintf(temp, "<>= > "); break;
            case T_OP_SOMA:           sprintf(temp, "<+> "); break;
            case T_OP_SUB:            sprintf(temp, "<-> "); break;
            case T_OP_MULT:           sprintf(temp, "<*> "); break;
            case T_OP_DIV:            sprintf(temp, "</> "); break;
            case T_OP_ATRIBUICAO:     sprintf(temp, "<=> "); break;

            case T_PONTO_VIRGULA:     sprintf(temp, "<;>\n"); break;
            case T_VIRGULA:           sprintf(temp, "<,> "); break;
            case T_PARENTESES_ESQ:    sprintf(temp, "<(> "); break;
            case T_PARENTESES_DIR:    sprintf(temp, "<)> "); break;
            case T_CHAVES_ESQ:        sprintf(temp, "<{> "); break;
            case T_CHAVES_DIR:        sprintf(temp, "<}> "); break;

             case T_ERRO:
                // A mensagem de erro já foi impressa para stderr
                break;
            default:
                // Este caso não deve ocorrer se todos os tokens forem tratados
                printf("Token não reconhecido no main: %d\n", token_id);
                break;
        }

        strcat(output_buffer, temp); // Adiciona temp em output_buffer
    }

    // Quando EOF, imprime tudo
    printf("Análise Léxica:\n");
    printf("%s\n", output_buffer);

    printf("\nTabela de Símbolos:\n");
    printf("Posição | Identificador\n");

    for (int i = 0; i < symbol_count; i++) {
        printf("[%d] %s\n", i, symbol_table[i]);
    }

    for (int i = 0; i < symbol_count; i++) {
        free(symbol_table[i]);
    }

    if (yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}
