// Mem_Accessor.sv
// Author: Evan Custodio 2018
//
// <Fill Out Description>
`timescale 1ns / 1ps
module Mem_Accessor (
	input                 user_clk,
	input                 user_reset,
	// memory port - upstream
	output reg            up_read,  // upstream completion request
	output reg            up_write, 
	output reg [4:0]      up_txtag, 
	input                 up_wait,
	output     [63:0]     up_address,
	output reg [63:0]     up_writedata,

	input [4:0]           up_rxtag, // upstream completion responses
	input [63:0]          up_readdata,
	input                 up_ack,
	input [2:0]           up_err,
	
	// memory port - downstream
	input                 down_read,
	input                 down_write,
	input [7:0]           down_bar,
	input [11:0]          down_len,
	input [4:0]           down_rxtag,
	input [63:0]          down_address,
	input [63:0]          down_writedata,
	
	output reg [4:0]      down_compl_tag,
	output reg [11:0]     down_compl_len,
	output reg            down_compl_ack,
	output reg            down_compl_err,
	output reg [63:0]     down_readdata,
	
	output reg            cfg_interrupt,
	input                 cfg_interrupt_rdy,
	output reg [7:0]      cfg_interrupt_di

);

initial up_read = 0;
initial up_write = 0;
initial up_txtag = 0;
initial up_writedata = 64'h0;
initial down_compl_tag = 0;
initial down_compl_len = 0;
initial down_compl_ack = 0;
initial down_compl_err = 0;
initial down_readdata = 64'h0;

reg  [63:0] up_addr = 0;
reg  [4:0]  up_rxtag_r = 0;
reg  [2:0]  up_err_r = 0;
wire        up_sent;
reg [63:0]  up_readdata_r = 64'h0;

reg [63:0]  SCRATCH = 0;
reg [63:0]  VER_REG = 64'h00c0fefe_00000001;
reg         in_progress=0;

always @(posedge user_clk) begin
	down_compl_ack <= 1'b0;
	down_compl_err <= 1'b0;
	up_txtag       <= 0;
	up_read        <= 0;
	up_write       <= 0;
	if (down_read) begin
		// synthesis translate_off
		//$display("RTL READ ADDR: 0x%x - BAR: 0x%x - LEN: %d - TAG: 0x%x",down_address,down_bar,down_len,down_rxtag);
		// synthesis translate_on 
		down_compl_len       <= down_len;
		down_compl_tag       <= down_rxtag;
		down_compl_ack       <= 1'b1;
		case (down_address[11:0])
		    'h0: down_readdata   <= VER_REG;
		    'h4: down_readdata   <= {32'h0,VER_REG[63:32]};
		    'h8: down_readdata   <= SCRATCH;
		    'hC: down_readdata   <= {32'b0,SCRATCH[63:32]};
		    'h10: down_readdata  <= up_addr;
		    'h14: down_readdata  <= {32'b0,up_addr[63:32]};
		    'h18: down_readdata  <= up_writedata;
		    'h1c: down_readdata  <= {32'b0,up_writedata[63:32]};
		    'h20: down_readdata  <= up_readdata_r;
		    'h24: down_readdata  <= {32'b0,up_readdata_r[63:32]};
		    'h30: down_readdata  <= {48'h0,7'b0,up_rxtag_r,in_progress,up_err_r};
		    'h34: down_readdata  <= 64'b0;
			'h40: down_readdata  <= {32'h0,16'h0,4'h0,cfg_interrupt_di,3'h0,cfg_interrupt};
		default: begin
			down_readdata    <= 64'hFFFFFFFFFFFFFFFF;
			down_compl_err   <= 1'b0;
		end
		endcase
		if (down_len > 2) down_compl_err <= 1;
	end
	else if (down_write) begin
		// synthesis translate_off
		//$display("RTL WRITE ADDR: 0x%x - BAR: 0x%x - LEN: %d - TAG: 0x%x - WRITEDATA: 0x%x",down_address,down_bar,down_len,down_rxtag,down_writedata);
		// synthesis translate_on
		case (down_address[11:0])
		    'h8: SCRATCH <= (down_len == 2) ? down_writedata : {SCRATCH[63:32],down_writedata[31:0]};
		    'hC: SCRATCH[63:32] <= down_writedata[31:0];
		    'h10: up_addr <= (down_len == 2) ? down_writedata : {up_addr[63:32],down_writedata[31:0]};
		    'h14: up_addr[63:32] <= down_writedata[31:0];
		    'h18: up_writedata <= (down_len == 2) ? down_writedata : {up_writedata[63:32],down_writedata[31:0]};
		    'h1C: up_writedata[63:32] <= down_writedata[31:0];
		    'h28: begin {up_txtag,up_read,up_write} <= {down_writedata[8:4],down_writedata[1:0]}; in_progress <= down_writedata[1]; end
		    'h2c: up_writedata[63:32] <= down_writedata[31:0];
			'h40: begin cfg_interrupt <= down_writedata[0]; cfg_interrupt_di <= down_writedata[11:4]; end
		endcase		
	end
	
	if (cfg_interrupt_rdy) begin
		cfg_interrupt <= 0;	
	end
	
	if (up_ack) begin
		up_readdata_r <= up_readdata;
		up_rxtag_r    <= up_rxtag;
		up_err_r      <= up_err;
		in_progress   <= 0;
		cfg_interrupt <= 1'b1;
		cfg_interrupt_di <= 0;
	end
	
	if (user_reset) begin
		down_compl_ack <= 1'b0;
		down_compl_err <= 1'b0;
		SCRATCH        <= 64'h0;
		in_progress    <= 0;
		cfg_interrupt  <= 0;
		cfg_interrupt_di <= 8'h0;
	end
end

assign  up_address = up_addr;

endmodule