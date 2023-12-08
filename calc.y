%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
extern int yylex();
extern void yyerror(const char* s);

FILE* input_file;  // Variable para el archivo que leo
extern FILE* yyin;  // Aquí declaro la variable global de Bison para la entrada
%}

%token NUM
%token SQRT
%left '+' '-'
%left '*' '/'
%left UMINUS
%right '^'
%left SHIFT
%left MOD
%left SHIFT_LEFT  /* Nuevo token para desplazamiento a la izquierda */
%left SHIFT_RIGHT /* Nuevo token para desplazamiento a la derecha */

%%

stmt:   expr '\n'      { printf("%d\n", $1); }
    | stmt expr '\n'   { /* Aquí evito imprimir el resultado intermedio */ }
    ;

expr:   expr '+' term   { $$ = $1 + $3; printf("%d + %d = %d\n", $1, $3, $$); }
    | expr '-' term    { $$ = $1 - $3; printf("%d - %d = %d\n", $1, $3, $$); }
    | expr '*' term    { $$ = $1 * $3; printf("%d * %d = %d\n", $1, $3, $$); }
    | expr '/' term    {
                            if ($3 != 0) {
                                $$ = $1 / $3;
                                printf("%d / %d = %d\n", $1, $3, $$);
                            } else {
                                fprintf(stderr, "Error: No se puede dividir por 0\n");
                                exit(EXIT_FAILURE);
                            }
                        }
    | expr '%' term    { $$ = $1 % $3; printf("%d %% %d = %d\n", $1, $3, $$); }
    | expr '^' term    { $$ = pow($1, $3); printf("%d ^ %d = %d\n", $1, $3, $$); }
    | SQRT '(' expr ')' {
                            if ($3 >= 0) {
                                $$ = sqrt($3);
                                printf("sqrt(%d) = %d\n", $3, $$);
                            } else {
                                fprintf(stderr, "Error: No se puede sacar raiz cuadrada con numero negativo\n");
                                exit(EXIT_FAILURE);
                            }
                        }
    | expr SHIFT_LEFT term   { $$ = $1 << $3; printf("%d << %d = %d\n", $1, $3, $$); }
    | expr SHIFT_RIGHT term  { $$ = $1 >> $3; printf("%d >> %d = %d\n", $1, $3, $$); }
    | '|' expr '|'      { $$ = fabs($2); printf("|%d| = %d\n", $2, $$); }
    | term             { $$ = $1; }
    ;

term:   term '*' factor { $$ = $1 * $3; printf("%d * %d = %d\n", $1, $3, $$); }
    | term '/' factor   {
                            if ($3 != 0) {
                                $$ = $1 / $3;
                                printf("%d / %d = %d\n", $1, $3, $$);
                            } else {
                                fprintf(stderr, "Error: No se puede dividir por 0\n");
                                exit(EXIT_FAILURE);
                            }
                        }
    | term MOD factor   {
                            if ($3 != 0) {
                                $$ = $1 % $3;
                                printf("%d %% %d = %d\n", $1, $3, $$);
                            } else {
                                fprintf(stderr, "Error: division por cero (módulo)\n");
                                exit(EXIT_FAILURE);
                            }
                        }
    | factor            { $$ = $1; }
    ;

factor:   factor '^' unary { $$ = pow($1, $3); printf("%d ^ %d = %d\n", $1, $3, $$); }
    | unary               { $$ = $1; }
    ;

unary:   '-' atom %prec UMINUS { $$ = -$2; printf("-%d = %d\n", $2, $$); }
    | atom                      { $$ = $1; }
    ;

atom:   NUM                { $$ = $1; }
    | SQRT '(' expr ')'   {
                            if ($3 >= 0) {
                                $$ = sqrt($3);
                                printf("sqrt(%d) = %d\n", $3, $$);
                            } else {
                                fprintf(stderr, "Error: No se puede sacar raiz cuadrada de un numero negativo\n");
                                exit(EXIT_FAILURE);
                            }
                        }
    | '|' expr '|'         { $$ = fabs($2); printf("|%d| = %d\n", $2, $$); }
    | '(' expr ')'        { $$ = $2; }
    ;

%%

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s archivo_de_entrada\n", argv[0]);
        return EXIT_FAILURE;
    }

    input_file = fopen(argv[1], "r");
    if (!input_file) {
        perror("Error al abrir el archivo de entrada");
        return EXIT_FAILURE;
    }

    yyin = input_file;  // Aquí asigno el puntero del archivo de entrada a yyin

    yyparse();

    fclose(input_file);
    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "%s\n", s);
}
