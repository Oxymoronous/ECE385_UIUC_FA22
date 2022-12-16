//inout are 3 bitlength, mainly for register unit
module twotoone_mux
(
input logic select,
input logic [2:0] zero, one,
output logic [2:0] mux_out
);

always_comb
	begin
		case (select)
			1'b0	:	mux_out = zero;
			1'b1	:	mux_out = one;
		default	:	mux_out = zero;
		endcase
	end

endmodule
