//rom.v
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/assembler_tut/L1_ejer6.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/assembler_porta/porta.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/assembler_portb/portb.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/assembler_irq/test_irq.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/assembler_irq/test_irq_nr.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/c_test/test_porta.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/c_irq/test_irq.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/c_serial/test_serial.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/assembler_delay/delay.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/c_delay/c_delay.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/c_timer/test_timer.hex4"
//`define FIRMWARE "/home/saul/projects/ulx3s/firmware/c_func_pointer/test_pointer.hex4"
`define FIRMWARE "/home/saul/projects/ulx3s/firmware/c_spi/spi_master.hex4"

module rom256(input clk,
			input wen,
			input [7:0] addr,
			input [31:0] wdata,
			output reg [31:0] rdata);
			
  reg [31:0] mem [0:255];
  
 // initial mem[0] = 32'haabbccdd;
  
  initial begin
		$readmemh(`FIRMWARE, mem);
  end
  
  always @(posedge clk) begin
        if (wen) mem[addr] <= wdata;
        rdata <= mem[addr];
  end
endmodule


module rom512(input clk,
			input wen,
			input [8:0] addr,
			input [31:0] wdata,
			output reg [31:0] rdata);
			
  reg [31:0] mem [0:511];
  
 // initial mem[0] = 32'haabbccdd;
  
  initial begin
		$readmemh(`FIRMWARE, mem);
  end
  
  always @(posedge clk) begin
        if (wen) mem[addr] <= wdata;
        rdata <= mem[addr];
  end
endmodule

module test_mem(        input clk,
			input wen,
			input [7:0] addr,
			input [7:0] wdata,
			output reg [7:0] rdata);
			
  reg [7:0] mem [0:255];
  
 // initial mem[0] = 32'haabbccdd;
  
  
  always @(posedge clk) begin
        if (wen) mem[addr] <= wdata;
        rdata <= mem[addr];
  end
endmodule


