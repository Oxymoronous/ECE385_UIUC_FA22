module PC_Register
(
input logic Clk, Reset, LD_PC,	//LD_PC comes from ISDU
input logic [15:0] Data_In, //comes from PCMUX
output logic [15:0] Data_Out, 
output logic [15:0] Next_PC
); 
	
	always_ff @ (posedge Clk or posedge Reset)
   begin
		if(Reset) //notice, this is an asynchronous reset, which is recommended on the FPGA
			Data_Out <= 16'h0;
		else
			if (LD_PC)
				Data_Out <= Data_In;
    end
	 
	 
	 assign Next_PC = Data_Out + 1;
endmodule


