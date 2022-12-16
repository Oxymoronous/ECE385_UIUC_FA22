//logic unit directly to databus
module branch_logic
(
	input logic [15:0] data_in,
	output logic n, z, p
);

	always_comb
		begin
			if (data_in[15]) begin
				z = 0;
				p = 0;
				n = 1;
			end
			
			else begin
			//MSB is zero
			n = 0;
				if (data_in == 16'h0000)
				begin
					z = 1;
					p = 0;
				end
				else
				begin
					z = 0;
					p = 1;
				end
			end
		end 

endmodule
