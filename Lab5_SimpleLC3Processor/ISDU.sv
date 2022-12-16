//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic[3:0]    Opcode, 
				input logic         IR_5,
				input logic         IR_11,
				input logic         BEN,
				  
				output logic        LD_MAR,
									LD_MDR,
									LD_IR,
									LD_BEN,
									LD_CC,
									LD_REG,
									LD_PC,
									LD_LED, // for PAUSE instruction
									
				output logic        GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
									
				output logic [1:0]  PCMUX,
				output logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
				output logic [1:0]  ADDR2MUX,
									ALUK,
				  
				output logic        Mem_OE,
									Mem_WE
				);

	enum logic [4:0] {  Halted, 
						S_18, 
						S_33_1, 
						S_33_2, 		//4
						S_33_1p2,
						S_33_1p3,
						S_35, 
						S_32, 		//8
						S_01, S_02, S_03, S_04, S_05, S_06, S_07, S_08,	//16
						BRANCHOUT, JSR2, MYREAD1, MYREAD2, MYREAD3_ANDLOAD, MDR_DR,	//22
						STR2, STR3, Storing2, Storing3,		//26 states
						
						Pause_IR1, Pause_IR2
						
						}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		LD_MAR = 1'b0;
		LD_MDR = 1'b0;
		LD_IR = 1'b0;
		LD_BEN = 1'b0;
		LD_CC = 1'b0;
		LD_REG = 1'b0;
		LD_PC = 1'b0;
		LD_LED = 1'b0;
		 
		GatePC = 1'b0;
		GateMDR = 1'b0;
		GateALU = 1'b0;
		GateMARMUX = 1'b0;
		 
		ALUK = 2'b00;
		 
		PCMUX = 2'b00;
		DRMUX = 1'b0;
		SR1MUX = 1'b0;
		SR2MUX = 1'b0;
		ADDR1MUX = 1'b0;
		ADDR2MUX = 2'b00;
		 
		Mem_OE = 1'b0;
		Mem_WE = 1'b0;
	
		// Assign next state
		unique case (State)
			Halted : 
				if (Run) 
					Next_state = S_18;                      
			S_18 : 
				Next_state = S_33_1;
			// Any states involving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			S_33_1 : 
				Next_state = S_33_1p2;
			S_33_1p2:
				Next_state = S_33_1p3;
			S_33_1p3 :
				Next_state = S_33_2;
			S_33_2 : 
				Next_state = S_35;
			S_35 : 
				Next_state = S_32;		//CP1 goes pause, CP2 goes S_32
//			// PauseIR1 and PauseIR2 are only for Week 1 such that TAs can see 
//			// the values in IR.
//			PauseIR1 : 
//				if (~Continue) 
//					Next_state = PauseIR1;
//				else 
//					Next_state = PauseIR2;
//			PauseIR2 : 
//				if (Continue) 
//					Next_state = PauseIR2;
//				else 
//					Next_state = S_18;
			S_32 : 
				case (Opcode)
					4'b0001	:	Next_state = S_01;	//ADD (this was given)
					4'b0101	:	Next_state = S_02;	//AND
					4'b1001	:	Next_state = S_03;	//NOT
					4'b0000	:	Next_state = S_04;	//Branch
					4'b1100	:	Next_state = S_05;	//JMP
					4'b0100	:	Next_state = S_06;	//JSR
					4'b0110	:	Next_state = S_07;	//LDR 
					4'b0111	:	Next_state = S_08;	//STR
					4'b1101	:	Next_state = Pause_IR1;	//Pause
					default : 
						Next_state = S_18;	//if invalid opcode is entered, we reset to the start state
				endcase
			S_01, S_02, S_03, S_05: 
				Next_state = S_18;
			
			//BRANCH starts
			S_04	:	
				if (BEN)
					Next_state = BRANCHOUT;
				else
					Next_state = S_18;
			BRANCHOUT : 
				Next_state = S_18;
			
			//JSR
			S_06 : 		
				Next_state = JSR2;
			JSR2 : 
				Next_state = S_18;
			
			//LDR, 3 read states, 1 final step
			S_07 :		
				Next_state = MYREAD1;
			MYREAD1 : 
				Next_state = MYREAD2;
			MYREAD2 :
				Next_state = MYREAD3_ANDLOAD;
			MYREAD3_ANDLOAD :
				Next_state = MDR_DR;
			MDR_DR :
				Next_state = S_18;
			
			//STR
			S_08 : 
				Next_state = STR2;
			STR2 : 
				Next_state = STR3;
			STR3 : 	//subsequent 3 states are to ensure write
				Next_state = Storing2;
			Storing2 : 
				Next_state = Storing3;
			Storing3 : 
				Next_state = S_18;
			
			//Pause
			Pause_IR1 : 
				if (~Continue)
					Next_state = Pause_IR1;
				else
					Next_state = Pause_IR2;
			Pause_IR2 : 
				if (Continue)
					Next_state = Pause_IR2;
				else
					Next_state = S_18;

			default : ;

		endcase
		
		// Assign control signals based on current state
		case (State)
			Halted: ;
			S_18 : 
				begin 
					GatePC = 1'b1;
					LD_MAR = 1'b1;		
					PCMUX = 2'b00;
					LD_PC = 1'b1;		
				end
			S_33_1, S_33_1p2, S_33_1p3, MYREAD1, MYREAD2: 			//counter : 7 states
				Mem_OE = 1'b1;
			S_33_2 : 
				begin 
					Mem_OE = 1'b1;
					LD_MDR = 1'b1;
				end
			S_35 : 
				begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
				end
			S_32 : 							//counter 12 states
				LD_BEN = 1'b1;
			S_01 : 	//ADD
				begin 
					SR2MUX = IR_5;	//handles (ADDi)
					ALUK = 2'b00;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					//incomplete
					LD_CC = 1'b1;
				end
			//------------------------------------------------------------------------------
			S_02 : //AND
				begin 
					SR2MUX = IR_5; //handles ANDi
					ALUK = 2'b01;	//handles which op
					GateALU = 1'b1;
					LD_REG = 1'b1;
					// incomplete...
					LD_CC = 1'b1;
				end
			S_03 : //NOT (always NOT A only)
				begin 
					//SR2_MUX is no care because it connects RegB
					ALUK = 2'b10;	//handles which op
					GateALU = 1'b1;
					LD_REG = 1'b1;
					// incomplete...
					LD_CC = 1'b1;
				end
			S_04 :	;//------------------------------------------------------branch
			BRANCHOUT:
				begin
					//branch condition is satisfied
					ADDR2MUX = 2'b10;
					ADDR1MUX = 1'b0;
					PCMUX = 2'b01;
					LD_PC = 1'b1;
					LD_MAR = 1'b1;
					GatePC = 1'b1;		//PC is driving the branch
				end
			S_05 : 
				begin 
					ADDR2MUX = 2'b01;	//zero extended
					ADDR1MUX = 1'b1;	//gets input  from register
					SR1MUX = 1'b0;
					PCMUX = 2'b01;	//loads into Rval into PC
					LD_PC = 1'b1;
				end
			//--------------------------------------------------------------------------- JSR
			S_06 : 
				begin 
					GatePC = 1'b1;
					LD_REG = 1'b1;
					DRMUX = IR_11;	//force Load PC into R7
				end
			JSR2 : 
				begin 
					//PC + offset11 into PC
					ADDR1MUX = 1'b0;
					ADDR2MUX = 2'b11;
					PCMUX = 2'b01;
					LD_PC = 1'b1;
					//no gates should be open here
				end
			//--------------------------------------------------------------------------LDR
			S_07 : 
				begin
					//Base register + off6 into MAR
					ADDR1MUX = 1'b1;
					ADDR2MUX = 2'b01;
					SR1MUX = 1'b0;
					GateMARMUX = 1'b1;
					LD_MAR = 1'b1;
				end
			MYREAD3_ANDLOAD :	//second step of LDR
				begin
					LD_MDR = 1'b1;
					Mem_OE = 1'b1;
				end
			MDR_DR	:	//last step of LDR
				begin
					GateMDR = 1'b1;	//Gate drives MDR
					DRMUX = 1'b0;
					LD_CC = 1'b1;
					LD_REG = 1'b1;
				end
			//---------------------------------------------------------------------------STR
			S_08:				// MAR   <-BaseR + off6
				begin
					SR1MUX = 1'b0;
					ADDR1MUX = 1'b1;	//taking from register
					ADDR2MUX = 2'b01;
					GateMARMUX = 1'b1;
					LD_MAR = 1'b1;
				end
			STR2 : 			//  MDR  <--- SR
				begin
					SR1MUX = 1'b1;
					ALUK = 2'b11;	//this will passA
					GateALU = 1'b1;	//ALU drives the bus
					LD_MDR = 1'b1;
					Mem_OE = 1'b0;	//this loads MDR with the databus input
				end
			STR3, Storing2, Storing3 : 
				begin 
					Mem_WE = 1'b1;	//writing to memory and want to hold
				end
			Pause_IR1, Pause_IR2 : 
				LD_LED = 1;

			default : ;
		endcase
	end 

	
endmodule
