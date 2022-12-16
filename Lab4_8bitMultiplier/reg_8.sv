module reg8_B
(
input logic Clk, Shift, Shift_In, Load,
input logic [7:0] Din,
output logic [7:0] Data_Out
);
//Register B can load input from switches, do shifting when XA is shifting
//Stop shifting when AB has the result
	always_ff @ (posedge Clk)
	begin
		if (Shift)
			Data_Out <= {Shift_In,Data_Out[7:1]};	//Shift_In comes from regA lowest bit
		else if (Load)
			//only when CALB button is pressed, comes from the adder
			Data_Out <= Din;
		
	end

endmodule


