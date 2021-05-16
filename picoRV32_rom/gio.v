//gio.v

`ifndef GIO_V
`define GIO_V

/* output is a standard digital output to be connected to the PICORV32 native memory interface
 * 
 */

module ioport(
	input clk,
	input [31:0] addr, 
	input [WIDTH-1:0] wdata,	
	input wen, 
	input resetn, 	
	input mem_valid,
	input mem_ready,
	output reg mem_port_ready,
	output reg [WIDTH-1:0] odata 
);
	parameter ADDR = 32'h0000_0000; //This parameter must be initialized during instantiation!
	parameter WIDTH = 8;		

    always @(posedge clk) begin
		if (resetn == 1'b0) begin
			odata <= 0;
			mem_port_ready <= 0;			
		end else if (mem_valid && (addr == ADDR)) begin
			mem_port_ready <= (!mem_ready)? 1'b1 : 1'b0; //activates only 1 cycle and only if another device has not already activated mem_ready!
			if (wen) begin
				odata <= wdata;
			end
		end else begin
			mem_port_ready <= 1'b0; 
		end				
    end    
endmodule

`endif
