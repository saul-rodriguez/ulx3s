`timescale 1ns/1ps

`include "timer.v"

`define TMR0 32'h0010_001C
`define END_SIM 1000


module timer_tb();
	reg clk;
	reg resetn;
	reg [31:0] timer_value;
	reg [31:0] addr;
	reg wen;
	//reg [7:0] wdata;
	reg mem_valid;
	reg mem_ready;
	wire [7:0] timer_rdata;
	wire timer_ready;
	
	reg int;
	reg en;
	reg go;
	reg auto_load;
	
	wire [7:0] wdata;
	wire interrupt;
	wire go_done;
	
	assign wdata = {{4'b0},auto_load,en,go,int};
	assign interrupt = timer_rdata[0];
	assign go_done = timer_rdata[1];
	
	
	TIMER_VARGEN #(`TMR0) tmr0(
			.clk(clk),
			.resetn(resetn),
			.timer_value(timer_value), // a configuration register must connect here
			.addr(addr), 
			.wen(wen),
			.wdata(wdata[7:0]),	
			.mem_valid(mem_valid),
			.mem_ready(mem_ready),
			.timer_rdata(timer_rdata),	
			.timer_ready(timer_ready)
	);
	
	
	parameter tck = 62.5; // clock TinyFpga (1/16 MHz)
	always #(tck/2) clk = ~clk;
	
	always @(*) begin
		mem_ready = timer_ready;
	end
	
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0,tmr0);
		
		clk = 1;
		resetn = 1;
		timer_value = 32'hffff_fff0;
		addr = 0;
		wen = 0;
		int = 0;
		en = 0;
		go = 0;
		auto_load = 0;
		mem_valid = 0;
		mem_ready = 0;
		
		#(tck/2) resetn = 0;
		#(tck) resetn = 1;
		
		#(5*tck) en = 1;
		#(2*tck) go = 1;
		#(2*tck) addr = `TMR0;
				 mem_valid = 1; wen = 1;
		#(1*tck) mem_valid = 0; wen = 0;
		
		
		#(20*tck) mem_valid = 1; wen = 1; auto_load = 1;
		#(1*tck) mem_valid = 0; wen = 0;
		
		#(20*tck) mem_valid = 1; wen = 1; auto_load = 1;
		#(1*tck) mem_valid = 0; wen = 0;
		
		#(60*tck) mem_valid = 1; wen = 1; auto_load = 0; go = 0; en = 0;
		#(1*tck) mem_valid = 0; wen = 0;
		
		#(`END_SIM*tck) $finish;
	end
	
endmodule
