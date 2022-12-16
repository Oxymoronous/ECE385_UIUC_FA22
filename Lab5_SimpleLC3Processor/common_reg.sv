//R0 to R7 for register unit (unused)
module common_reg
(
	input logic Clk,
	input logic LD_REG,
	input logic [15:0] Data_In,
	output logic [15:0] Data_Out
);
	always_ff @ (posedge Clk)
		begin
			if (LD_REG)
				Data_Out <= Data_In;
		end
		
endmodule
