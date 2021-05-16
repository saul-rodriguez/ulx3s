`ifndef UART_V
`define UART_V
 
 /*
  * This code was originally found at https://www.nandland.com/vhdl/modules/module-uart-serial-port-rs232.html
  * Slight modifications are done in order to improve readability and wrappers have been written in order to
  * facilitate integration with the PICORV32 
 */
 
module UART_TX 
   (
   input       i_Rst_L,
   input       i_Clock,
   input       i_TX_DV,		//control signal to start transmission
   input [7:0] i_TX_Byte,
   input [11:0] i_Clk_per_bit, // clk_frequency / bit_rate
   output reg  o_TX_Active_L, //output remains L during transmission
   output reg  o_TX_Serial,
   output reg  o_TX_Done
   );
 
  localparam IDLE         = 3'b000;
  localparam TX_START_BIT = 3'b001;
  localparam TX_DATA_BITS = 3'b010;
  localparam TX_STOP_BIT  = 3'b011;
  localparam CLEANUP      = 3'b100;
  
  reg [2:0] r_SM_Main;
  reg [11:0] r_Clock_Count;
  reg [2:0] r_Bit_Index;
  reg [7:0] r_TX_Data;


  // Purpose: Control TX state machine
  always @(posedge i_Clock) begin
    if (i_Rst_L == 0) begin
		r_SM_Main <= 3'b000;
		o_TX_Done <= 1'b0;
		o_TX_Active_L <= 1'b1;
    end else begin
		
		case (r_SM_Main)
			IDLE :
				begin
					o_TX_Serial   <= 1'b1;    // Drive Tx output line to High 
					o_TX_Done     <= 1'b0;	// Flag that Tx is ready to new transmission
					r_Clock_Count <= 0;
					r_Bit_Index   <= 0;
			  
					if (i_TX_DV == 1'b1) begin
						o_TX_Active_L <= 1'b0;
						r_TX_Data     <= i_TX_Byte;
						r_SM_Main     <= TX_START_BIT;
					end else
						r_SM_Main <= IDLE;
					end // case: IDLE
				
		  // Send out Start Bit. Start bit = 0
			TX_START_BIT :
				begin
					o_TX_Serial <= 1'b0;
				  
					// Wait i_Clk_per_bit-1 clock cycles for start bit to finish
					if (r_Clock_Count < i_Clk_per_bit-1) begin
						r_Clock_Count <= r_Clock_Count + 1;
						r_SM_Main     <= TX_START_BIT;
					end else begin
						r_Clock_Count <= 0;
						r_SM_Main     <= TX_DATA_BITS;
					end
				end // case: TX_START_BIT
            
		  // Wait i_Clk_per_bit-1 clock cycles for data bits to finish         
			TX_DATA_BITS :
				begin
					o_TX_Serial <= r_TX_Data[r_Bit_Index];
			  
					if (r_Clock_Count < i_Clk_per_bit-1) begin
						r_Clock_Count <= r_Clock_Count + 1;
						r_SM_Main     <= TX_DATA_BITS;
					end else begin
						r_Clock_Count <= 0;
					
						// Check if we have sent out all bits
						if (r_Bit_Index < 7) begin
							r_Bit_Index <= r_Bit_Index + 1;
							r_SM_Main   <= TX_DATA_BITS;
						end else begin
							r_Bit_Index <= 0;
							r_SM_Main   <= TX_STOP_BIT;
						end
					end 
				end // case: TX_DATA_BITS
		  
      
		  // Send out Stop bit.  Stop bit = 1
			TX_STOP_BIT :
				begin
					o_TX_Serial <= 1'b1;
			  
					// Wait i_Clk_per_bit-1 clock cycles for Stop bit to finish
					if (r_Clock_Count < i_Clk_per_bit-1) begin
						r_Clock_Count <= r_Clock_Count + 1;
						r_SM_Main     <= TX_STOP_BIT;
					end else begin
						o_TX_Done     <= 1'b1;
						r_Clock_Count <= 0;
						r_SM_Main     <= CLEANUP;
						//o_TX_Active   <= 1'b0;
					end 
				end // case: TX_STOP_BIT      
      
		  // Stay here 1 clock
			CLEANUP :
				begin
					o_TX_Done <= 1'b1;
					r_SM_Main <= IDLE;
					o_TX_Active_L   <= 1'b1;
				end		  
		  
			default :
				r_SM_Main <= IDLE;
      
		endcase
    end 
  end 
  
endmodule


module UART_RX
  (
   input            i_Rst_L,
   input            i_Clock,
   input            i_RX_Serial_asyn,
   input [11:0]		i_Clk_per_bit,	// clk_frequency / bit_rate
   output reg       o_RX_DV,		//flag Rx data valid in the output register
   output reg [7:0] o_RX_Byte
   );
   
  localparam IDLE         = 3'b000;
  localparam RX_START_BIT = 3'b001;
  localparam RX_DATA_BITS = 3'b010;
  localparam RX_STOP_BIT  = 3'b011;
  localparam CLEANUP      = 3'b100;
  
  reg [11:0] r_Clock_Count;
  reg [2:0] r_Bit_Index; //8 bits total
  reg [2:0] r_SM_Main;
    
  reg r_rx_meta;
  reg i_RX_Serial;
  
  reg [7:0] RX_Byte_temp;
  
  //Synchronize rx input
  always @(posedge i_Clock) begin	
	r_rx_meta <= i_RX_Serial_asyn;		
	i_RX_Serial <= r_rx_meta;
  end
  
  // Purpose: Control RX state machine
  always @(posedge i_Clock) begin
	if (i_Rst_L == 0) begin
		r_SM_Main <= 3'b000;
		o_RX_DV   <= 1'b0;
		o_RX_Byte <= 8'h00;
		RX_Byte_temp <= 8'h00;
    end else begin
		case (r_SM_Main)
			IDLE :
					begin
						o_RX_DV       <= 1'b0;
						r_Clock_Count <= 0;
						r_Bit_Index   <= 0;
				  
						if (i_RX_Serial == 1'b0) begin          // Start bit detected
							r_SM_Main <= RX_START_BIT;
						end else begin
							r_SM_Main <= IDLE;
						end
					end
		  
			// Check middle of start bit to make sure it's still low
			RX_START_BIT :
					begin
						if (r_Clock_Count == (i_Clk_per_bit-1)/2) begin
							if (i_RX_Serial == 1'b0) begin
								r_Clock_Count <= 0;  // reset counter, found the middle
								r_SM_Main <= RX_DATA_BITS;
							end else begin
								r_SM_Main <= IDLE;
							end
						end else begin
							r_Clock_Count <= r_Clock_Count + 1;
							r_SM_Main <= RX_START_BIT;
						end
					end 
		  
			// Wait i_Clk_per_bit-1 clock cycles to sample serial data
			RX_DATA_BITS :
					begin
						if (r_Clock_Count < i_Clk_per_bit-1) begin
							r_Clock_Count <= r_Clock_Count + 1;
							r_SM_Main <= RX_DATA_BITS;
						end else begin
							r_Clock_Count <= 0;
							RX_Byte_temp[r_Bit_Index] <= i_RX_Serial;
					
							// Check if we have received all bits
							if (r_Bit_Index < 7) begin
								r_Bit_Index <= r_Bit_Index + 1;
								r_SM_Main   <= RX_DATA_BITS;
							end else begin
								r_Bit_Index <= 0;
								r_SM_Main   <= RX_STOP_BIT;
								//o_RX_Byte <= RX_Byte_temp;
							end
						end
					end 
				
			// Receive Stop bit.  Stop bit = 1
			RX_STOP_BIT :
					begin
						// Wait i_Clk_per_bit-1 clock cycles for Stop bit to finish
						if (r_Clock_Count < i_Clk_per_bit-1) begin
							r_Clock_Count <= r_Clock_Count + 1;
							r_SM_Main     <= RX_STOP_BIT;
						end else begin
							o_RX_Byte <= RX_Byte_temp;
							o_RX_DV       <= 1'b1;  // Flag is high during 1 cycle
							r_Clock_Count <= 0;
							r_SM_Main     <= CLEANUP;
						end
					end 
		  		  
			// Stay here 1 clock
			CLEANUP :
					begin
						r_SM_Main <= IDLE;
						o_RX_DV   <= 1'b0;
					end
		  
			default :
					r_SM_Main <= IDLE;
		  
		endcase
    end 
  end 
  
endmodule // UART_RX

//This wrapper connects the UART_TX to the picorv32

module UART_TX_PICO (
	input rstn,
	input clk,	
	input [11:0] clk_per_bit,
	input [31:0] addr,
	input wen,
	input [7:0] wdata, //data to be transmited	
	input mem_valid,
	input mem_ready,
	output reg uart_tx_ready, //Acknowledge that address has been read
	output tx_uart,
	output uart_tx_int_flag //Active high when the module is IDLE (not transmitting)
);

parameter ADDR = 32'h0000_0000; // This address must be changed during instantiation!

wire start_tx;
assign start_tx = ((addr == ADDR) && mem_valid && wen)? 1'b1 : 1'b0;

always @(posedge clk) begin
	if (rstn == 0) begin
		uart_tx_ready <= 0;
	end else if (start_tx) begin
		uart_tx_ready <= (!mem_ready)? 1'b1 : 1'b0; 
	end else begin
		uart_tx_ready <= 1'b0;	
	end
end

UART_TX uart_transmitter(
	.i_Rst_L(rstn),
	.i_Clock(clk),
    .i_TX_DV(start_tx),		//control signal to start transmission
    .i_TX_Byte(wdata),
    .i_Clk_per_bit(clk_per_bit), // clk_frequency / bit_rate
    .o_TX_Active_L(uart_tx_int_flag), //output flag remains low during transmission and high when idle 
    .o_TX_Serial(tx_uart),
    .o_TX_Done()		
);

endmodule 

//This wrapper connects the UART_RX to the picorv32
module UART_RX_PICO (
	input rstn,
	input rx_uart,
	input clk,
	input [11:0] clk_per_bit,
	input [31:0] addr,		
	input ren,
	input mem_valid,
	input mem_ready,
	output [7:0] data_out,
	output uart_rx_int_flag, // 
	output reg uart_rx_ready //Acknowledge that address has been read
);
// ADDR must be passed during instantiation
parameter ADDR = 32'h00000000; 

always @(posedge clk) begin
	if (rstn == 0) begin
		uart_rx_ready <= 0;
	end else if (mem_valid && (addr == ADDR)) begin
		uart_rx_ready <= (!mem_ready)? 1'b1 : 1'b0;
	end
end

reg int_reset;
reg uart_rx_int_flag;

wire rx_ready;

UART_RX uart_receiver(
	  .i_Rst_L(rstn),
	  .i_Clock(clk),
	  .i_RX_Serial_asyn(rx_uart),
	  .i_Clk_per_bit(clk_per_bit),
      .o_RX_DV(rx_ready),
      .o_RX_Byte(data_out)
   );

always @(posedge clk) begin
	if (rstn == 0) begin
		int_reset <= 0;			
		uart_rx_int_flag <= 0;
	end else begin
		if (mem_valid && (addr == ADDR)) begin
			if (ren) begin // The data has been read, the RX interrupt flg can be cleared
				int_reset <= 1;
			end
		end 
		
		if (int_reset) begin
			uart_rx_int_flag <= 0;
			int_reset <= 0;
		end else begin
			if (rx_ready) begin // raise RX interrupt flag
				uart_rx_int_flag <= 1;
			end
		end
		
	end
end

endmodule

`endif

