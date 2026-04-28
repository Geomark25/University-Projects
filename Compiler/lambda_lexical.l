%{
#include <stdio.h>
#include <stdlib.h>
#include "cgen.h"
#include "lambdaParser.tab.h"

int line_num = 1;
char **macro_val = NULL;
char **macro_list = NULL;
int macro_count = 0;
void saveMacro(char ***macros);
void freeMacrosList(char ***ids, char ***values);
void print_token(const char* token, const char* text);
%}

%option noyywrap

/*Decleration of basic components*/
DEC_DIGIT       [0-9]
NAT_DIGIT       [1-9]
LETTER          [a-zA-Z_]

/*Decleration of Lectical units*/
IDENTIFIER      {LETTER}({LETTER}|{DEC_DIGIT})*
INTEGER         0|{NAT_DIGIT}{DEC_DIGIT}*
SCI_NOTATION    ([eE][+-]?{DEC_DIGIT}+)
FLOAT           {INTEGER}\.{DEC_DIGIT}+({SCI_NOTATION})?

NEW_LINE        \n
WHITESPACE      [ \t\r]
CONST_STRING    \"[^\n]*\"

COMMENT         "--"[^\n]*

%x defmacro

%%

"@defmacro"                 {macro_count++; print_token("MACRO", yytext); BEGIN(defmacro); }
<defmacro>{WHITESPACE}      {}
<defmacro>{IDENTIFIER}      {saveMacro(&macro_list);}
<defmacro>{CONST_STRING}    {saveMacro(&macro_val);}
<defmacro>{INTEGER}|{FLOAT} {saveMacro(&macro_val);}
<defmacro>{NEW_LINE}        {line_num++; BEGIN(INITIAL);}

{COMMENT}       {/* Do nothing */}

"integer"       {print_token("KEYWORD_integer", yytext); return KEYWORD_integer;}
"scalar"        {print_token("KEYWORD_scalar", yytext); return KEYWORD_scalar;}
"str"           {print_token("KEYWORD_str", yytext); return KEYWORD_str;}
"bool"          {print_token("KEYWORD_bool", yytext); return KEYWORD_bool;}
"True"          {print_token("KEYWORD_True", yytext); return KEYWORD_True;}
"False"         {print_token("KEYWORD_False", yytext); return KEYWORD_False;}
"const"         {print_token("KEYWORD_const", yytext); return KEYWORD_const;}
"if"            {print_token("KEYWORD_if", yytext); return KEYWORD_if;}
"else"          {print_token("KEYWORD_else", yytext); return KEYWORD_else;}
"endif"         {print_token("KEYWORD_endif", yytext); return KEYWORD_endif;}
"for"           {print_token("KEYWORD_for", yytext); return KEYWORD_for;}
"in"            {print_token("KEYWORD_in", yytext); return KEYWORD_in;}
"endfor"        {print_token("KEYWORD_endfor", yytext); return KEYWORD_endfor;}
"while"         {print_token("KEYWORD_while", yytext); return KEYWORD_while;}
"endwhile"      {print_token("KEYWORD_endwhile", yytext); return KEYWORD_endwhile;}
"break"         {print_token("KEYWORD_break", yytext); return KEYWORD_break;}
"continue"      {print_token("KEYWORD_continue", yytext); return KEYWORD_continue;}
"def"           {print_token("KEYWORD_def", yytext); return KEYWORD_def;}
"enddef"        {print_token("KEYWORD_enddef", yytext); return KEYWORD_enddef;}
"main"          {print_token("KEYWORD_main", yytext); return KEYWORD_main;}
"return"        {print_token("KEYWORD_return", yytext); return KEYWORD_return;}
"comp"          {print_token("KEYWORD_comp", yytext); return KEYWORD_comp;}
"endcomp"       {print_token("KEYWORD_endcomp", yytext); return KEYWORD_endcomp;}
"of"            {print_token("KEYWORD_of", yytext); return KEYWORD_of;}

"not"           {print_token("OPERATOR_not", yytext); return OP_NOT;}
"and"           {print_token("OPERATOR_and", yytext); return OP_AND;}
"or"            {print_token("OPERATOR_or", yytext); return OP_OR;}

"+"             {print_token("PLUS_OP", yytext); return '+';}
"-"             {print_token("MINUS_OP", yytext); return '-';}
"*"             {print_token("MULTIPLIER_OP", yytext); return '*';}
"/"             {print_token("DIVIDER_OP", yytext); return '/';}
"%"             {print_token("MODULO_OP", yytext); return '%';}
"**"            {print_token("POWER_OP", yytext); return pow_op;}
"=="            {print_token("EQUALS_OP", yytext); return EQUALS_OP;}
"!="            {print_token("NOT_EQUALS_OP", yytext); return NOT_EQUALS_OP;}
"<"             {print_token("LESS_OP", yytext); return LESS_OP;}
"<="            {print_token("LESS_EQUAL_OP", yytext); return LESS_EQUAL_OP;}
">"             {print_token("MORE_OP", yytext); return MORE_OP;}
">="            {print_token("MORE_EQUAL_OP", yytext); return MORE_EQUAL_OP;}

"="             {print_token("ASSIGN_OP", yytext); return ASSIGN;}
"+="            {print_token("ADDITION_ASSIGN_OP", yytext); return ADD_ASSIGN;}
"-="            {print_token("SUBTRACTION_ASSIGN_OP", yytext); return SUB_ASSIGN;}
"*="            {print_token("MULTIPLICATION_ASSIGN_OP", yytext); return MULT_ASSIGN;}
"/="            {print_token("DIVISION_ASSIGN_OP", yytext); return DIV_ASSIGN;}
"%="            {print_token("MODULO_ASSIGN_OP", yytext); return MOD_ASSIGN;}
":="            {print_token("WALRUS_OP", yytext); return WAL_ASSIGN;}

";"             {print_token("SEMICOLON", yytext); return ';';}
"("             {print_token("LEFT_PARENTHESIS", yytext); return '(';}
")"             {print_token("RIGHT_PARENTHESIS", yytext); return ')';}
","             {print_token("COMMA", yytext); return ',';}
"["             {print_token("LEFT_BRACKET", yytext); return '[';}
"]"             {print_token("RIGHT_BRACKET", yytext); return ']';}
":"             {print_token("COLON", yytext); return ':';}
"."             {print_token("DOT", yytext); return '.';}

"#"             {print_token("HASHTAG", yytext); return '#';}
"->"            {print_token("ARROW", yytext); return arrow;}

{CONST_STRING}  {print_token("CONST_STRING", yytext); yylval.string = strdup(yytext); return token_STRING;}
{FLOAT}         {print_token("FLOAT", yytext); yylval.string = strdup(yytext); return token_FLOAT;}
{INTEGER}       {print_token("INTEGER", yytext); yylval.string = strdup(yytext); return token_INTEGER;}
{IDENTIFIER}    {
    for(int i = 0; i < macro_count; i++){
        if(!strcmp(yytext, macro_list[i])){
            yylval.string = strdup(macro_val[i]);
            print_token("CONST_STRING", yytext);
            return token_STRING;
        }
    }

    print_token("IDENTIFIER", yytext); yylval.string = strdup(yytext);
    return token_IDENTIFIER;
    }

[ \t\r]+        {/* Skip whitespace */}
\n              {line_num++;}

.               {
    fprintf(stderr, "Unrecognized token %s in line %d\n", yytext, line_num);
    return 1;
}

<<EOF>>         {freeMacrosList(&macro_val, &macro_list); return EOF;}
%%

void saveMacro(char ***macros){
    char **temp = (char **)realloc(*macros,  macro_count * sizeof(char *));

    *macros = temp;

    /* assign to 0 element first */
    (*macros)[macro_count - 1] = strdup(yytext);
}

/* free occupied space*/
void freeMacrosList(char ***ids, char ***values){
    for(int i=0; i < macro_count; i++){
        free((*ids)[i]);
        free((*values)[i]);
    }
    *ids = NULL;
    *values = NULL;
}

void print_token(const char* token, const char* text){
    //printf("token \'%s\':  %s\n", token, text);
}