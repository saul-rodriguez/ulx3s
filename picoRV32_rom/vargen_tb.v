//vargen_tb.v

`timescale 1ns/10ps

`include "vargen.v"

`define END_SIM 150000

module vargen_tb;

	reg clk;
	reg resetn;
		
	reg  irq_5;
	reg  irq_6;
	reg  irq_7;
		
	wire [7:0] porta_out;	
	reg [7:0] portb_in;
	
	wire tx_uart;	
	wire rx_uart;
	
	//uncomment only for loopback test!
	assign rx_uart = tx_uart; 
	
	vargen myrisc(
			.clk(clk),
			.resetn(resetn),
			.irq_5(irq_5),
			.irq_6(irq_6),
			.irq_7(irq_7),
			.porta_out(porta_out),
			.portb_in(portb_in),
			.rx_uart(rx_uart),
			.tx_uart(tx_uart)
	);
	
/*	initial begin
		$monitor("%d\t%H\t%h\n",$time,myrisk,leds);
	end  
*/
	integer idx;
	
	initial begin
		
		$dumpfile("dump.vcd");
		$dumpvars(0,myrisc);
		
		for(idx = 0; idx < 32; idx = idx + 1) begin
			$dumpvars(0,myrisc.cpu.cpuregs.regs[idx]);
		end

		clk = 0;
		irq_5 = 0;
		irq_6 = 0;
		irq_7 = 0;
		resetn = 0;
		portb_in = 0;
		#(5*tck) resetn = 1;
		
		//test_irq;
		
		test_serial;
				
		#(`END_SIM*tck) $finish;
	end

parameter tck = 62.5; // clock TinyFpga (1/16 MHz)
always #(tck/2) clk = ~clk;

/*
	always begin
		#10 clk = ~clk;
	end
*/	
	
	
	task test_serial; //connect rx_uart to tx_uart for loopback test
		begin
			portb_in = 8'h00;
		end
	endtask
	
	
	task test_irq; 
		begin
			portb_in = 8'haf;
			#(500*tck) irq_5 = 1;
			#(40*tck) irq_5 = 0;
			//#(10000*tck) irq_6 = 1;
			#(10000*tck) irq_6 = 0;
			//#(10000*tck) irq_7 = 1;
			#(40*tck) irq_7 = 0;	
		end
	endtask

endmodule
