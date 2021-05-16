# Makefile template for PICORV32 GCC projects
# Author: Saul Rodriguez
# Date:	2020-07-03
#
#  The following variables need to be set for each project:
# 	NAME = project name used as output name
#	SRCS = paths to the C files to be compiled
# 	SRC_START = path to the assembler start script
#	L_SECTIONS = path to sections.lds file

#Compiler variables
CC = /opt/riscv32i/bin/riscv32-unknown-elf-gcc
OBJDUMP = /opt/riscv32i/bin/riscv32-unknown-elf-objdump
OBJCOPY = /opt/riscv32i/bin/riscv32-unknown-elf-objcopy

#Simulator
VARGEN = /home/saul/projects/Qt/vargen_simulator/build-vargen-Desktop_Qt_5_12_3_GCC_64bit-Debug/vargen

#compiler and linker flags
CFLAGS = -march=rv32imc -O3 -Wall -flto

#compiler and linker flags debug
CFLAGS_DEB = -march=rv32imc -O3 -Wall -fverbose-asm -g

# linker flags
LINK_FLAGS = -march=rv32imc -Wall -flto -nostartfiles -Wl,-Bstatic,-T,$(L_SECTIONS),--strip-debug,-Map=firmware.map,--cref -ffreestanding -nostdlib

#output name
NAME = test_pointer

#sources
SRCS = ../common/vargen.c interrupt_manager.c main.c 
SRC_START = ../common/start.S
L_SECTIONS = sections.lds

SRCS_NO_DIR = $(notdir $(SRCS))
ASSEMS = $(SRCS_NO_DIR:.c=.s)
OBJS = $(ASSEMS:.s=.o)

all: $(NAME).hex4	
	@echo creating hex4 file from source	
#all tests
test: 
	@echo all tests

#compile elf file from source
compile: $(NAME).elf
	@echo Compiled elf file from sources

#dump assembly code and symbols table on the terminal
dump: $(NAME).elf	 
	$(OBJDUMP) -d -t $(NAME).elf > $(NAME).dmp
	
#Compile step
$(ASSEMS) : $(SRCS)
	$(CC) $(CFLAGS) -S $^

#Compile debug step
debug : $(SRCS)
	$(CC) $(CFLAGS_DEB) -S $^
	$(CC) $(CFLAGS_DEB) -Wa,-adhln -c $(SRC_START) $(ASSEMS) > $(NAME).lst
	make all

#assemble step
$(OBJS) : $(ASSEMS) 
	$(CC) $(CFLAGS) -c $^

start.o : $(SRC_START)
	$(CC) $(CFLAGS) -c $^

#link step
$(NAME).elf: start.o $(OBJS) 
	$(CC) $(LINK_FLAGS) -o $@ $^ 

#create hex files
$(NAME).hex4: $(NAME).elf	
	$(OBJCOPY) -O ihex $(NAME).elf $(NAME).hex
	./ihex2all $(NAME).hex $(NAME).hex4

#simulate	
sim: $(NAME).hex4
	make debug
	make dump
	$(VARGEN) $(NAME).hex4 $(NAME).dmp $(NAME).lst
	
#clean up
clean:
	-rm -rf *.o *.s *.lst *.map *.hex *.hex4 *.elf *.dmp


