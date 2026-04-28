SOURCES := $(wildcard *.la)


all:
	bison -d -v -r all lambdaParser.y -Wcounterexamples
	flex lambda_lexical.l
	gcc -o mycompiler lex.yy.c lambdaParser.tab.c cgen.c -lfl

remake: remC
	rm -rf lex.yy.c lambdaParser.tab.c lambdaParser.tab.h mycompiler
	bison -d -v -r all lambdaParser.y -Wcounterexamples
	flex lambda_lexical.l
	gcc -o mycompiler lex.yy.c lambdaParser.tab.c cgen.c -lfl
	@echo "Successfully created Lambda Compiler \n\n"

full: remake exec

exec:
	@for src in $(SOURCES); do \
		./mycompiler "$$src"; \
	done

remC:
	rm -f $(filter-out lambdaParser.tab.c cgen.c lex.yy.c, $(wildcard *.c))

clean:
	rm -rf lambdaParser.tab.c lambdaParser.tab.h mycompiler lex.yy.c lambdaParser.output