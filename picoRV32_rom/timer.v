`ifndef TIMER_V
`define TIMER_V

module timer(
	input clk,
	input resetn, //active (L)	
	input [31:0] timer_value, // 31 bit load value for the counter 
	input en, //enable (H)
	input go, //start (H)
	input auto_load, //automatic restart timer after rolloff (H)
	output reg tmr_int, //roll of - interrupt 1 pulse (H)
	output reg go_clear // 1 pulse (H)
);

//Timer
reg [31:0] timer_count;
reg [1:0] timer_state;

parameter IDLE  = 2'b00,
		  GO 	= 2'b01,
		  ROLL  = 2'b11;
		
always @(posedge clk) begin
	if (resetn == 0) begin
		timer_count <= 0;
		timer_state <= IDLE;
		tmr_int <= 0;
		go_clear <= 0;		
	end else begin
		if (en) begin 
			case (timer_state)
				IDLE:	begin
							if (go) begin
								timer_count <= timer_value;
								timer_state <= GO;								
							end else begin
								timer_state <= IDLE;
							end
							
							tmr_int <= 0;								
						end
						
				GO:		begin
							timer_count <= timer_count + 1;
							
							if (timer_count == 32'hffff_ffff) begin
								timer_state <= ROLL;
								go_clear <= 1; //active for 1 cycle!
								tmr_int <= 1;
							end else begin
								timer_state <= GO;
							end
						end
						
				ROLL:	begin
							tmr_int <= 0; 
							go_clear <= 0;
							
							if (auto_load) begin
								timer_count <= timer_value;
								timer_state <= GO;
							end else begin
								timer_state <= IDLE;
							end								
							
						end
				default:	timer_state <= IDLE;
			endcase
			
		end else begin
			timer_state <= IDLE;
		end
	end
end

endmodule

/***************
* TIMER VARGEN *
****************/

/*
// timer_rdata contains the control register for the timer:
//      B7       B6        B5       B4        B3        B2        B1        B0
//   	-         -         -        -      AUTO_LD     EN        GO      INT_TMR
//
// Notes: 1) GO and INT_TMR are R&W bits that are set/cleared by the timer.
// 		  2) timer_value is a 32bit word that is loaded into the counter. Once the module is enabled EN=(H),
//           and GO is set (H), the counter increments with every clock cycle. An overflow sets INT_TMR to (H)
//			 INT_TMR must be cleared by software. If AUTO_LD is set (H), the timer_value word is automatically reloaded and
//			 a new counting starts. If AUTO_LD is cleared (L) the counter remains iddle.
// 
*/




module TIMER_VARGEN (
	input clk,
	input resetn,
	input [31:0] timer_value, // a configuration register must be connected here
	input [31:0] addr, 
	input wen,
	input [7:0] wdata,	
	input mem_valid,
	input mem_ready,
	output reg [7:0] timer_rdata,	
	output reg timer_ready //acknowledge that address has been read
);
	
parameter ADDR = 32'h0000_0000; //This parameter must be initialized during instantiation!
	

//These flags are used to write the configuration word
wire go_clear;
wire tmr_int;

wire write_conf;
assign write_conf = go_clear | tmr_int;

always @(posedge clk) begin
	if (resetn == 0) begin
		timer_rdata <= 0;
	end else if (write_conf) begin //the timer needs to update the config word
		if (tmr_int) timer_rdata[0] <= 1; // To interrupt out
		if (go_clear) timer_rdata[1] <= 0; // To GO
	end else if (mem_valid && (addr == ADDR)) begin //picorv32 needs to access the config word for r/w
		timer_ready <= (!mem_ready)? 1'b1 : 1'b0; 
		if (wen) begin
			timer_rdata <= wdata;
		end		
	end else begin
		timer_ready <= 1'b0;
	end
end

wire go;
wire en;
wire auto_load;

assign go = timer_rdata[1];
assign en = timer_rdata[2];
assign auto_load = timer_rdata[3];

timer tmr(
		.clk(clk),
		.resetn(resetn), //active (L)	
		.timer_value(timer_value), // 31 bit load value for the counter 
		.en(en), //enable (H)
		.go(go), //start (H)
		.auto_load(auto_load), //automatic restart timer after rolloff (H)		
		.tmr_int(tmr_int), //roll of - interrupt 1 pulse (H)
		.go_clear(go_clear) // 1 pulse (H)
);

endmodule
		
	
`endif


