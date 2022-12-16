module MDR_Register
(
input logic Clk, Reset, LD_MDR, MIO_EN,
input logic [15:0] Data_In, Data_to_CPU,
output logic [15:0] Data_Out 
);

logic [15:0] value;
assign Data_Out = value;

always_ff @ (posedge Clk or posedge Reset)
	begin
		if(Reset)
			value <= 16'h0000;
		else begin
			if (LD_MDR)
				if (MIO_EN)
					value <= Data_to_CPU;
				else
					value <= Data_In;
		end
	end

endmodule
