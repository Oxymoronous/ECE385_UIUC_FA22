module ben_reg
(
input logic Clk, Reset, ben_in, LD_BEN,
output logic ben_out
);

always_ff @ (posedge Clk or posedge Reset)
	begin
		if (Reset)
			ben_out <= 1'b0;
		else
			if (LD_BEN)
				ben_out <= ben_in;
	end

endmodule
