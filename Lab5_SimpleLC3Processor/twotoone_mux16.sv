module twotoone_mux16
(
	input logic select,
	input logic [15:0] zero, one,
	output logic [15:0] mux_out
);

always_comb
	begin
		case (select)
			1'b0	:	mux_out = zero;
			1'b1	:	mux_out = one;
			default	:	;
		endcase
	end

endmodule
