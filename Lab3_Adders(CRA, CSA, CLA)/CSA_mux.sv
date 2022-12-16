module CSA_mux
(
input logic [4:0] adder0, adder1,
input logic select,
output logic [4:0] s
);

	always_comb
		begin
			if (select) begin
				s = adder1;
			end else begin
				s = adder0;
			end
		end

endmodule
