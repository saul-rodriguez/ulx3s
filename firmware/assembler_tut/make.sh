riscv32-unknown-elf-as -march=rv32imc  -o $1.o $1.asm

riscv32-unknown-elf-ld -Ttext=$2 -o $1.elf $1.o

riscv32-unknown-elf-nm $1.elf

riscv32-unknown-elf-objdump -d $1.elf

riscv32-unknown-elf-objcopy -O ihex $1.elf $1.hex

./ihex2all $1.hex $1.hex4
 
