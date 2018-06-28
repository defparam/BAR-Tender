// TLP_Processor.sv
// Author: Evan Custodio 2018
//
// This module translates memory-mapped based memory requests to TLP streaming packets and vice-versa.
// At the moment it only supports 64-bit data upstream reads/writes and 32/64-bit data downstream
// reads/writes. This module was based on a similar module written for Altera-based HIP which
// is why port names seem very Altera-esque. However, rest assured this module has been ported to
// communicate to an Artix-7 based AXI PCIe core.

`timescale 1ns / 1ps
module TLP_Processor (
	input             pcie_clk,
	input             pcie_rst,
	input [12:0]      pcie_busdev,
	
	input [7:0]       rx_bar,     
	input [0:0]       rx_tlast,          
	input [0:0]       rx_tvalid,           
	output            rx_tready,           
	input [63:0]      rx_tdata,    
	
	output [0:0]      tx_tlast,               
	output [0:0]      tx_tvalid,           
	input             tx_tready,           
	output [63:0]     tx_tdata,
	output reg [7:0]  tx_tkeep,

	// memory port - upstream
	input             up_read,  // upstream completion request
	input             up_write, 
	input [4:0]       up_txtag, 
	output            up_wait,
	input [63:0]      up_address,
	input [63:0]      up_writedata,

	output reg [4:0]  up_rxtag, // upstream completion responses
	output reg [63:0] up_readdata,
	output reg        up_ack,
	output reg [2:0]  up_err,
	
	// memory port - downstream

	output reg        down_read,
	output reg        down_write,
	output reg [7:0]  down_bar,
	output reg [11:0] down_len,
	output reg [4:0]  down_rxtag,
	output reg [63:0] down_address,
	output reg [63:0] down_writedata,
	
	input [4:0]       down_compl_tag,
	input [11:0]      down_compl_len,
	input             down_compl_ack,
	input             down_compl_err,
	input [63:0]      down_readdata
);

function [31:0] byteswap32(input [31:0] data);
    byteswap32 = { data[7:0],
                 data[15:8],
                 data[23:16],
                 data[31:24]};
endfunction

`define TX_IDLE             4'h0
`define TX_MEMREAD_3DW      4'h1
`define TX_MEMREAD_4DW      4'h2
`define TX_MEMWRITE_3DW_0   4'h3
`define TX_MEMWRITE_3DW_1   4'h4
`define TX_MEMWRITE_4DW_0   4'h5
`define TX_MEMWRITE_4DW_1   4'h6
`define TX_COMPLERR_3DW     4'h7
`define TX_RCOMPL64_3DW_0   4'h8
`define TX_RCOMPL64_3DW_1   4'h9
`define TX_RCOMPL32_3DW_0   4'hB
`define TX_RCOMPL32_3DW_1   4'hC


wire        rx_eop;
wire        rx_val;
reg         rx_ready;
wire [63:0] rx_data;
reg         tx_sop;
reg         tx_eop;
reg         tx_val;
wire        tx_ready;
reg  [63:0] tx_data;

assign rx_eop    = rx_tlast[0];
assign rx_val    = rx_tvalid[0];
assign rx_tready = rx_ready;
assign rx_data   = rx_tdata;
assign tx_tlast  = tx_eop;
assign tx_tvalid = tx_val;
assign tx_ready  = tx_tready;
assign tx_tdata  = tx_data;

reg rx_sop = 1'b1;
always @(posedge pcie_clk) begin
	if (rx_tvalid && rx_tready && rx_tlast) rx_sop <= 1'b1;
	else if (rx_tvalid && rx_tready) rx_sop <= 1'b0;
	if (pcie_rst) rx_sop <= 1'b1;
end


`define UPSTREAM_DECODE if (compl_ready) begin \
	tx_sop <= 1'b1; \
	tx_eop <= 1'b0; \
	tx_val <= 1'b1; \
	compl_grab <= 1'b1; \
	compl_reqidtag_r <= {reqid_ram[compl_tag],3'b000,compl_tag}; \
	compl_readdata_r <= compl_readdata; \
	laddr_bits <= laddr_ram[compl_tag]; \
	if (compl_err || (down_compl_len > 2)) begin \
		tx_data[31:0]  <= {3'b000  ,5'b01010  ,1'b0, 3'b000, 4'b0000, 1'b0,1'b0,2'b00,2'b00,10'd0}; \
		tx_data[63:32] <= {{pcie_busdev,3'b0},3'b001,1'b0,12'h008}; \
		tx_state <= `TX_COMPLERR_3DW; \
	end \
	else if (down_compl_len == 2) begin \
		tx_data[31:0]  <= {3'b010  ,5'b01010  ,1'b0, 3'b000, 4'b0000, 1'b0,1'b0,2'b00,2'b00,10'd2}; \
		tx_data[63:32] <= {{pcie_busdev,3'b0},3'b000,1'b0,12'h008}; \
		tx_state <= `TX_RCOMPL64_3DW_0; \
	end \
	else begin \
		tx_data[31:0]  <= {3'b010  ,5'b01010  ,1'b0, 3'b000, 4'b0000, 1'b0,1'b0,2'b00,2'b00,10'd1}; \
		tx_data[63:32] <= {{pcie_busdev,3'b0},3'b000,1'b0,12'h004}; \
		tx_state <= `TX_RCOMPL32_3DW_0; \
	end \
end \
else if (upp_read & upp_ready) begin \
	tx_sop <= 1'b1; \
	tx_eop <= 1'b0; \
	tx_val <= 1'b1; \
	upp_grab <= 1'b1; \
	uppp_address <= upp_address; \
	if (~|upp_address[63:32]) begin \
		tx_data[31:0] <= {1'b0  ,2'b00  ,5'b00000  ,1'b0, 3'b000, 4'b0000, 1'b0,1'b0,2'b00,2'b00,10'd2}; \
		tx_data[63:32] <= {{pcie_busdev,3'b0},3'b0,upp_txtag,4'hF,4'hF}; \
		tx_state <= `TX_MEMREAD_3DW; \
	end else begin \
		tx_data[31:0] <= {1'b0  ,2'b01  ,5'b00000  ,1'b0, 3'b000, 4'b0000, 1'b0,1'b0,2'b00,2'b00,10'd2}; \
		tx_data[63:32] <= {{pcie_busdev,3'b0},3'b0,upp_txtag,4'hF,4'hF}; \
		tx_state <= `TX_MEMREAD_4DW; \
	end \
end \
else if (upp_write & upp_ready) begin \
	tx_sop <= 1'b1; \
	tx_eop <= 1'b0; \
	tx_val <= 1'b1; \
	upp_grab <= 1'b1; \
	uppp_address <= upp_address; \
	uppp_writedata <= upp_writedata; \
	if (~|upp_address[63:32]) begin \
		tx_data[31:0] <= {1'b0  ,2'b10  ,5'b00000  ,1'b0, 3'b000, 4'b0000, 1'b0,1'b0,2'b00,2'b00,10'd2}; \
		tx_data[63:32] <= {{pcie_busdev,3'b0},3'b0,upp_txtag,4'hF,4'hF}; \
		tx_state <= `TX_MEMWRITE_3DW_0; \
	end else begin \
		tx_data[31:0] <= {1'b0  ,2'b11  ,5'b00000  ,1'b0, 3'b000, 4'b0000, 1'b0,1'b0,2'b00,2'b00,10'd2}; \
		tx_data[63:32] <= {{pcie_busdev,3'b0},3'b0,upp_txtag,4'hF,4'hF}; \
		tx_state <= `TX_MEMWRITE_4DW_0; \
	end \
end \
else begin \
	tx_sop <= 1'b0; \
	tx_eop <= 1'b0; \
	tx_val <= 1'b0; \
	tx_state <= `TX_IDLE; \
end

reg [3:0] tx_state;
initial tx_data = 64'h0;
initial up_readdata = 64'h0;
wire             upp_read;  // upstream completion request
wire             upp_write; 
wire [4:0]       upp_txtag;
wire [63:0]      upp_address;
wire [63:0]      upp_writedata;
wire             upp_ready;
wire             rdempty_0,rdempty_1;
reg              upp_grab;
reg [63:0]       uppp_writedata;
reg [63:0]       uppp_address;
wire  [23:0]     compl_reqidtag;
wire  [11:0]     compl_len;
wire             compl_err;
wire [63:0]      compl_readdata;
reg              compl_grab;
wire             compl_ready;
reg   [23:0]     compl_reqidtag_r;
reg [63:0]       compl_readdata_r;
wire [4:0]       compl_tag;


compl_fifo cfifo (
  .clk(pcie_clk),
  .srst(pcie_rst),
  .din({down_compl_tag,down_compl_len,down_compl_err,down_readdata}),
  .wr_en(down_compl_ack),
  .rd_en(compl_grab),
  .dout({compl_tag,compl_len,compl_err,compl_readdata}),
  .full(),
  .empty(rdempty_1)
);
		
assign compl_ready = ~rdempty_1;


up_fifo ufifo (
  .clk(pcie_clk),
  .srst(pcie_rst),
  .din({up_read, up_write, up_txtag, up_address, up_writedata}),
  .wr_en(up_read | up_write),
  .rd_en(upp_grab),
  .dout({upp_read, upp_write, upp_txtag, upp_address, upp_writedata}),
  .full(up_wait),
  .empty(rdempty_0)
);
		
assign upp_ready = ~rdempty_0;

reg [4:0] laddr_ram[0:31];
reg [15:0] reqid_ram[0:31];
reg [4:0] laddr_bits;

always @(posedge pcie_clk or posedge pcie_rst) begin
	if (pcie_rst) begin
		tx_state <= `TX_IDLE;
		tx_sop <= 1'b0;
		tx_eop <= 1'b0;
		tx_val <= 1'b0;
		upp_grab <= 1'b0;
		compl_grab <= 1'b0;
		tx_tkeep <= 8'hFF;
	end else begin
	tx_tkeep <= 8'hFF;
	upp_grab <= 1'b0;
	compl_grab <= 1'b0;
	case (tx_state)
	`TX_IDLE: begin
		if (tx_ready) begin
			`UPSTREAM_DECODE
		end
	end
	`TX_RCOMPL32_3DW_0: begin
		if (tx_ready) begin
			tx_sop <= 1'b0;
			tx_eop <= 1'b1;
			tx_val <= 1'b1;
			tx_data <= {byteswap32(compl_readdata_r[31:0]),{compl_reqidtag_r,1'b0,laddr_bits,2'b00}};
			tx_state <= `TX_IDLE;
		end
	end
	`TX_RCOMPL64_3DW_0: begin
		if (tx_ready) begin
			tx_sop <= 1'b0;
			tx_eop <= 1'b0;
			tx_val <= 1'b1;
			tx_data[31:0] <= {compl_reqidtag_r,1'b0,laddr_bits,2'b00};
			tx_data[63:32] <= byteswap32(compl_readdata_r[31:0]);
			tx_state <= `TX_RCOMPL64_3DW_1;
		end
	end
	`TX_RCOMPL64_3DW_1: begin
		if (tx_ready) begin
			tx_sop <= 1'b0;
			tx_eop <= 1'b1;
			tx_val <= 1'b1;
			tx_tkeep <= 8'h0F;
			tx_data[31:0] <= byteswap32(compl_readdata_r[63:32]);
			tx_state <= `TX_IDLE;
		end
	end
	`TX_COMPLERR_3DW: begin
		if (tx_ready) begin
			tx_sop <= 1'b0;
			tx_eop <= 1'b1;
			tx_val <= 1'b1;
			tx_tkeep <= 8'h0F;
			tx_data[31:0] <= {compl_reqidtag_r,1'b0,laddr_bits,2'b00};
			tx_state <= `TX_IDLE;
		end
	end
	`TX_MEMREAD_3DW: begin
		if (tx_ready) begin
			tx_data[31:0] <= {uppp_address[31:2],2'b0};
			tx_sop <= 1'b0;
			tx_eop <= 1'b1;
			tx_val <= 1'b1;
			tx_tkeep <= 8'h0F;
			tx_state <= `TX_IDLE;
		end
	end
	`TX_MEMREAD_4DW: begin
		if (tx_ready) begin
			tx_data[63:32] <= {uppp_address[31:2],2'b0};
			tx_data[31:0] <= uppp_address[63:32];
			tx_sop <= 1'b0;
			tx_eop <= 1'b1;
			tx_val <= 1'b1;
			tx_state <= `TX_IDLE;
		end
	end
	`TX_MEMWRITE_3DW_0: begin
		if (tx_ready) begin
			tx_data[31:0] <= {uppp_address[31:2],2'b0};
			tx_data[63:32] <= byteswap32(uppp_writedata[31:0]);
			tx_sop <= 1'b0;
			tx_eop <= 1'b0;
			tx_val <= 1'b1;
			tx_state <= `TX_MEMWRITE_3DW_1;
		end
	end
	`TX_MEMWRITE_3DW_1: begin
		if (tx_ready) begin
			tx_data[31:0] <=  byteswap32(uppp_writedata[63:32]);
			tx_sop <= 1'b0;
			tx_eop <= 1'b1;
			tx_val <= 1'b1;
			tx_tkeep <= 8'h0F;
			tx_state <= `TX_IDLE;
		end
	end
	`TX_MEMWRITE_4DW_0: begin
		if (tx_ready) begin
			tx_data[31:0] <= uppp_address[63:32];
			tx_data[63:32] <= {uppp_address[31:2],2'b0};
			tx_sop <= 1'b0;
			tx_eop <= 1'b0;
			tx_val <= 1'b1;
			tx_state <= `TX_MEMWRITE_4DW_1;
		end
	end
	`TX_MEMWRITE_4DW_1: begin
		if (tx_ready) begin
			tx_data <= {byteswap32(uppp_writedata[63:32]),byteswap32(uppp_writedata[31:0])};
			tx_sop <= 1'b0;
			tx_eop <= 1'b1;
			tx_val <= 1'b1;
			tx_state <= `TX_IDLE;
		end
	end
	default: tx_state <= `TX_IDLE;
	endcase
	
	end
end



`define RX_IDLE             4'h0
`define RX_COMPID_HEADER    4'h1
`define RX_COMPID_DATA      4'h2
`define RX_MEMREAD_3DW      4'h3
`define RX_MEMREAD_4DW      4'h4
`define RX_MEMWRITE_3DW_0   4'h5
`define RX_MEMWRITE_3DW_1   4'h6
`define RX_MEMWRITE_4DW_0   4'h7
`define RX_MEMWRITE_4DW_1   4'h8

reg [3:0] rx_state;

`define DOWNSTREAM_DECODE if (rx_val & rx_ready & rx_sop) begin \
case (rx_data[31:24]) \
{3'b010,5'b01010}: /* Completion w/data */ \
begin \
	if (rx_data[9:0] != 10'd2) begin /* only 64-bit accesses at this time */ \
		up_ack   <= 1'b1; \
		up_err   <= 3'b111; /* set error bits */ \
		rx_state <= `RX_IDLE; \
	end \
	else rx_state <= `RX_COMPID_HEADER; \
end \
{3'b000,5'b01010}: /* Completion wo/data (Most likely completion error) */ \
begin \
	up_err   <= rx_data[15+32:13+32]; /* set error bits */ \
	up_ack   <= 1'b1; \
	rx_state <= `RX_IDLE; \
end \
{3'b010,5'b00000}: /* Memory Write Request 3DW (32-bit) */ \
begin \
	down_bar   <= rx_bar; \
	down_len   <= rx_data[11:0]; \
	down_rxtag <= rx_data[44:40]; \
	rx_state   <= `RX_MEMWRITE_3DW_0; \
end \
{3'b000,5'b00000}: /* Memory Read Request 3DW (32-bit) */ \
begin \
	down_bar   <= rx_bar; \
	down_len   <= rx_data[11:0]; \
	down_rxtag <= rx_data[44:40]; \
	reqid_ram[rx_data[44:40]] <= rx_data[63:48]; \
	rx_state   <= `RX_MEMREAD_3DW; \
end \
{3'b011,5'b00000}: /* Memory Write Request 4DW (64-bit) */ \
begin \
	down_bar   <= rx_bar; \
	down_len   <= rx_data[11:0]; \
	down_rxtag <= rx_data[44:40]; \
	rx_state   <= `RX_MEMWRITE_4DW_0; \
end \
{3'b001,5'b00000}: /* Memory Read Request 4DW (64-bit) */ \
begin \
	down_bar   <= rx_bar; \
	down_len   <= rx_data[11:0]; \
	down_rxtag <= rx_data[44:40]; \
	reqid_ram[rx_data[44:40]] <= rx_data[63:48]; \
	rx_state   <= `RX_MEMREAD_4DW; \
end \
default: \
begin \
	/* All others unsupported, may need to send unsupported request completion */ \
	/* However, hoping unlikely to get other TLP types, otherwise TLP timeout */ \
	rx_state   <= `RX_IDLE; \
end \
endcase \
end else rx_state   <= `RX_IDLE;

always @(posedge pcie_clk or posedge pcie_rst) begin
	if (pcie_rst) begin
		rx_state <= `RX_IDLE;
		rx_ready <= 1'b1;
		up_err <= 0;
		up_ack <= 1'b0;
		up_rxtag <= 0;
		down_bar <= 8'h00;
		down_len <= 12'h000;
		down_rxtag <= 5'h0;
		down_read <= 1'b0;
		down_write <= 1'b0;
		down_address <= 32'h0;
		down_writedata <= 32'h0;
	end else begin
	up_ack <= 1'b0;
	down_read <= 1'b0;
	down_write <= 1'b0;
	case (rx_state)
	`RX_IDLE: begin
		rx_ready <= 1'b1;
		up_err <= 0;
		`DOWNSTREAM_DECODE
	end
	`RX_MEMREAD_3DW: begin
		if (rx_val & rx_ready) begin
			down_read <= 1'b1;
			down_address <= {32'h0000_0000,rx_data[31:2],2'b00};
			`DOWNSTREAM_DECODE
		end
	end
	`RX_MEMREAD_4DW: begin
		if (rx_val & rx_ready) begin
			down_read <= 1'b1;
			down_address <= {rx_data[31:0],rx_data[63:34],2'b00};
			`DOWNSTREAM_DECODE
		end
	end
	`RX_MEMWRITE_3DW_0: begin
		if (rx_val & rx_ready) begin
		    down_address <= {32'h0000_0000,rx_data[31:2],2'b00};
			down_writedata[31:0] <= byteswap32(rx_data[63:32]);
			if (down_len == 2) begin
				rx_state   <= `RX_MEMWRITE_3DW_1;
			end
			else if (down_len == 1) begin
				down_write <= 1'b1;
				`DOWNSTREAM_DECODE
			end
			else rx_state   <= `RX_IDLE;
		end
	end
	`RX_MEMWRITE_3DW_1: begin
		if (rx_val & rx_ready) begin
			down_write <= 1'b1;
			down_writedata[63:32] <= byteswap32(rx_data[31:0]);
			`DOWNSTREAM_DECODE
		end
	end
	`RX_MEMWRITE_4DW_0: begin
		if (rx_val & rx_ready) begin
			down_address <= {rx_data[31:0],rx_data[63:34],2'b00};
			rx_state   <= `RX_MEMWRITE_4DW_1;
		end
	end
	`RX_MEMWRITE_4DW_1: begin
		if (rx_val & rx_ready) begin
			down_write <= 1'b1;			
			if (down_len == 2) begin
				down_writedata <= {byteswap32(rx_data[63:32]),byteswap32(rx_data[31:0])};
			end
			else if (down_len == 1) begin
				down_writedata[31:0] <= byteswap32(rx_data[31:0]);
			end
			`DOWNSTREAM_DECODE
		end
	end
	`RX_COMPID_HEADER: begin
		if (rx_val & rx_ready) begin
			up_rxtag <= rx_data[12:8];
			up_readdata[31:0] <= byteswap32(rx_data[63:32]);
			rx_state   <= `RX_COMPID_DATA;
		end
	end
	`RX_COMPID_DATA: begin
		if (rx_val & rx_ready) begin
			up_readdata[63:32] <= byteswap32(rx_data[31:0]);
			up_ack <= 1'b1;
			`DOWNSTREAM_DECODE
		end
	end

	default: `DOWNSTREAM_DECODE
	endcase
	if (down_read) laddr_ram[down_rxtag] <= down_address[6:2];
	end
end
endmodule