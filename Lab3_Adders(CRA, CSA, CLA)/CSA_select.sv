module CSA_select
(
input logic cout1, cout2, prev_cout,
output logic next_cout
);

	logic x;
	always_comb
		begin
			x = cout2 & prev_cout;
			next_cout = x | cout1;
		end

endmodule
