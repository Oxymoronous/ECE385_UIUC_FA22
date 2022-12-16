module datapath
(
	input logic Clk, Reset, Run, LD_IR, LD_MAR, LD_PC, LD_MDR, LD_CC, LD_BEN, 
	input logic LD_REG, //control signals for CP2
	input logic MIO_EN,
	input logic [15:0] data_in, //data from the databus
	input logic [15:0] Data_to_CPU,	//data from the MEM2IO
	//control signals mux selects
	input logic [1:0] pcmux_select, 
	//register unit mux selects
	input logic sr1mux_select, drmux_select,
	
	//addrmuxes selects
	input logic [1:0] addr2mux_select,
	input logic addr1mux_select,
	
	//ALU control signals
	input logic sr2mux_select,
	input logic [1:0] ALUK_select,
	
	output logic BEN_Out,
	output logic [15:0] IR_Out, MAR_Out,		//pass this out so we can put onto LEDs to see instructions
	output logic [15:0] MARMUX_Out, ALU_Out, PC_Out, MDR_Out	//these are the outputs feed on to the data bus again
);
 
 logic [15:0] LoadedIR, LoadedMAR, Next_PC, pcmux_out;
 logic [15:0] addr2mux_in0, addr2mux_in1, addr2mux_in2, addr2mux_in3;	//left to right be 0 to 3
 logic [15:0] sr2mux_in1;
 
 //for registers
 logic [2:0] sr1_muxout, dr_muxout;
 logic [15:0] regAout, regBout;
 
 //for ALU
 logic [15:0] ALUB_in;  
 
 //for ADDR muxes output
 logic [15:0] addr2mux_out, addr1mux_out, addrblock_out;
 
 //for logic unit
 logic n1, z1, p1, n2, z2, p2, ben_in, ben_out;
 
 //for SR2MUX inputs
 SEXT ext5_16(.slice_base(IR_Out[4:0]), .slice5p1(IR_Out[4]), 
					.slice6p3({IR_Out[4], IR_Out[4], IR_Out[4]}), .slice9p2({IR_Out[4], IR_Out[4]}), 
					.sext16(sr2mux_in1));
				
 //for ADDR2MUX, pin0 is assigned in always_comb block below
 SEXT ext6_16(.slice_base(IR_Out[4:0]), .slice5p1(IR_Out[5]), 
					.slice6p3({IR_Out[5], IR_Out[5], IR_Out[5]}), .slice9p2({IR_Out[5], IR_Out[5]}),
					.sext16(addr2mux_in1));
 
 SEXT ext9_16(.slice_base(IR_Out[4:0]), .slice5p1(IR_Out[5]), 
					.slice6p3(IR_Out[8:6]), .slice9p2({IR_Out[8], IR_Out[8], IR_Out[8]}),
					.sext16(addr2mux_in2));
 
 SEXT ext11_16(.slice_base(IR_Out[4:0]), .slice5p1(IR_Out[5]), 
					.slice6p3(IR_Out[8:6]), .slice9p2(IR_Out[10:9]),
					.sext16(addr2mux_in3));
					
 //muxes for register file
 twotoone_mux sr1_mux(.select(sr1mux_select), .zero(IR_Out[8:6]), .one(IR_Out[11:9]), .mux_out(sr1_muxout));
 twotoone_mux dr_mux(.select(drmux_select), .zero(IR_Out[11:9]), .one(3'b111), .mux_out(dr_muxout));
 
 //ALU
 twotoone_mux16 sr2_mux(.select(sr2mux_select), .zero(regBout), .one(sr2mux_in1), .mux_out(ALUB_in));
 
 assign addr2mux_in0 = 16'h0000;
 assign addrblock_out = addr1mux_out + addr2mux_out;
 assign nocares = 16'hxxxx;		//this is for PC mux dummy
 assign MARMUX_Out = addrblock_out;
 //muxes for addr block
 fourtoone_mux addr2mux(.select(addr2mux_select), .zero(addr2mux_in0), .one(addr2mux_in1), .two(addr2mux_in2), .three(addr2mux_in3), 
								.muxout(addr2mux_out));
								
 twotoone_mux16 addr1mux(.select(addr1mux_select), .zero(PC_Out), .one(regAout), .mux_out(addr1mux_out));
 
 //Depending on which load is HIGH, load the registers with busdata
 always_ff @ (posedge Clk)
 begin
	if (LD_IR)
		IR_Out <= data_in;
	if (LD_MAR)
		MAR_Out <= data_in;		
 end
 
 fourtoone_mux		pc_mux(.select(pcmux_select), .zero(Next_PC), .one(addrblock_out), .two(data_in), .three(nocares), //left AddrMux and nocare
						.muxout(pcmux_out));
						//lab 1: pcmux_select is always zero, so always load next_pc
						
 PC_Register pc_reg(.Clk(Clk), .Reset(Reset), .LD_PC(LD_PC), .Data_In(pcmux_out),	
				        .Data_Out(PC_Out), .Next_PC(Next_PC));
 //MDR mux is implemented within register
 MDR_Register mdr_reg(.Clk(Clk), .Reset(Reset), .LD_MDR(LD_MDR), .Data_In(data_in), .Data_to_CPU(Data_to_CPU), .MIO_EN(MIO_EN),
							.Data_Out(MDR_Out));	//passed as Data_from_CPU to Mem2IO);
 
 //CP2 code-----------------------------------------------------------------------------
 register_unit reg_file(.Clk(Clk), .LD_REG(LD_REG), .Reset(Reset), .sr1_in(sr1_muxout), .sr2_in(IR_Out[2:0]), .dr_mux(dr_muxout), .data_in(data_in), 
								.sr1_out(regAout), .sr2_out(regBout));	//SR2 always come from same part of IR
 
 ALU	alu_unit(.ALUK(ALUK_select), .sr1_in(regAout), .sr2_in(ALUB_in), .ALU_out(ALU_Out));
 
 //logic unit modules
 branch_logic logic1(.data_in(data_in), .n(n1), .z(z1), .p(p1));
 
 nzp_reg		   register_nzp(.Clk(Clk), .Reset(Reset), .LD_CC(LD_CC), .n_in(n1), .z_in(z1), .p_in(p1),
									.n(n2), .z(z2), .p(p2));
 
 instr_branch logic2(.IR_br(IR_Out[11:9]), .n_in(n2), .z_in(z2), .p_in(p2), .branch_bool(ben_in));
 
 ben_reg			register_ben(.Clk(Clk), .Reset(Reset), .ben_in(ben_in), .LD_BEN(LD_BEN), 
								.ben_out(BEN_Out));
 
 
 
endmodule
