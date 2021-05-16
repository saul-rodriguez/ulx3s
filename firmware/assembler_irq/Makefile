#Makefile 

#simulator path
VARGEN = /home/saul/projects/Qt/vargen_simulator/build-vargen-Desktop_Qt_5_12_3_GCC_64bit-Debug/vargen

#Compiler variables
CC = /opt/riscv32i/bin/riscv32-unknown-elf-gcc
OBJDUMP = /opt/riscv32i/bin/riscv32-unknown-elf-objdump
OBJCOPY = /opt/riscv32i/bin/riscv32-unknown-elf-objcopy

#link flags
L_SECTIONS = ../common/sections.lds
LINK_FLAGS = -march=rv32imc -Wall -flto -nostartfiles -Wl,-Bstatic,-T,$(L_SECTIONS),--strip-debug,-Map=firmware.map,--cref -ffreestanding -nostdlib

#sources
NAME=test_irq
SRCS = test_irq.S

all: $(NAME).hex4

dump: $(NAME).elf
	$(OBJDUMP) -d -t $(NAME).elf > $(NAME).dmp

$(NAME).elf : $(SRCS)
	$(CC) $(LINK_FLAGS) -o $(NAME).elf $^

$(NAME).hex4 : $(NAME).elf	
	$(OBJCOPY) -O ihex $(NAME).elf $(NAME).hex
	./ihex2all $(NAME).hex $(NAME).hex4
	
sim: $(NAME).hex4
	make dump
	$(VARGEN) $(NAME).hex4 $(NAME).dmp

clean: 
	rm -rf *.elf *.hex *.hex4 *.dmp *.map



