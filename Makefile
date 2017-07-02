CC = gcc
LEX = flex
YACC = bison
TESTER = sh tester.sh

okreadme: okreadme_parser.o okreadme_scanner.o okreadme.o okreadme_type.o
	$(CC) -o $@ okreadme_parser.o okreadme_scanner.o okreadme.o okreadme_type.o -ly -ll

okreadme.o: okreadme.c okreadme_lib.h
	$(CC) -c -o $@ okreadme.c

okreadme_parser.o: okreadme_parser.y okreadme_lib.h okreadme_type.h
	$(YACC) -d okreadme_parser.y
	$(CC) -c -o $@ okreadme_parser.tab.c

okreadme_scanner.o: okreadme_scanner.l okreadme_parser.o
	$(LEX) okreadme_scanner.l
	$(CC) -c -o $@ lex.yy.c

okreadme_type.o: okreadme_type.c okreadme_type.h
	$(CC) -c -o $@ okreadme_type.c

readme:
	./okreadme > README.md

# test:
# 	@$(TESTER)

test: okreadme
	okreadme test.ok.md
	
clean:
	rm -f *.o

