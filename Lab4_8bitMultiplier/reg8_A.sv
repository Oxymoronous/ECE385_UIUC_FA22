module reg8_A
(
input logic Clk, CA, Reset_CALB, Shift, Shift_In, Add, Sub,//Shift_In is the 9th bit of the adder
//Reset CALB comes from state machine when RUN is pressed
input logic [7:0] Din,		//Din is passed in as the 8 bit adder sum 
output logic Shift_Out,		//passed into Shift_In for RegB 
output logic [7:0] Data_Out
);
//Register A can load from adder9 output, shift, cleared, or halt

	logic check1, check2;
	
	assign check1 = Reset_CALB | CA;
	assign check2 = Add | Sub;

	always_ff @ (posedge Clk)
	begin
		
		if(check1)
		//cleared
			Data_Out <= 8'b0;	//clearing 
		
		//shift
		else if (Shift)
			Data_Out <= {Shift_In, Data_Out[7:1]};	//Shift_In is X in this case
		
		//Loading input from adder sum
		else if (check2)
			Data_Out <= Din;
		
	end
	
	assign Shift_Out = Data_Out[0];

endmodule

