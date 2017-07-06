
PREFIX?=/usr/local
INSTALL_BIN=$(PREFIX)/bin

CC = gcc
LEX = flex
YACC = bison

PREFIX?=/usr/local
INSTALL_BIN=$(PREFIX)/bin

OKR = okreadme
OKR_SCANNER = okreadme_scanner.o
OKR_PARSER = okreadme_parser.o
OKR_TYPE = okreadme_type.o

$(OKR): $(OKR_PARSER) $(OKR_SCANNER) $(OKR_TYPE) okreadme.c okreadme_lib.h
	$(CC) -o $@ okreadme.c $(OKR_PARSER) $(OKR_SCANNER) $(OKR_TYPE) -ly -ll

$(OKR_PARSER): okreadme_parser.y okreadme_lib.h okreadme_type.h
	$(YACC) -d okreadme_parser.y
	$(CC) -c -o $@ okreadme_parser.tab.c

$(OKR_SCANNER): okreadme_scanner.l $(OKR_PARSER)
	$(LEX) okreadme_scanner.l
	$(CC) -c -o $@ lex.yy.c

$(OKR_TYPE): okreadme_type.c okreadme_type.h
	$(CC) -c -o $@ okreadme_type.c

test: okreadme
	@(cd ..; sh tester.sh)

.PHONY = test

clean:
	rm -f *.o

.PHONY = clean

install: $(OKR)
	@mkdir -p $(INSTALL_BIN)
	cp -pf $(OKR) $(INSTALL_BIN)

.PHONY = install
