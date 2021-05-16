//vargen_tb.sv

`timescale 1ns/10ps

`include "vargen.v"

`define CLK_FREQ 25000000
`define END_SIM 25000


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
	
	wire spi_clk;
	wire spi_mosi;
	wire spi_miso;
	wire spi_cs;
	//wire SPI_CS
	
	//uncomment only for loopback tests!
	assign rx_uart = tx_uart; 
	assign spi_miso = spi_mosi;
	
	parameter CLK_PERIOD = 40;  // Period Clock TinyFpga 1/16 MHz
	
	vargen myrisc(
			.clk(clk),
			.resetn(resetn),
			.irq_5(irq_5),
			.irq_6(irq_6),
			.irq_7(irq_7),
			.porta_out(porta_out),
			.portb_in(portb_in),
			.rx_uart(rx_uart),
			.tx_uart(tx_uart),
			.spi_clk(spi_clk),
			.spi_mosi(spi_mosi),
			.spi_miso(spi_miso),
			.spi_cs(spi_cs)
	);
	

	integer idx;
	
	initial begin
		
		$dumpfile("dump.vcd");
		$dumpvars;
		//$dumpvars(0,myrisc);
		
		
		for(idx = 0; idx < 32; idx = idx + 1) begin
			$dumpvars(0,myrisc.cpu.cpuregs.regs[idx]);
		end

		clk = 0;
		irq_5 = 0;
		irq_6 = 0;
		irq_7 = 0;
		resetn = 0;
		portb_in = 0;
		
		repeat(10) @(posedge clk);
		resetn = 1;
		
		//test_spi;	
		test_irq;		
		//test_serial;
				
		#(`END_SIM*CLK_PERIOD) $finish;
	end

always #(CLK_PERIOD/2) clk = ~clk;
	
	
	task test_serial; //connect rx_uart to tx_uart for loopback test
		begin
			portb_in = 8'h00;
		end
	endtask
	
	task test_spi; //connect rx_uart to tx_uart for loopback test
		begin
			portb_in = 8'h01;
		end
	endtask
	
	task test_irq; 
		begin
			portb_in = 8'haf;
			#(7500*CLK_PERIOD) irq_5 = 1;
			#(800*CLK_PERIOD) irq_5 = 0;
			#(2500*CLK_PERIOD) irq_6 = 1;
			#(800*CLK_PERIOD) irq_6 = 0;
			#(2500*CLK_PERIOD) irq_7 = 1;
			#(800*CLK_PERIOD) irq_7 = 0;	
		end
	endtask

endmodule
