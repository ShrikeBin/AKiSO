# Makefile do kompilacji boot sektora, Mandelbrota dla QEMU

# Nazwy plików
BOOT=boot.asm
MAIN=main.asm
BOOT_BIN=boot.bin

# Kompilator NASM
NASM=nasm

# Emulator QEMU
QEMU=qemu-system-i386

# Flagi NASM
NASM_FLAGS=-f bin -o

all: $(BOOT_BIN)

# Kompilacja boot sektora
$(BOOT_BIN): $(BOOT) $(MAIN)
	$(NASM) $(BOOT) $(NASM_FLAGS) $@
	$(NASM) $(MAIN) -o main.o -F elf32

# Uruchamianie w QEMU
run: $(BOOT_BIN)
	$(QEMU) -drive format=raw,file=$(BOOT_BIN)

# Czyszczenie plików tymczasowych
clean:
	rm -f $(BOOT_BIN) main.o

.PHONY: all run clean
