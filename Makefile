# GCC options
CC = gcc
CFLAGS = -Ofast -g -std=c99 -fopenmp -pedantic -Wall -march=native -fno-omit-frame-pointer
#CFLAGS = -Kfast -std=c99 
LDFLAGS = -lm

#Debug options
#CFLAGS = -g -Og -std=c99 -pedantic -fsanitize=undefined -fsanitize=address

# Intel icc compiler
#CC = icc
#CFLAGS = -restrict -Ofast -std=c99 -pedantic
#LDFLAGS =

# Clang options
#CC = clang
#CFLAGS = -Ofast -g -std=c99 -fopenmp -pedantic -Wall -march=native -fno-omit-frame-pointer
#-Rpass=openmp-opt
#LDFLAGS = -lm


SOURCE = src/current.c src/emf.c src/particles.c src/random.c src/timer.c src/main.c src/simulation.c src/zdf.c

TARGET = zpic

DOCSBASE = docs

DOCS = $(DOCSBASE)/html/index.html

OBJ = $(SOURCE:.c=.o)

export OMP_NUM_THREADS ?= 12

all : $(TARGET)

docs : $(DOCS)

$(TARGET) : $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) $(LDFLAGS) -o $@

src/%.o: src/%.c
	$(CC) -c $(CFLAGS) $< -o $@

$(DOCS) : $(SOURCE)
	@doxygen ./Doxyfile

run: all
	./zpic

clean:
	rm -f $(TARGET) $(OBJ)
	rm -rf $(DOCSBASE)
