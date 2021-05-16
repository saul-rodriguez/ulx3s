
`include "vargen.v"
//`include "rom.v"

module top (
	input [3:0] sw, 	
	input [5:0] gp,
	output [5:0] gn,
	output [7:0] led,	
	input [6:0] btn, // [3:1] are active high, [0] is active low	
	//output PIN_23,
	input clk_25mhz,
	output wifi_gpio0    
);
    	assign wifi_gpio0 = 1'b1;
	
	//PORTB
	wire [7:0] switches;
	//assign switches = {PIN_8,PIN_7,PIN_6,PIN_5,PIN_4,PIN_3,PIN_2,PIN_1};
	assign switches = {{(4){1'b0}},sw[3:0]};
	
	//PORTA
	wire [7:0] leds;
	assign leds = led[7:0];
	
	//IRQs
	wire [3:0] pushbuttons;
	assign pushbuttons[3:0] = btn[3:0];
	
	//UART
	wire rx_uart;
	assign rx_uart = gp[0];
	
	wire tx_uart;
	assign tx_uart = gn[0];
	
	//SPI
	wire spi_clk;
	wire spi_mosi;
	wire spi_miso;
	wire spi_cs;
	
	assign spi_miso = gp[1];
	assign spi_clk = gn[1];
	assign spi_mosi = gn[2];
	assign spi_cs = gn[3];
	
	//resetn		
	reg resetn_meta;
	reg resetn;
	
	wire CLK;

	assign CLK = clk_25mhz;

	always @(posedge CLK) begin
		resetn_meta <= pushbuttons[0];
//		resetn_meta <= pushbuttons[0];
		resetn <= resetn_meta;
	end
	

	//TEST FLOW
//	assign leds[3:0] = sw[3:0];
//	assign leds[4] = pushbutton[0];
//	assign leds[7:4] = pushbuttons[3:0];

/*
reg [3:0] tempo;
always @(posedge CLK) begin
	if (resetn == 0) begin
		tempo[3:0] = sw[3:0];		
	end else begin
		tempo[3:0] = 0;
	end
end

assign leds[3:0] = tempo[3:0];
*/
	//risc5 vargen

	vargen myrisc(
			.clk(CLK),
			.resetn(resetn),
			.irq_5(pushbuttons[1]),
			.irq_6(pushbuttons[2]),
			.irq_7(pushbuttons[3]),
			.porta_out(leds),
			.portb_in(switches),
			.rx_uart(rx_uart),
			.tx_uart(tx_uart),
			.spi_miso(spi_miso),
			.spi_clk(spi_clk),
			.spi_mosi(spi_mosi),
			.spi_cs(spi_cs)
	);
	

/*
vargen myrisc(
			.clk(CLK),
			.resetn(resetn),
			.irq_5(1'b0),
			.irq_6(1'b0),
			.irq_7(1'b0),
			.porta_out(leds),
			.portb_in(switches),
			.rx_uart(1'b1),
			.tx_uart(tx_uart),
			.spi_miso(1'b0),
			.spi_clk(spi_clk),
			.spi_mosi(spi_mosi),
			.spi_cs(spi_cs)
	);	
  */  


/*
wire [8:0] address;
assign address = {{5'b0},sw[3:0]};

wire [31:0] rom_rdata;
assign leds[7:0] = rom_rdata[7:0];

rom512 pico_rom(
			.clk(CLK),
			.wen(1'b0),
			.addr(address), //address is always aligned to 4 bytes
			.wdata(32'h0000_0000),
			.rdata(rom_rdata)
		);

*/

endmodule
