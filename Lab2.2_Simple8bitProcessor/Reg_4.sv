module reg_4 (input  logic Clk, Reset, Shift_In, Load, Shift_En,
              input  logic [7:0]  D,
              output logic Shift_Out,
              output logic [7:0]  Data_Out);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			  Data_Out <= 8'h0;
		 else if (Load)
			  Data_Out <= D;
		 else if (Shift_En)
		 begin
			  //concatenate shifted in data to the previous left-most 3 bits
			  //note this works because we are in always_ff procedure block
			  Data_Out <= { Shift_In, Data_Out[7:1] }; 
	    end
    end
	
    assign Shift_Out = Data_Out[0];

endmodule


module reg8_B
(
input logic Clk, Reset_CALB, Shift, Shift_In,
input logic [7:0] Din,
output logic Shift_Out, 
output logic [7:0] Data_Out);
);

	always_ff @ (posedge Clk)
	begin
		if(Reset_CALB)
			Data_Out <= Din;	//this corresponds to SW
		else
		begin
			Data_Out <= {Shift_In, Data_Out[7:1]};	//Shift_In comes from regA lowest bit
		end
	end
	
	assign Shift_Out = Data_Out[0];		//discarded and nt used

endmodule


module reg8_A
(
input logic Clk, Reset_CALB, Shift, Shift_In,
input logic [7:0] Din, 
output logic Shift_Out,		//passed into Shift_In for RegB 
output logic [7:0] Data_Out,  
output logic X				
);

	always_ff @ (posedge Clk)
	begin
		if(Reset_CALB)
		begin
			Data_Out <= 8'b0;	//clearing A
			X <= 0;
		end
		else
		begin
			Data_Out <= {Shift_In, Data_Out[7:1]};	//Shift_In is X in this case
			X <= Shift_In;
		end
	end
	
	assign Shift_Out = Data_Out[0];

endmodule
