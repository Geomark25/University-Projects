%{
    #include "lambdalib.h"
    #include "cgen.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <errno.h>

    int yylex(void);
    extern int line_num;

    char *output = NULL;

    extern FILE* yyin;
    FILE *outfile = NULL;
    char *parseExpression(char *, char *, char *);
    int is_comp_variable = 0;
    int is_comp_function = 0;
    char **comp_functions = NULL;
    char **comp_function_names = NULL;
    char *func = NULL;
    char *id = NULL;
    int comp_function_num = 0;
    int comp_function_names_num = 0;
    char **comp_variable = NULL;
    int comp_variable_count = 0;

        
    void process_file(FILE *in, const char *input_name, const char *def);
    void save_comp_variable(const char *name, const char *type);
    void save_comp_array(const char *name, const char *type);
    void append_function(const char *str);
    void append_function_name(const char *str);

%}

%union{
    char *string;
}

/* RESERVED KEYWORDS */
%token KEYWORD_integer
%token KEYWORD_scalar
%token KEYWORD_str
%token KEYWORD_bool
%token KEYWORD_True
%token KEYWORD_False
%token KEYWORD_const
%token KEYWORD_if
%token KEYWORD_else
%token KEYWORD_endif
%token KEYWORD_for
%token KEYWORD_in
%token KEYWORD_endfor
%token KEYWORD_while
%token KEYWORD_endwhile
%token KEYWORD_break
%token KEYWORD_continue
%token KEYWORD_def
%token KEYWORD_enddef
%token KEYWORD_main
%token KEYWORD_return
%token KEYWORD_comp
%token KEYWORD_endcomp
%token KEYWORD_of

%token <string> token_IDENTIFIER
%token <string> token_INTEGER
%token <string> token_FLOAT
%token <string> token_STRING

%token ';'
%token arrow
%token '#'
%token ':'
%token ','

%right ASSIGN ADD_ASSIGN SUB_ASSIGN MULT_ASSIGN DIV_ASSIGN MOD_ASSIGN WAL_ASSIGN
%left OP_OR
%left OP_AND
%right OP_NOT
%nonassoc EQUALS_OP NOT_EQUALS_OP
%nonassoc LESS_OP LESS_EQUAL_OP MORE_OP MORE_EQUAL_OP
%left '+' '-'
%left '*' '/' '%'
%right pow_op
%left '.' '(' ')' '[' ']'


%start compiler
%type <string> compiler
%type <string> lib_init
%type <string> main_func
%type <string> declaration_body
%type <string> declaration_template
%type <string> comp_declaration
%type <string> comp_function_declaration
%type <string> comp_variables
%type <string> const_declaration
%type <string> variable_declaration
%type <string> basic_var
%type <string> variable_names
%type <string> array_names
%type <string> function_declaration
%type <string> emp_func_body
%type <string> function_body
%type <string> function_arguments
%type <string> statemets
%type <string> emp_comp_body
%type <string> comp_body
%type <string> comp_variable_declaration
%type <string> comp_variable_identifier
%type <string> comp_array_variable
%type <string> parameters
%type <string> comp_var

%type <string> function_statement
%type <string> if_statement
%type <string> for_statement
%type <string> return_statement
%type <string> arrays
%type <string> block

%type <string> assign_expression
%type <string> arithmetic
%type <string> relational
%type <string> identifier
%type <string> expression
%type <string> comp_expression

%type <string> fin_statement


%%
/* Main and program initialization */
compiler:
    lib_init    {$$ = template("#include <stdio.h>\n"
                               "#include <stdlib.h>\n"
                               "#include \"lambdalib.h\"\n\n%s", $1); output = template("#include <stdio.h>\n"
                               "#include <stdlib.h>\n"
                               "#include \"lambdalib.h\"\n\n%s", $1);}
;

lib_init:
    main_func                       {$$ = $1;}
|   declaration_body main_func      {$$ = template("%s\n%s", $1, $2);}

/* Main() */
main_func:
    KEYWORD_def KEYWORD_main '(' ')' ':' function_body KEYWORD_enddef ';' {$$ = template("\nint main() {\n\t%s\nreturn 0;\n}", $6);}
;

/* Declarations */
declaration_body:
    declaration_template                     {$$ = $1;}
|   declaration_body declaration_template    {$$ = template("%s\n%s", $1, $2);}
;

declaration_template:
    comp_declaration
|   const_declaration
|   variable_declaration
|   function_declaration
;

/* Comp */
comp_declaration:
    KEYWORD_comp token_IDENTIFIER ':' emp_comp_body KEYWORD_endcomp ';' {
        char *functions = malloc(1);
        functions[0] = '\0';
        for (int i = 0; i < comp_function_num; i++){
            functions = (char *)realloc(functions, strlen(functions) + strlen(comp_functions[i]) + 1);
            strcat(functions, comp_functions[i]);
        }
        comp_function_num = 0;

        char *names = malloc(1);
        names[0] = '\0';
        for (int i = 0; i < comp_function_names_num; i++){
            names = (char*)realloc(names, strlen(names) + strlen(comp_function_names[i]) + 3);
            strcat(names, comp_function_names[i]);
            if(i != comp_function_names_num -1 || ((i != comp_function_names_num) && (comp_variable_count != 0))){
                strcat(names, ", ");
            }
        }
        comp_function_names_num = 0;
        for(int i = 0; i < comp_variable_count; i++){
            names = (char *)realloc(names, strlen(names) + strlen(comp_variable[i]) + 1);
            strcat(names, comp_variable[i]);
            if(i != comp_variable_count -1){
                strcat(names, ", ");
            }
        }

        comp_variable_count = 0;

        $$ = template("\n#define SELF struct %s *self\n\n"
                        "typedef struct %s {\n%s\n} %s; \n"
                        "\n%s\n const %s ctor_%s = { %s }; \n"
                        "#undef SELF\n\n", $2, $2, $4, $2, functions, $2, $2, names);

        free(functions);
        free(names);
    }
;

emp_comp_body:
    %empty   {$$ = "";}
|   comp_body
;

comp_body:
    comp_variable_declaration
|   comp_variable_declaration comp_body {$$ = template("%s\n%s", $1, $2);}
|   comp_function_declaration
|   comp_function_declaration comp_body {$$ = template("%s\n%s", $1, $2);}
;

comp_variables:
    variable_names ':' token_IDENTIFIER ';' {
        sstream S;
        ssopen(&S);

        char *var_names = strdup($1);
        char *token = strtok(var_names, ",");

        while (token) {
            // Trim leading spaces
            while (*token == ' ') token++;

            char *assign = template("%s %s = ctor_%s;\n", $3, token, $3);
            fputs(assign, S.stream);
            free(assign);

            token = strtok(NULL, ",");
        }

        free(var_names);
        $$ = strdup(ssvalue(&S));
        ssclose(&S);
    }
;

comp_variable_declaration:
    comp_variable_identifier ':' comp_var ';' {$$ = template("%s %s;", $3, $1); save_comp_variable($1, $3);}
|   comp_array_variable ':' comp_var ';'      {$$ = template("%s %s;", $3, $1); save_comp_array($1, $3);}
;

comp_variable_identifier:
    '#' token_IDENTIFIER                                {$$ = $2;}
|   '#' token_IDENTIFIER ',' comp_variable_identifier   {$$ = template("%s, %s", $2, $4);}
;

comp_array_variable:
    '#' token_IDENTIFIER '[' token_INTEGER ']'                          {$$ = template("%s[%s]", $2, $4);}
|   comp_array_variable ',' '#' token_IDENTIFIER '[' token_INTEGER ']'  {$$ = template("%s, %s[%s], $1, $4, $6");}
;

comp_function_declaration:
      KEYWORD_def token_IDENTIFIER '(' parameters ')' ':' function_body KEYWORD_enddef ';'
    {
        // Build function definition
        char *func_code = template(
            "\nvoid %s(SELF%s%s) {\n\t%s\n}\n",
            $2,
            (strcmp($4, "") ? ", " : ""),
            $4,
            $7
        );

        comp_functions = realloc(comp_functions, sizeof(char *) * (comp_function_num + 1));
        comp_functions[comp_function_num++] = func_code;

        // Build function pointer assignment
        char *assign_code = template(".%s = %s", $2, $2);
        comp_function_names = realloc(comp_function_names, sizeof(char *) * (comp_function_names_num + 1));
        comp_function_names[comp_function_names_num++] = assign_code;

        // Set return value
        $$ = template("\tvoid (*%s)(SELF%s%s);", $2, (strcmp($4, "") ? ", " : ""), $4);
    }
|     KEYWORD_def token_IDENTIFIER '(' parameters ')' arrow comp_var ':' function_body KEYWORD_enddef ';'
    {
        char *func_code = template(
            "\n%s %s(SELF%s%s) {\n\t%s\n}\n",
            $7,
            $2,
            (strcmp($4, "") ? ", " : ""),
            $4,
            $9
        );

        comp_functions = realloc(comp_functions, sizeof(char *) * (comp_function_num + 1));
        comp_functions[comp_function_num++] = func_code;

        char *assign_code = template(".%s = %s", $2, $2);
        comp_function_names = realloc(comp_function_names, sizeof(char *) * (comp_function_names_num + 1));
        comp_function_names[comp_function_names_num++] = assign_code;

        // Set return value
        $$ = template("\t%s (*%s)(SELF%s%s);", $7, $2, (strcmp($4, "") ? ", " : ""), $4);
    }
;


comp_expression:
    expression '.' comp_rem expression {
        $$ = template("%s.%s", $1, $4);
        is_comp_variable = 0;
    }
;

comp_rem:
%empty{
    is_comp_variable = 1;
    is_comp_function = 1;
    }
;
/* Functions */
function_declaration:
    KEYWORD_def token_IDENTIFIER '(' parameters ')' ':' emp_func_body KEYWORD_enddef ';' {
        $$ = template("void %s(%s) {\n\t%s\n}\n", $2, $4, $7);
    }
|   KEYWORD_def token_IDENTIFIER '(' parameters ')' arrow comp_var ':' emp_func_body KEYWORD_enddef ';' {
        $$ = template("%s %s(%s) {\n\t%s\n}\n", $7, $2, $4, $9);
    }
;

emp_func_body:
    %empty          {$$ = "";}
|   function_body
;

function_body:
    declaration_template
|   comp_variables
|   fin_statement
|   function_body fin_statement             {$$ = template("%s\n\t%s", $1, $2);}
|   function_body declaration_template  {$$ = template("%s\n\t%s", $1, $2);}
|   function_body comp_variables        {$$ = template("%s\n\t%s", $1, $2);}
;

function_arguments:
    expression                          {$$ = template("%s", $1);}
|   expression ',' function_arguments   {$$ = template("%s, %s", $1, $3);}
;

parameters:
    %empty                                                {$$ = "";}
|   token_IDENTIFIER ':' comp_var                         {$$ = template("%s %s", $3, $1);}
|   token_IDENTIFIER ':' comp_var ',' parameters          {$$ = template("%s %s, %s", $3, $1, $5);}
|   token_IDENTIFIER '[' ']' ':' comp_var                 {$$ = template("%s *%s", $5, $1);}
|   token_IDENTIFIER '[' ']' ':' comp_var ',' parameters  {$$ = template("%s *%s, %s", $5, $1, $7);}
;

/* Variables */
variable_declaration:
    variable_names ':' basic_var ';'   {$$ = template("%s %s;", $3, $1);}
|   array_names ':' basic_var ';'      {$$ = template("%s %s;", $3, $1);}
;

variable_names:
    token_IDENTIFIER
|   variable_names ',' token_IDENTIFIER {$$ = template("%s, %s", $1, $3);}
;

array_names:
    token_IDENTIFIER '[' token_INTEGER']'                   {$$ = template("%s[%s]", $1, $3);}
|   array_names ',' token_IDENTIFIER '[' token_INTEGER']'   {$$ = template("%s, %s[%s]", $1, $3, $5);}


basic_var:
    KEYWORD_integer {$$ = template("int");}
|   KEYWORD_scalar  {$$ = template("double");}
|   KEYWORD_str     {$$ = template("StringType");}
|   KEYWORD_bool    {$$ = template("int");}
;

comp_var:
    basic_var
|   token_IDENTIFIER
;

/* Const declaration*/
const_declaration:
    KEYWORD_const variable_names ASSIGN token_INTEGER ':' comp_var ';' {$$ = template("const %s %s = %s;", $6, $2, $4);}
|   KEYWORD_const variable_names ASSIGN token_FLOAT ':' comp_var ';' {$$ = template("const %s %s = %s;", $6, $2, $4);}
|   KEYWORD_const variable_names ASSIGN token_STRING ':' comp_var ';' {$$ = template("const %s %s = %s;", $6, $2, $4);}
;

/* Statements */
statemets:
    assign_expression
|   if_statement
|   for_statement
|   KEYWORD_while '(' expression ')' ':' block KEYWORD_endwhile {$$ = template("while(%s) {\n\t\t%s\n\t}", $3, $6);}
|   KEYWORD_break                                              {$$ = "break";}
|   KEYWORD_continue                                           {$$ = "continue";}
|   expression                                                  {$$ = template("%s", $1);}
|   return_statement
|   arrays
;

fin_statement:
    ';'             {$$ = ";"; func = NULL;}
|    statemets ';'   {$$ = template("%s;", $1); func = NULL; id = NULL;}
;


if_statement:
    KEYWORD_if '(' expression ')' ':' block KEYWORD_endif                       {$$ = template("if (%s) {\n\t\t%s\n\t}", $3, $6);}
|   KEYWORD_if '(' expression ')' ':' block KEYWORD_else ':' block KEYWORD_endif    {$$ = template("if (%s) {\n\t\t%s\n\t} else {\n\t\t%s\n\t}", $3, $6, $9);}
;

for_statement:
    KEYWORD_for token_IDENTIFIER KEYWORD_in '[' expression ':' expression ']' ':' block KEYWORD_endfor                  {$$ = template("for (int %s = %s; %s < %s; %s++) {\n\t\t%s\n\t}", $2, $5, $2, $7, $2, $10);}
|   KEYWORD_for token_IDENTIFIER KEYWORD_in '[' expression ':' expression ':' expression ']' ':' block KEYWORD_endfor   {$$ = template("for (int %s = %s; %s < %s; %s = %s + %s) {\n\t\t%s\n\t}", $2, $5, $2, $7, $2, $2, $9, $12);}
;

return_statement:
    KEYWORD_return               {$$ = "return";}
|   KEYWORD_return expression   {$$ = template("return %s", $2);}
;

arrays:
    token_IDENTIFIER WAL_ASSIGN '[' expression KEYWORD_for token_IDENTIFIER ':' token_INTEGER ']' ':' comp_var{
        $$ = template("%s* %s = (%s*)malloc(%s*sizeof(%s));\n"
                      "\tfor(int %s=0; %s < %s; ++%s) {\n"
                      "\t\t%s[%s] = %s;\n\t}", $11, $1, $11, $8, $11, $6, $6, $8, $6, $1, $6, $4);
    }
|   token_IDENTIFIER WAL_ASSIGN '[' expression KEYWORD_for token_IDENTIFIER ':' comp_var KEYWORD_in token_IDENTIFIER KEYWORD_of token_INTEGER ']' ':' comp_var{
        $$ = template("%s* %s = (%s*)malloc(%s*sizeof(%s));\n"
                        "\tfor(int %s_i=0; %s_i < %s; ++%s_i) {\n"
                        "\t\t%s[%s_i] = %s;\n\t}", $15, $1, $15, $12, $15, $10, $10, $12, $10, $1, $10, parseExpression($4, $6, $10));
    }
;

function_statement:
    token_IDENTIFIER '(' ')' {
        if(id && is_comp_function){
            $$ = template("%s(&%s)", $1, id);
            id = NULL;
            is_comp_function = 0;
        }
        else if(is_comp_function){
            $$ = template("%s(&%s)", $1, func);
            func = NULL;
            is_comp_function = 0;
        }
        else{
            $$ = template("%s()", $1);
        }
    }
|   token_IDENTIFIER '(' function_arguments ')'{
        if(id && is_comp_function){
            $$ = template("%s(&%s, %s)", $1, id, $3);
            id = NULL;
            is_comp_function = 0;
        }
        if(is_comp_function){
            $$ = template("%s(&%s, %s)", $1, func, $3);
            is_comp_function = 0;
        }
        else{
            $$ = template("%s(%s)", $1, $3);
        }
    }
;

block:
    fin_statement                   {$$ = $1;}
|   declaration_template        {$$ = $1;}
|   block fin_statement             {$$ = template("%s\n%s", $1, $2);}
|   block declaration_template  {$$ = template("%s\n%s", $1, $2);}
;

assign_expression:
    expression ASSIGN  rem expression        {$$ = template("%s = %s", $1, $4);}
|   expression ADD_ASSIGN expression    {$$ = template("%s += %s", $1, $3);}
|   expression SUB_ASSIGN expression    {$$ = template("%s -= %s", $1, $3);}
|   expression MULT_ASSIGN expression   {$$ = template("%s *= %s", $1, $3);}
|   expression DIV_ASSIGN expression    {$$ = template("%s /= %s", $1, $3);}
|   expression MOD_ASSIGN expression    {$$ = template("%s %= %s", $1, $3);}
;

rem:
%empty
{
    id = NULL;
    func = NULL;
    is_comp_function = 0;
}
;

expression:
    '(' expression ')'              {$$ = template("(%s)", $2);}
|   expression OP_AND expression    {$$ = template("%s && %s", $1, $3);}
|   expression OP_OR expression     {$$ = template("%s || %s", $1, $3);}
|   OP_NOT expression               {$$ = template("!%s", $2);}
|   KEYWORD_True                    {$$ = "1";}
|   KEYWORD_False                   {$$ = "0";}
|   token_STRING                    {$$ = $1;}
|   arithmetic                      {$$ = $1;}
|   relational                      {$$ = $1;}
|   identifier                      {$$ = $1;}
|   function_statement              {$$ = $1;}
|   comp_expression                 {$$ = $1;}
;


arithmetic:
    token_INTEGER
|   token_FLOAT
|   '+' expression              {$$ = template("+%s", $2);}
|   '-' expression              {$$ = template("-%s", $2);}
|   expression '+' expression   {$$ = template("%s + %s", $1, $3);}
|   expression '-' expression   {$$ = template("%s - %s", $1, $3);}
|   expression '*' expression   {$$ = template("%s * %s", $1, $3);}
|   expression '/' expression   {$$ = template("%s / %s", $1, $3);}
|   expression '%' expression   {$$ = template("%s %% %s", $1, $3);}
|   expression pow_op expression   {$$ = template("pow(%s, %s)", $1, $3);}
;

relational:
    expression EQUALS_OP expression     {$$ = template("%s == %s", $1, $3);}
|   expression NOT_EQUALS_OP expression {$$ = template("%s != %s", $1, $3);}
|   expression LESS_OP expression       {$$ = template("%s < %s", $1, $3);}
|   expression LESS_EQUAL_OP expression {$$ = template("%s <= %s", $1, $3);}
|   expression MORE_OP expression       {$$ = template("%s > %s", $1, $3);}
|   expression MORE_EQUAL_OP expression {$$ = template("%s >= %s", $1, $3);}
;

identifier:
    token_IDENTIFIER                            {
        func = func ? func : $1;        
        }
|   token_IDENTIFIER '[' token_IDENTIFIER ']'   {$$ = template("%s[%s]", $1, $3);}
|   token_IDENTIFIER '[' token_INTEGER ']'      {$$ = template("%s[%s]", $1, $3);}
|   '#' token_IDENTIFIER{
        const char* format = is_comp_variable ? "%s" : "self->%s";
        func = template(format, $2);
        is_comp_variable = 0;
        $$ = template(format, $2);
        id = template(format, $2);
    }
|   '#' token_IDENTIFIER '[' identifier ']' {
        const char* format = is_comp_variable ? "%s[%s]" : "self->%s[%s]";
        is_comp_variable = 0;
        func = template(format, $2, $4);
        $$ = template(format, $2, $4);
        id = template(format, $2, $4);
    }
;

%%
int main(int argc, char *argv[]){
    if (argc > 1){
        for (int i = 1; i < argc; i++){
            const char *input_filename = argv[i];
            FILE *in = fopen(input_filename, "r");
            if(!in){
                fprintf(stderr, "Could not open %s\n", input_filename);
                continue;
            }
            process_file(in, input_filename, NULL);
        }
    }
    else{
        process_file(stdin, NULL, "output.c");
    }

    return 0;
}

char *parseExpression(char *expression, char *identifier, char *array){    
    char *modifiedExpression = NULL;

    char *temp = (char *)malloc((4 + 2*strlen(array)) * sizeof(char));
    sprintf(temp, "%s[%s_i]", array, array);

    // Calculate the length of the new expression
    int newLength = strlen(expression);
    int idLength = strlen(identifier);
    int tempLength = strlen(temp);
    int count = 0;

    // Find how many times the identifier appears in the expression
    char *pos = expression;
    while ((pos = strstr(pos, identifier)) != NULL) {
        count++;
        pos += idLength;
    }

    // Allocate memory for the new expression
    newLength = newLength + count * (tempLength - idLength);
    modifiedExpression = (char *)malloc((newLength + 1) * sizeof(char));

    // Replace all occurrences of identifier with temp
    char *currentPos = expression;
    char *nextPos;
    char *resultPos = modifiedExpression;

    while ((nextPos = strstr(currentPos, identifier)) != NULL) {
        // Copy the part before the identifier
        int len = nextPos - currentPos;
        strncpy(resultPos, currentPos, len);
        resultPos += len;

        // Copy the temp instead of the identifier
        strcpy(resultPos, temp);
        resultPos += tempLength;

        // Move past the identifier in the original expression
        currentPos = nextPos + idLength;
    }

    // Copy the remaining part of the original expression
    strcpy(resultPos, currentPos);

    free(temp);
    return modifiedExpression;
}

void process_file(FILE *in, const char *input_name, const char *def){
        char output_filename[256];

        if(input_name){
            const char *dot = strrchr(input_name, '.');
            if(dot && strcmp(dot, ".la") == 0) {
                size_t len = (size_t)(dot - input_name);
                snprintf(output_filename, sizeof(output_filename), "%.*s.c", (int)len, input_name);
            }
            else{
                fprintf(stderr, "File %s is not valid for lambda compiling.\n", input_name);
                return;
            }
        }
        else{
            strncpy(output_filename, def, sizeof(output_filename));
        }

        outfile = fopen(output_filename, "w");
        if(!outfile){
            fprintf(stderr, "Error: could not open output file %s: %s \n", output_filename, strerror(errno));
            return;
        }

        yyin = in;
        if(yyparse() == 0){
            printf("Successfully compiled into %s\n", output_filename);
            fputs(output, outfile);
        }
        else{
            fprintf(stderr, "Parser error in %s\n", input_name ? input_name : "stdin");
        }

        fclose(outfile);
        if (in != stdin) fclose(in);
    }

void save_comp_variable(const char *name, const char *type) {

    if(strcmp(type, "int") == 0 || strcmp(type, "StringType") == 0 || strcmp(type, "double") == 0){
        return;
    }

    char *assign_code = template(".%s = ctor_%s", name, type);
    comp_variable = realloc(comp_variable, sizeof(char *) * (comp_variable_count + 1));
    comp_variable[comp_variable_count++] = strdup(assign_code);
}

void save_comp_array(const char *name, const char *type){

    if(strcmp(type, "int") == 0 || strcmp(type, "StringType") == 0 || strcmp(type, "double") == 0){
        return;
    }

    char *start = strchr(name, '[');
    char *end = strchr(name, ']');

    *start = '\0';
    *end = '\0';

    char *assign_code = template(".%s = {[0 ... %s - 1] = ctor_%s}", name, start + 1, type);
    comp_variable = realloc(comp_variable, sizeof(char *) * (comp_variable_count + 1));
    comp_variable[comp_variable_count++] = strdup(assign_code);
}