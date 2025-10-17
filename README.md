# Lexical Analyzer - Compilers - UFBA

This project implements a **lexical analyzer** for a simplified programming language, developed as part of the **MATA61 - Compilers** course at the **Federal University of Bahia (UFBA)**.

## To-do List

### Tipagem e Variáveis (Tipagem Estática)

- [ ] Definir a palavra-chave para declaração de variáveis numéricas **inteiras**.
- [ ] Definir a palavra-chave para declaração de variáveis de **ponto flutuante**.
- [ ] Definir a sintaxe para declaração e inicialização de **vetores** do tipo numérico.
- [ ] Definir a palavra-chave para declaração de variáveis **booleanas**.

### Acessos e Atribuições (Expressões Aritméticas)

- [ ] Implementar a sintaxe de **atribuição** simples (ex: `x = 20;`).
- [ ] Implementar **expressões aritméticas** com números pré-definidos na atribuição (ex: `y = 1.5 + 2.0;`).
- [ ] Implementar expressões aritméticas com **variáveis** na atribuição (ex: `z = x * y;`).
- [ ] Implementar a sintaxe para **acesso** individual a elementos do vetor (ex: `arr[0]`).
- [ ] Implementar a sintaxe para **atribuição** individual a elementos do vetor (ex: `arr[i] = x - 5;`).
- [ ] Implementar suporte para **chamadas de função** dentro de expressões aritméticas (ex: `resultado = funcao_soma(a, b);`).

### Estruturas de Controle

- [ ] Definir a sintaxe para **operações de comparação** (igual, diferente, maior, menor, etc.).
- [ ] Implementar o desvio **condicional simples** (o `if` básico).
- [ ] Implementar o desvio **condicional composto** (o `if-else`).
- [ ] Implementar o comando de **repetição** (o `while` ou `for` com condição de comparação).

### Funções (Com Retorno Explícito)

- [ ] Definir a sintaxe para **criação de funções** (o tipo de retorno deve ser o primeiro).
    - [ ] Definir o tipo de retorno **inteiro** (ex: `int func(...)`).
    - [ ] Definir o tipo de retorno **ponto flutuante** (ex: `float func(...)`).
    - [ ] Definir o tipo de retorno
- [ ] Definir sintaxe para **print** e **input**.

### Tokens
- [ ] Impressão correta no formato de analisador léxico.
- [ ] Impressão somente após o usuário definir.


## Dictionary

- **int** = **inteiro**.
- **float** = **decimal**.
- **string** = **palavra**.
- **char** = **caractere**.
- **bool** = ----.
- **vetores** = ----.
- **void** = **vazio**.

- **if** = **se**.
- **else** = **senao**.
- **while** = **enquanto**.
- **return** = **retorno**.
- **print** = **escreva**.
- **input** = **receba**.