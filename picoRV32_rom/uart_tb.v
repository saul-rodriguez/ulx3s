//uart_tb.v
`timescale 1ns/1ps

`include "uart.v"

`define CLK_FREQ 16000000
`define BRATE 9600
`define END_SIM 36000
`define RX_UART 32'hcafe_babe
`define TX_UART 32'hcaca_bebe

module uart_tb();

parameter N=`CLK_FREQ/`BRATE;

reg rstn;
reg clk;	
reg [11:0] clk_per_bit;
reg [31:0] addr;
reg wen;
reg [7:0] wdata; //data to be transmited	
reg mem_valid;
reg wstrobe;

//reg mem_ready;
wire mem_ready;

wire uart_tx_ready; //Acknowledge that address has been read
wire tx_uart;
wire uart_tx_int_flag;

wire [7:0] data_out;
wire uart_rx_int_flag;
wire uart_rx_ready;

/*
wire [7:0] test;
wire [3:0] a;

assign a = 4'b1010;
assign test = {{(7-4){1'b1}},{a}};
*/

assign mem_ready = uart_tx_ready || uart_rx_ready;

UART_TX_PICO #(.ADDR(`TX_UART)) tx(
	.rstn(rstn),
	.clk(clk),
	.clk_per_bit(clk_per_bit),
	.addr(addr),
	.wen(wstrobe),
	.wdata(wdata),
	.mem_valid(mem_valid),
	.mem_ready(mem_ready),
	.uart_tx_ready(uart_tx_ready),
	.tx_uart(tx_uart),
	.uart_tx_int_flag(uart_tx_int_flag)
);

UART_RX_PICO #(.ADDR(`RX_UART)) rx(
	.rstn(rstn),
	.rx_uart(tx_uart),
	.clk(clk),
	.clk_per_bit(clk_per_bit),	
	.addr(addr),		
	.ren(!wstrobe),	
	.mem_valid(mem_valid),
	.mem_ready(mem_ready),
	.data_out(data_out),
	.uart_rx_int_flag(uart_rx_int_flag), // 
	.uart_rx_ready(uart_rx_ready) //Acknowledge that address has been read
);


parameter tck = 62.5; // clock TinyFpga (1/16 MHz)
always #(tck/2) clk = ~clk;

initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0,tx,rx);
	
	clk = 0;
	rstn = 1;
	wdata = 0;
	clk_per_bit = N;
	addr = 0;
	wstrobe = 0;
		
	#tck     rstn = 0;
	#(2*tck) rstn = 1;	
	
	#(3*tck) wdata = 8'haf;
	TXbyte;
	
	RXbyte;
	
	#(3*tck) wdata = 8'hee;
	TXbyte;
	
	RXbyte;
			 
	
	#(`END_SIM*tck) $finish;
end

task TXbyte;
	begin
		//#(3*tck) //wdata = 8'haf;
				 addr = `TX_UART;
				 mem_valid = 1;
				 wstrobe = 1;
		#(2*tck) wdata = 0;
				 addr = 0;
				 mem_valid = 0;
				 wstrobe = 0;
	end
endtask

task RXbyte;
	begin
		#((`END_SIM/2)*tck) addr = `RX_UART;
							mem_valid = 1;
							wstrobe = 0;
		#(2*tck) addr = 0;
				 mem_valid = 0;
				 wstrobe = 0;		
	end
endtask


endmodule 
