module nzp_reg
(
	input logic Clk, Reset, LD_CC,
	input logic n_in, z_in, p_in,
	output logic n, z, p
);

//asynchronous reset
always_ff @ (posedge Clk or posedge Reset)
	begin
		if (Reset) begin
			n <= 0; z <= 0; p <= 0;
		end
		else begin
			if (LD_CC) begin
				n <= n_in; z <= z_in; p <= p_in;
			end
		end
	end


endmodule
