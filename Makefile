
TARGET=senzillc

CFLAGS = -Wall -DNDEBUG

.phony: clean all test error

all : $(TARGET) VM dissas assembler

dissas : dissas.c SM.c CG.c
	$(CC) $(CFLAGS) dissas.c SM.c CG.c -o dissas -lm

VM : SM.c VM.c CG.c
	$(CC) $(CFLAGS) CG.c SM.c VM.c -o VM -lm

$(TARGET) : $(TARGET).tab.c lex.yy.c SM.c CG.c ST.c
	$(CC) $(CFLAGS) $(TARGET).tab.c lex.yy.c SM.c CG.c ST.c -lm -o $(TARGET) 

$(TARGET).tab.h $(TARGET).tab.c : $(TARGET).y
	bison -dv $(TARGET).y 

lex.yy.c : $(TARGET).l
	flex $(TARGET).l

assembler : assembler.l SM.c CG.c ST.c
	flex -o assembler.c assembler.l
	$(CC) $(CFLAGS) assembler.c SM.c CG.c ST.c -o assembler -lm
	$(RM) assembler.c

clean:
	rm -f $(TARGET) VM dissas assembler $(TARGET).tab.c $(TARGET).tab.h lex.yy.c $(TARGET).output *.o *~ *.vm


TESTS = $(wildcard *.sz)
ERRORS = $(wildcard *.error)

test: $(TARGET)
	@echo "#### Begin Test" $(TARGET)
	@for t in $(TESTS); do \
		echo "#### Testing" $$t ; \
		./$(TARGET) $$t `basename $$t .sz`.vm; \
	done
	@echo "#### Ending Test"

error: $(TARGET)
	@for t in $(ERRORS); do \
		./$(TARGET) $$t; \
	done
