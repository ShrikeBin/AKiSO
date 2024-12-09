ASM_FILES := $(wildcard *.asm)     
OBJ_FILES := $(ASM_FILES:.asm=.o)
BIN_FILES := $(ASM_FILES:.asm=)

NASM := nasm
NASM_FLAGS := -f elf64
LD := ld
LD_FLAGS := -m elf_x86_64

all: $(BIN_FILES)

%: %.o
	$(LD) $(LD_FLAGS) -o $@ $<

%.o: %.asm
	$(NASM) $(NASM_FLAGS) -o $@ $<

clean:
	rm -f $(OBJ_FILES) $(BIN_FILES)

