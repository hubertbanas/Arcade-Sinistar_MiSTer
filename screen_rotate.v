//============================================================================
//
//  Screen +90/-90 deg. rotation
//  Copyright (C) 2017,2018 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

//
// Output timings are incompatible with any TV/VGA mode.
// The output is supposed to be send to VIP scaler input.
//
// clk_out must be 4*(clk_in&ce_in) if DOUBLING is 1
//
module screen_rotate #(parameter WIDTH=320, HEIGHT=240, DEPTH=8, MARGIN=8, CCW=0, DOUBLING=1)
(
	input              clk_in,
	input              ce_in,
	
	input  [DEPTH-1:0] video_in,
	input              hblank,
	input              vblank,
	

	input              clk_out,
	output [DEPTH-1:0] video_out,
	output reg         hsync,
	output reg         vsync,
	output             de
);

localparam bufsize = WIDTH*HEIGHT;
localparam memsize = bufsize*2;
localparam aw = memsize > 131072 ? 18 : memsize > 65536 ? 17 : 16; // resolutions up to ~ 512x256

reg [aw-1:0] addr_in, addr_out;
reg we_in;
reg buff = 0;

rram #(aw, DEPTH, memsize) ram
(
	.wrclock(clk_in),
	.wraddress(addr_in),
	.data(video_in),
	.wren(en_we),
	
	.rdclock(clk_out),
	.rdaddress(addr_out),
	.q(out)
);

wire [DEPTH-1:0] out; 
reg  [DEPTH-1:0] vout,vout2;

assign video_out = vout;

wire en_we = ce_in & ~blank & en_x & en_y;
wire en_x = (xpos<WIDTH);
wire en_y = (ypos<HEIGHT);
integer xpos, ypos;

wire blank = hblank | vblank;
always @(posedge clk_in) begin
	reg old_blank, old_vblank;
	reg [aw-1:0] addr_row;

	if(en_we) begin
		addr_in <= CCW ? addr_in-HEIGHT[aw-1:0] : addr_in+HEIGHT[aw-1:0];
		xpos <= xpos + 1;
	end

	old_blank <= blank;
	old_vblank <= vblank;
	if(~old_blank & blank) begin
		xpos <= 0;
		ypos <= ypos + 1;
		addr_in  <= CCW ? addr_row + 1'd1 : addr_row - 1'd1;
		addr_row <= CCW ? addr_row + 1'd1 : addr_row - 1'd1;
	end

	if(~old_vblank & vblank) begin
		if(buff) begin
			addr_in  <= CCW ? bufsize[aw-1:0]-HEIGHT[aw-1:0] : HEIGHT[aw-1:0]-1'd1;
			addr_row <= CCW ? bufsize[aw-1:0]-HEIGHT[aw-1:0] : HEIGHT[aw-1:0]-1'd1;
		end else begin
			addr_in  <= CCW ? bufsize[aw-1:0]+bufsize[aw-1:0]-HEIGHT[aw-1:0] : bufsize[aw-1:0]+HEIGHT[aw-1:0]-1'd1;
			addr_row <= CCW ? bufsize[aw-1:0]+bufsize[aw-1:0]-HEIGHT[aw-1:0] : bufsize[aw-1:0]+HEIGHT[aw-1:0]-1'd1;
		end
		buff <= ~buff;
		ypos <= 0;
		xpos <= 0;
	end
end

assign de = ~(hsync | vbl);

reg vbl;
always @(posedge clk_out) begin
	reg old_buff, old_buff2;
	reg hs;
	reg prex = 0, prey = 0;
	reg [aw-1:0] addr_sav;
	reg [1:0] vcnt;

	integer xpos, ypos;
	
	old_buff <= buff;
	old_buff2 <= old_buff;
	
	if(old_buff2 != old_buff) begin
		addr_out <= old_buff ? {aw{1'b0}} : bufsize[aw-1:0];
		addr_sav <= old_buff ? {aw{1'b0}} : bufsize[aw-1:0];
		xpos <= 0;
		ypos <= 0;
		vsync <= 0;
		vcnt <= 0;
		vbl <= 0;
		prex <= 0;
		prey <= 0;
	end
	else begin

		if(DOUBLING) prex <= ~prex;
		if(!DOUBLING || prex) begin
			vout <= vout2;
			hsync <= (xpos >= HEIGHT);
			if((ypos<MARGIN) || (ypos>=WIDTH+MARGIN)) begin
				vout2 <= 0;
			end else begin
				vout2 <= out;
				if(xpos < HEIGHT) addr_out <= addr_out + 1'd1;
				if(xpos == HEIGHT) begin
					if(DOUBLING) begin
						prey <= ~prey;
						if(~prey) addr_out <= addr_sav;
						else addr_sav <= addr_out;
					end
				end
			end

			xpos <= xpos + 1;

			if(xpos > (HEIGHT + 2)) begin
				xpos  <= 0;
				
				if(ypos >= (WIDTH+MARGIN+MARGIN-1)) begin
					vbl <= 1;
					if(~&vcnt) vcnt <= vcnt + 1'd1;
					else vsync <= 1;
				end
				else if(~prey) ypos <= ypos + 1;
			end
		end
	end
end

endmodule

module rram #(parameter AW=16, DW=8, NW=1<<AW)
(
	input           wrclock,
	input  [AW-1:0] wraddress,
	input  [DW-1:0] data,
	input           wren,

	input	          rdclock,
	input	 [AW-1:0] rdaddress,
	output [DW-1:0] q
);

altsyncram	altsyncram_component
(
	.address_a (wraddress),
	.address_b (rdaddress),
	.clock0 (wrclock),
	.clock1 (rdclock),
	.data_a (data),
	.wren_a (wren),
	.q_b (q),
	.aclr0 (1'b0),
	.aclr1 (1'b0),
	.addressstall_a(1'b0),
	.addressstall_b(1'b0),
	.byteena_a(1'b1),
	.byteena_b(1'b1),
	.clocken0(1'b1),
	.clocken1(1'b1),
	.clocken2(1'b1),
	.clocken3(1'b1),
	.data_b({DW{1'b0}}),
	.eccstatus (),
	.q_a(),
	.rden_a (1'b1),
	.rden_b (1'b1),
	.wren_b(1'b0)
);

defparam
	altsyncram_component.address_aclr_b = "NONE",
	altsyncram_component.address_reg_b = "CLOCK1",
	altsyncram_component.clock_enable_input_a = "BYPASS",
	altsyncram_component.clock_enable_input_b = "BYPASS",
	altsyncram_component.clock_enable_output_b = "BYPASS",
	altsyncram_component.intended_device_family = "Cyclone V",
	altsyncram_component.lpm_type = "altsyncram",
	altsyncram_component.numwords_a = NW,
	altsyncram_component.numwords_b = NW,
	altsyncram_component.operation_mode = "DUAL_PORT",
	altsyncram_component.outdata_aclr_b = "NONE",
	altsyncram_component.outdata_reg_b = "UNREGISTERED",
	altsyncram_component.power_up_uninitialized = "FALSE",
	altsyncram_component.widthad_a = AW,
	altsyncram_component.widthad_b = AW,
	altsyncram_component.width_a = DW,
	altsyncram_component.width_b = DW,
	altsyncram_component.width_byteena_a = 1;

endmodule
