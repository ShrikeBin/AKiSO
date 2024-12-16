ASM_FILES := $(wildcard *.asm)     
OBJ_FILES := $(ASM_FILES:.asm=.o)
BIN_FILES := $(ASM_FILES:.asm=)

NASM := nasm
NASM_FLAGS := -f elf -g -F dwarf
LD := ld
LD_FLAGS := -m elf_i386

all: $(BIN_FILES)

%: %.o
	$(LD) $(LD_FLAGS) -o $@ $<

%.o: %.asm
	$(NASM) $(NASM_FLAGS) -o $@ $<

clean:
	rm -f $(OBJ_FILES) $(BIN_FILES)

gdb: $(BIN_FILES)
	@echo "Launching GDB for the first binary file: $(firstword $(BIN_FILES))"
	gdb $(firstword $(BIN_FILES))
