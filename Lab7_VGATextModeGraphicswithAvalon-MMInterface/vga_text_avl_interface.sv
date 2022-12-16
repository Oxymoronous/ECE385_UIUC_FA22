/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define REG_PER_ROW	40
module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

//logic [31:0] LOCAL_REG       [601]; // Registers
//put other local variables here
logic [7:0] fontrom_data;
logic [9:0] dx, dy;
logic pixel_clk, blank, sync;
logic [31:0] VGA_READDATA;
logic [31:0] palette_content [8];
//Declare submodules..e.g. VGA controller, ROMS, etc
   vga_controller myvga(.Clk(CLK),       // 50 MHz clock-------------------------------INPUT----------------
                          .Reset(RESET),     // reset signal
								  //----------------OUTPUT------------------
									.hs(hs),        // Horizontal sync pulse.  Active low
								   .vs(vs),        // Vertical sync pulse.  Active low
							      .pixel_clk(pixel_clk), // 25 MHz pixel clock output
									.blank(blank),     // Blanking interval indicator.  Active low.
									.sync(sync),      // Composite Sync signal.  Active low.  We don't use it in this lab,
												             //   but the video DAC on the DE2 board requires an input for it.
									//-----------------------OUTPUT-----------------------
									.DrawX(dx),     // horizontal coordinate
								    .DrawY(dy) );   // vertical coordinate
	ocm onchip_memory(.address_a(AVL_ADDR), .address_b(vram_index), .byteena_a(AVL_BYTE_EN),
							.byteena_b(), 
							.clock(CLK),
							.data_a(AVL_WRITEDATA),
							.data_b(),
							.rden_a(AVL_READ),
	.rden_b(1'b1),
	.wren_a(AVL_WRITE),
	.wren_b(1'b0),
	.q_a(AVL_READDATA),
	.q_b(VGA_READDATA));
	
	always_ff @ (posedge CLK) begin
		//character index is from 0 to 1199
		//reserved index is from 1200 to 2047
		//palette index is from 2048 to 2055
		if (AVL_WRITE && (AVL_ADDR[11] == 1'b1) ) 
			palette_content[AVL_ADDR - 2048] <= AVL_WRITEDATA;
	end
		
//handle drawing (may either be combinational or sequential - or both).

//determine which 16x8 block we are in
int block_row, vram_index;

logic vram_code;					//only 1 bit because only 2 sections in 32 bit
logic [15:0] vram_codeN;		//changed to 16 bit per character
logic [10:0] fontrom_addr; 
logic [3:0] color_index, fgd_index, bkg_index;
logic flipcode, bitpx;

assign block_row = dy[9:4];		//right shift drawY by 4 bits = divide by 16
assign vram_index = (block_row * `REG_PER_ROW) + dx[9:4];		
																
assign vram_code = dx[3];  
//getting to the correct vram code inside the vram register
// dx[4:3] = dx divide 8 % 4 

always_comb 
begin
	unique case (vram_code)
		1'b0: begin
			//lower 16-bit of the 32 bit = code 0
			flipcode = VGA_READDATA[15];
			vram_codeN = VGA_READDATA[14:8];
			fgd_index = VGA_READDATA[7:4];
			bkg_index = VGA_READDATA[3:0];
		end
		1'b1: begin
			flipcode = VGA_READDATA[31];
			vram_codeN = VGA_READDATA[30:24];
			fgd_index = VGA_READDATA[23:20];
			bkg_index = VGA_READDATA[19:16];
		end
	endcase
	
	fontrom_addr = {vram_codeN, dy[3:0]};
	bitpx = fontrom_data[7 - dx[2:0]];
	
	if (bitpx ^ flipcode) 
		color_index = fgd_index;
	else 
		color_index = bkg_index;
end

always_ff @(posedge pixel_clk) begin 
	if (~blank) begin
		red <= 0;
		green <= 0;
		blue <= 0;
	end
	
	//we take the index divide by two to get us to the correct palette index 0 to 7
	//we take the index % 2 to know which color we are using within that selected palette 
	else if (color_index[0]) begin
		//color_index is odd number, take the higher palette
		red <= palette_content[color_index[3:1]][24:21];
		green <= palette_content[color_index[3:1]][20:17];
		blue <= palette_content[color_index[3:1]][16:13];
	end
	
	else begin
		red <= palette_content[color_index[3:1]][12:9];
		green <= palette_content[color_index[3:1]][8:5];
		blue <= palette_content[color_index[3:1]][4:1];
	end
end

font_rom myfontrom( .addr(fontrom_addr), .data(fontrom_data) );	//takes in an address and read the data in FONTROM (as output)
		
endmodule
