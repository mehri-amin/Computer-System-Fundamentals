# COMP1521 Lab07 Makefile

CC=gcc
#CFLAGS=-std=c99 -Wall -Werror
#CFLAGS=-std=c99 -Wall -Werror -DDBUG

#mysh : mysh1.c

#clean :
#	rm -f mysh *.o core

CFLAGS=-ggdb
all: main
main: mysh1.c
	$(CC) $(CFLAGS) -o mysh mysh1.c

clean:
	rm -rf mysh
