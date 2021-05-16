//gio_tb.v
`timescale 1ns/10ps

`include "gio.v"

`define WIDTH 8
`define ADDR  32'h01000000 //This parameter must be initialized during instantiation!
`define DATA  8'hab

module output_tb();
	reg clk;
	reg [31:0] addr;	
	reg [`WIDTH-1:0] wdata;	
	reg wen;
	reg resetn;
	reg mem_valid;
	reg mem_ready;
	wire mem_port_ready; 
	wire [`WIDTH-1:0] odata; 


	outport #(.ADDR(`ADDR),.WIDTH(`WIDTH)) myport(
		.clk(clk),
		.addr(addr), 
		.wdata(wdata),	
		.wen(wen), 
		.resetn(resetn),
		.mem_valid(mem_valid),
		.mem_ready(mem_ready),
		.mem_port_ready(mem_port_ready), 
		.odata(odata) 
	);

	always @(*) begin
		mem_ready = mem_port_ready;
	end
	
	initial begin		
		$dumpfile("dump.vcd");
		$dumpvars(0,myport);
		$monitor("%d\t%d\t%d\t%X\t%X\t%d",$time,clk,wen,addr,odata,mem_port_ready);

		clk = 0;
		wen = 0;
		addr = `ADDR;
		resetn = 0;
		wdata = `DATA;
		mem_valid = 0;
		mem_ready = 0; 
		
		#10 resetn = 1;
		#10 wen = 1; mem_valid = 1;
		#30 wen = 0; mem_valid = 0;
			//addr = 0;
			wdata = `DATA + 1;
			//addr = `ADDR+1;
		#10 wen = 1; mem_valid = 1;
		#50 $finish;
		 
		
	end
	
	always begin
		#5 clk = ~clk;
	end
	
endmodule

