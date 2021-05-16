`ifndef VARGEN_V
`define VARGEN_V

	//VERIL exposes the memory interface so that Verilator and a C++ program
	//can externally connect a ROM. The internal ROM and its signals are disabled.	
//`define VERIL

	//SYNQ_IRQ synchronizes IRQ5,6,7. This is required if they are external inputs
`define SYNQ_IRQ
	
`ifdef PICORV32_V
`error "vargen.v must be read before picorv32.v!"
`endif
	


`define PICORV32_REGS picosoc_regs

`include "vargen_inc.v"

`include "picorv32.v"
`include "rom.v"
`include "gio.v"
`include "uart.v"
`include "timer.v"
`include "SPI_Master.v"


module vargen (
		`ifdef VERIL
			output v_mem_valid,
			output v_mem_instr,
			input  v_mem_ready,

			output [31:0] v_mem_addr,
			output [31:0] v_mem_wdata,
			output [ 3:0] v_mem_wstrb,
			input  [31:0] v_mem_rdata,
		`endif
		
	input clk,
	input resetn,
	input  irq_5,
	input  irq_6,
	input  irq_7,
	output [`PORTA_WIDTH-1:0] porta_out,
	input [`PORTB_WIDTH-1:0] portb_in,
	input rx_uart,
	output tx_uart,
	output spi_clk,
	output spi_mosi,
	input  spi_miso,
	output spi_cs	
);

parameter integer MEM_WORDS = 256;
parameter [31:0] STACKADDR = (4*MEM_WORDS);       // end of memory at 1kbyte
parameter [31:0] PROGADDR_RESET = 32'h 0001_0000; // Starts at 64k from initialized blockRAM
parameter [31:0] PROGADDR_IRQ = 32'h 0001_0010; // 

/************/
/* PICORV32 */
/************/

//Interrupts
reg [31:0] irq;
wire irq_stall = 0;
wire irq_uart = 0;

//Syncrhonize external interrupts if needed
wire irq_5_sync;
wire irq_6_sync;
wire irq_7_sync;

`ifdef SYNQ_IRQ
	reg irq_5_meta;
	reg irq_6_meta;
	reg irq_7_meta;
	
	reg irq_5_stab;
	reg irq_6_stab;
	reg irq_7_stab;
	
	always @(posedge clk) begin
		irq_5_meta <= irq_5;
		irq_6_meta <= irq_6;
		irq_7_meta <= irq_7;
		irq_5_stab <= irq_5_meta;
		irq_6_stab <= irq_6_meta;
		irq_7_stab <= irq_7_meta;
	end
	
	assign irq_5_sync = irq_5_stab;
	assign irq_6_sync = irq_6_stab;
	assign irq_7_sync = irq_7_stab;
	
`else
	assign irq_5_sync = irq_5;
	assign irq_6_sync = irq_6;
	assign irq_7_sync = irq_7;	
`endif

always @* begin
		irq = 0;
		irq[3] = vargen_int_flag;
	//	irq[3] = uart_tx_int_flag_pico;
	//	irq[4] = uart_rx_int_flag_pico;
	//	irq[5] = irq_5;
	//	irq[6] = irq_6;
	//	irq[7] = irq_7;
	//	irq[8] = timer0_int_flag_pico;
	//	irq[9] = spi_master_int_flag_pico;
end

// address & data bus 
wire mem_valid;
wire mem_instr;
wire mem_ready;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [3:0] mem_wstrb;
wire [31:0] mem_rdata;

`ifdef VERIL
	assign v_mem_valid = mem_valid;
	assign v_mem_instr = mem_instr;
	assign v_mem_addr = mem_addr;
	assign v_mem_wdata = mem_wdata;
	assign v_mem_wstrb = mem_wstrb;
`endif


//mem_ready is asserted when a peer that is connected to the address bus (for read/write) has completed reading the address. 
assign mem_ready = ram_ready || rom_ready || porta_ready || portb_ready || 
				   uart_conf_ready || uart_tx_ready || uart_rx_ready ||
				   intcon_ready || intflags_ready || timer0_ready || timer0_value_ready 
				   || spi_master_conf_ready || spi_master_ready
				   `ifdef VERIL
				   		|| v_mem_ready;
				   `else
						;
				   `endif
				   

//mem_rdata is the read data bus and it is implemented as a mux: 
assign mem_rdata = ram_ready ? ram_rdata :
				   rom_ready ? rom_rdata : 
				   porta_ready ? porta_data32 :
				   portb_ready ? portb_data32 :
				   uart_rx_ready ? uart_rx_data32 : 
				   intcon_ready ? intcon_data32 :
				   intflags_ready? intflags_data32 : 
				   timer0_ready? timer0_rdata32 : 
				   spi_master_conf_ready? spi_master_conf_data32 :
				   spi_master_ready? spi_master_rx_data32 : 
				   `ifdef VERIL
				   	v_mem_ready? v_mem_rdata :
				   `endif
				   32'h0000_0000;
				   

/* Only one <name>_ready signal can be asserted at a time!   
*  Note: ram_ready and rom_ready are left here exactly as they were in the original PicoSoc example
*  However, <name>_ready signals should in principle be generated by the peers that are addressed.
*/
always @(posedge clk) begin	
	ram_ready <= mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS; //Only asserted if address is below 4*MEMWORDS = 1kbyte	
	`ifdef VERIL
		rom_ready <= 0;
	`else		
		rom_ready <= mem_valid && !mem_ready && mem_addr >= 4*MEM_WORDS && mem_addr < 32'h0010_0000; //Only asserted if memory is above RAM and under 1M
	`endif
	//porta_ready <= mem_valid && !mem_ready && mem_addr == `PORTA; //Example for local creation of a <name>_ready signal (not recommended, read above)
end

//RISC V picorv32 
picorv32 #(
		.STACKADDR(STACKADDR),
		.PROGADDR_RESET(PROGADDR_RESET),
		.PROGADDR_IRQ(PROGADDR_IRQ),
		.BARREL_SHIFTER(1),
		.COMPRESSED_ISA(1),
		.ENABLE_MUL(1),
		.ENABLE_DIV(1),
		.ENABLE_IRQ(1),
		.ENABLE_IRQ_QREGS(1)
	) cpu (
		.clk         (clk        ),
		.resetn      (resetn     ),
		.mem_valid   (mem_valid  ),
		.mem_instr   (mem_instr  ),
		.mem_ready   (mem_ready  ),
		.mem_addr    (mem_addr   ),
		.mem_wdata   (mem_wdata  ),
		.mem_wstrb   (mem_wstrb  ),
		.mem_rdata   (mem_rdata  ),
		.irq         (irq        )
	);

/***************/
/* DATA MEMORY */
/***************/

wire [31:0] ram_rdata;
reg ram_ready;

picosoc_mem #(.WORDS(MEM_WORDS)) memory (
		.clk(clk),
		.wen((mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS) ? mem_wstrb : 4'b0),
		.addr(mem_addr[23:2]), //address is always aligned to 4 bytes
		.wdata(mem_wdata),
		.rdata(ram_rdata)
	);

/******************/	
/* PROGRAM MEMORY */
/******************/

wire [31:0] rom_rdata;
reg rom_ready; 


`ifdef VERIL

	assign rom_rdata = 0;
	
`else
	rom512 pico_rom(
			.clk(clk),
			.wen(1'b0),
			.addr(mem_addr[10:2]), //address is always aligned to 4 bytes
			.wdata(32'h0000_0000),
			.rdata(rom_rdata)
		);
	
`endif

/************/
/* PORTA (W)*/
/************/
//porta_out already declared at vargen()
wire porta_ready;
wire [31:0] porta_data32;
assign porta_data32 = {{(32 -`PORTA_WIDTH){1'b0}},porta_out};

//ioport #(.ADDR(`SPI_MST_CONF),
ioport #(.ADDR(`PORTA),
		  .WIDTH(`PORTA_WIDTH)
		  ) porta(
			.clk(clk),
			.addr(mem_addr), 
			.wdata(mem_wdata[`PORTA_WIDTH-1:0]),	
			.wen(mem_wstrb[0]), 
			.resetn(resetn), 
			.mem_valid(mem_valid),
			.mem_ready(mem_ready),
			.mem_port_ready(porta_ready),
			.odata(porta_out)
		  );

/************/
/* PORTB (R)*/
/************/

wire [`PORTB_WIDTH-1:0] portb_data;
wire portb_ready;
wire [31:0] portb_data32;
assign portb_data32 = {{(32 -`PORTB_WIDTH){1'b0}},portb_data};

ioport #(.ADDR(`PORTB),
		  .WIDTH(`PORTB_WIDTH)
		  ) portb(
			.clk(clk),
			.addr(mem_addr), 
			.wdata(portb_in),	
			.wen(1'b1), // always enabled for writing
			.resetn(resetn), 
			.mem_valid(mem_valid),
			.mem_ready(mem_ready),
			.mem_port_ready(portb_ready),
			.odata(portb_data)
		  );

/************************/		  
/* INTCON REGISTER (R/W)*/
/************************/

//          Interrupt bits order in INTCON and INTFLAG
//  B7      B6      B5      B4       B3      B2      B1      B0
//  GIE    IRQ7    IRQ6    IRQ5  SPI_MASTER  TMR0  TX_UART RX_UART 

wire intcon_ready;
wire [7:0] intcon;
wire [31:0] intcon_data32;
assign intcon_data32 = {{(24){1'b0}},intcon};

ioport #(.ADDR(`INTCON),
		 .WIDTH(8)
		 ) intcon_reg (
			.clk(clk),
			.addr(mem_addr), 
			.wdata(mem_wdata[7:0]),	
			.wen(mem_wstrb[0]), 
			.resetn(resetn), 
			.mem_valid(mem_valid),
			.mem_ready(mem_ready),
			.mem_port_ready(intcon_ready),
			.odata(intcon)
		  );

/************************/
/* INTFLAGS REGISTER (R)*/
/************************/

wire [7:0] intflags;
wire intflags_ready;
wire [31:0] intflags_data32;
assign intflags_data32 = {{(24){1'b0}},intflags};

wire [7:0] interrupt_flags;

assign interrupt_flags[0] = uart_rx_int_flag;
assign interrupt_flags[1] = uart_tx_int_flag;
assign interrupt_flags[2] = timer0_int_flag;
assign interrupt_flags[3] = spi_master_int_flag;
assign interrupt_flags[4] = irq_5_sync;
assign interrupt_flags[5] = irq_6_sync;
assign interrupt_flags[6] = irq_7_sync;
assign interrupt_flags[7] = 0;


wire vargen_int_flag;

assign vargen_int_flag = intcon[7] & ( | (intcon[6:0] & interrupt_flags[6:0]));

ioport #(.ADDR(`INTFLAGS),
		  .WIDTH(8)
		  ) intflags_reg (
			.clk(clk),
			.addr(mem_addr), 
			.wdata(interrupt_flags),	
			.wen(1'b1), // it would also work  .wen(!mem_wstrb[0])
			//.wen(!mem_wstrb[0]), // it would also work  .wen(!mem_wstrb[0])
			.resetn(resetn), 
			.mem_valid(mem_valid),
			.mem_ready(mem_ready),
			.mem_port_ready(intflags_ready),
			.odata(intflags)
		  );

/********/
/* UART */
/********/

//UART Configuration register

wire [11:0] uart_conf;
wire uart_conf_ready;

ioport #(.ADDR(`UART_CONF),
		  .WIDTH(12)
		  ) uart_conf_reg(
			.clk(clk),
			.addr(mem_addr), 
			.wdata(mem_wdata[11:0]),	
			.wen(mem_wstrb[0]), 
			.resetn(resetn), 
			.mem_valid(mem_valid),
			.mem_ready(mem_ready),
			.mem_port_ready(uart_conf_ready),
			.odata(uart_conf)
		  );

//UART TX wrapper
wire tx_uart;	  
wire uart_tx_ready;
wire uart_tx_int_flag;
wire uart_tx_int_flag_pico; //This signal will connect to an irq input in the picorv32 

assign uart_tx_int_flag_pico = intcon[1] & uart_tx_int_flag;

UART_TX_PICO #(.ADDR(`UART_TX)) tx(
	.rstn(resetn),
	.clk(clk),
	.clk_per_bit(uart_conf),
	.addr(mem_addr),
	.wen(mem_wstrb[0]),
	.wdata(mem_wdata[7:0]),
	.mem_valid(mem_valid),
	.mem_ready(mem_ready),
	.uart_tx_ready(uart_tx_ready),
	.tx_uart(tx_uart),
	.uart_tx_int_flag(uart_tx_int_flag)
);


//UART RX wrapper
wire rx_uart;
wire [7:0] uart_rx_data;
wire uart_rx_ready;
wire [31:0] uart_rx_data32;
assign uart_rx_data32 = {{(24){1'b0}},uart_rx_data};

wire uart_rx_int_flag;
wire uart_rx_int_flag_pico; //This signal will connect to an irq input in the picorv32

assign uart_rx_int_flag_pico = intcon[0] & uart_rx_int_flag;

UART_RX_PICO #(.ADDR(`UART_RX)) rx(
	.rstn(resetn),
	.rx_uart(rx_uart),
	.clk(clk),
	.clk_per_bit(uart_conf),	
	.addr(mem_addr),		
	.ren(!mem_wstrb[0]),	
	.mem_valid(mem_valid),
	.mem_ready(mem_ready),
	.data_out(uart_rx_data),
	.uart_rx_int_flag(uart_rx_int_flag), // 
	.uart_rx_ready(uart_rx_ready) //Acknowledge that address has been read
);

/***********/
/* TIMER0  */
/***********/

//Timer0 value register

wire [31:0] timer0_value;
wire timer0_value_ready;

ioport #(.ADDR(`TIMER0),
		.WIDTH(32)
	) timer0_reg(
		.clk(clk),
		.addr(mem_addr), 
		.wdata(mem_wdata),	
		.wen(mem_wstrb[0]), 
		.resetn(resetn), 
		.mem_valid(mem_valid),
		.mem_ready(mem_ready),
		.mem_port_ready(timer0_value_ready),
		.odata(timer0_value)
	);

// Timer0 wrapper

wire [7:0] timer0_rdata;
wire timer0_ready;

wire [31:0] timer0_rdata32;
assign timer0_rdata32 = {{(24){1'b0}},timer0_rdata};

wire timer0_int_flag;
wire timer0_int_flag_pico;

assign timer0_int_flag = timer0_rdata[0];
assign timer0_int_flag_pico = timer0_int_flag & intcon[2];

TIMER_VARGEN #(`TIMER0_CONF) tmr0(
		.clk(clk),
		.resetn(resetn),
		.timer_value(timer0_value), // a configuration register must connect here
		.addr(mem_addr), 
		.wen(mem_wstrb[0]),
		.wdata(mem_wdata[7:0]),	
		.mem_valid(mem_valid),
		.mem_ready(mem_ready),
		.timer_rdata(timer0_rdata),	
		.timer_ready(timer0_ready)
	);
	
/***************
 * SPI MASTER  *
 ***************/
 
 //SPI Master configuration register
 
wire [12:0] spi_master_conf;
wire spi_master_conf_ready;
wire spi_master_cs;

wire [31:0] spi_master_conf_data32;
assign spi_master_conf_data32 = {{(19){1'b0}},spi_master_conf};

assign spi_master_cs = spi_master_conf[12];
assign spi_cs = spi_master_cs; //CS output of vargen

ioport #(.ADDR(`SPI_MST_CONF),
		.WIDTH(13)
	) spi_master_conf_reg(
		.clk(clk),
		.addr(mem_addr), 
		.wdata(mem_wdata[12:0]),	
		.wen(|mem_wstrb), 
		.resetn(resetn), 
		.mem_valid(mem_valid),
		.mem_ready(mem_ready),
		.mem_port_ready(spi_master_conf_ready),
		.odata(spi_master_conf)
	);
	

 
 //SPI Master wrapper
wire [7:0] spi_master_rx_data;
wire [31:0] spi_master_rx_data32;
wire spi_master_ready;
assign spi_master_rx_data32 = {{(24){1'b0}},spi_master_rx_data};

wire spi_master_int_flag;
wire spi_master_int_flag_pico; //This signal will connect to an irq input in the picorv32
assign spi_master_int_flag_pico = intcon[3] & spi_master_int_flag;

SPI_master_pico #(.ADDR(`SPI_MST)) spi(
		.clk(clk),
		.addr(mem_addr), 
		.wdata(mem_wdata[7:0]),	
		.wen(mem_wstrb[0]), 
		.resetn(resetn), 	
		.mem_valid(mem_valid),
		.mem_ready(mem_ready),
		.mem_port_ready(spi_master_ready),
		.rx_data(spi_master_rx_data),
		.tx_ready(spi_master_int_flag), //High when idle, Low when busy
		.Clks_per_half_bit(spi_master_conf[11:0]),
		.SPI_Clk(spi_clk),
		.SPI_MISO(spi_miso),
		.SPI_MOSI(spi_mosi) //Back to back test
	);


endmodule //END module vargen

//Registers module

module picosoc_regs (
	input clk, wen,
	input [5:0] waddr,
	input [5:0] raddr1,
	input [5:0] raddr2,
	input [31:0] wdata,
	output [31:0] rdata1,
	output [31:0] rdata2
);
	reg [31:0] regs [0:31];

	always @(posedge clk)
		if (wen) regs[waddr[4:0]] <= wdata;

	assign rdata1 = regs[raddr1[4:0]];
	assign rdata2 = regs[raddr2[4:0]];
endmodule

//Data memory module
module picosoc_mem #(
	parameter integer WORDS = 256
) (
	input clk,
	input [3:0] wen,
	input [21:0] addr,
	input [31:0] wdata,
	output reg [31:0] rdata
);
	reg [31:0] mem [0:WORDS-1];

	always @(posedge clk) begin
		rdata <= mem[addr];
		if (wen[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
		if (wen[1]) mem[addr][15: 8] <= wdata[15: 8];
		if (wen[2]) mem[addr][23:16] <= wdata[23:16];
		if (wen[3]) mem[addr][31:24] <= wdata[31:24];
	end
endmodule

`endif
