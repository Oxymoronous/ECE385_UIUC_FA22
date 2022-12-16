//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Lab 5 Given Code - SLC-3 top-level (Physical RAM)
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//    Revised 06-09-2020
//	  Revised 03-02-2021
//------------------------------------------------------------------------------


module slc3(
	input logic [9:0] SW,
	input logic	Clk, Reset, Run, Continue,
	output logic [9:0] LED,
	input logic [15:0] Data_from_SRAM,
	output logic OE, WE,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3,
	output logic [15:0] ADDR,
	output logic [15:0] Data_to_SRAM
);


// An array of 4-bit wires to connect the hex_drivers efficiently to wherever we want
// For Lab 1, they will direclty be connected to the IR register through an always_comb circuit
// For Lab 2, they will be patched into the MEM2IO module so that Memory-mapped IO can take place
logic [3:0] hex_4[3:0]; 
HexDriver hex_drivers[3:0] (hex_4, {HEX3, HEX2, HEX1, HEX0});
// This works thanks to http://stackoverflow.com/questions/1378159/verilog-can-we-have-an-array-of-custom-modules

// Internal connections
logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED;
logic GatePC, GateMDR, GateALU, GateMARMUX;
logic SR2MUX, ADDR1MUX, MARMUX;
logic BEN, MIO_EN, DRMUX, SR1MUX, WR_EN;
logic [1:0] PCMUX, ADDR2MUX, ALUK;
logic [15:0] MDR_In;
logic [15:0] MAR, MDR, IR;

//--------------------------------------------------------My code-----------------------------------------------
logic [15:0] PC_Out, MARMUX_Out, ALU_Out, BUS_Data;		//MDR_Out == MDR
logic [1:0] busmux_select;	//select for MARMUX/PC/ALU/MDR to go onto databus

Gate_Decoder  busdecoder(.GateMARMUX(GateMARMUX), .GatePC(GatePC),.GateALU(GateALU), .GateMDR(GateMDR),
									.GateSelect(busmux_select));
									
fourtoone_mux busdriver(.select(busmux_select), .zero(MARMUX_Out), .one(PC_Out), .two(ALU_Out), .three(MDR),
								.muxout(BUS_Data));
								

//--------------------------------------------------------End of my code-----------------------------------------------

// Connect MAR to ADDR, which is also connected as an input into MEM2IO
//	MEM2IO will determine what gets put onto Data_CPU (which serves as a potential
//	input into MDR)
assign ADDR = MAR; 
assign MIO_EN = OE;
assign WRITE_ENABLE = WE;

always_comb
	begin
		if (LD_LED) begin
			LED[1:0] = IR[11:10];
			LED[9:2] = IR[7:0];
		end
		else
			LED[9:0] = 10'b0000000000;
	end

// Connect everything to the data path (you have to figure out this part)
datapath d0 (.Clk(Clk), .Reset(Reset), .Run(Run), .LD_IR(LD_IR), .LD_MAR(LD_MAR), 
				.LD_PC(LD_PC), .LD_MDR(LD_MDR), .LD_CC(LD_CC), .LD_BEN(LD_BEN), .LD_REG(LD_REG),
			.MIO_EN(MIO_EN), 
			.data_in(BUS_Data), //output from busdriver as input
			.Data_to_CPU(MDR_In),	//output from Mem2IO as input
			.pcmux_select(PCMUX),	//input
			.sr1mux_select(SR1MUX), .drmux_select(DRMUX),
			.addr2mux_select(ADDR2MUX), .addr1mux_select(ADDR1MUX),
			.sr2mux_select(SR2MUX), .ALUK_select(ALUK),
			.BEN_Out(BEN),
			
			.IR_Out(IR), .MAR_Out(MAR),		//MAR is different from MARMUX_Out
														//dummy outputs
			.MARMUX_Out(MARMUX_Out), .ALU_Out(ALU_Out), .PC_Out(PC_Out), .MDR_Out(MDR));

// Our SRAM and I/O controller (note, this plugs into MDR/MAR)

Mem2IO memory_subsystem(
    .*, .Reset(Reset), .ADDR(ADDR), .Switches(SW),
    .HEX0(hex_4[0][3:0]), .HEX1(hex_4[1][3:0]), .HEX2(hex_4[2][3:0]), .HEX3(hex_4[3][3:0]),	//these are outputs
    .Data_from_CPU(MDR), .Data_to_CPU(MDR_In),
    .Data_from_SRAM(Data_from_SRAM), .Data_to_SRAM(Data_to_SRAM)
);

// State machine, you need to fill in the code here as well (do not need to change for week 1)
ISDU state_controller(
	.*, .Reset(Reset), .Run(Run), .Continue(Continue),
	.Opcode(IR[15:12]), .IR_5(IR[5]), .IR_11(IR[11]),
   .Mem_OE(OE), .Mem_WE(WE)
);

// SRAM WE register
//logic SRAM_WE_In, SRAM_WE;
////// SRAM WE synchronizer
//always_ff @(posedge Clk or posedge Reset_ah)
//begin
//	if (Reset_ah) SRAM_WE <= 1'b1; //resets to 1
//	else 
//		SRAM_WE <= SRAM_WE_In;
//end
	
endmodule
