//handles 16bit inout
module fourtoone_mux
(
	input logic [1:0] select,
	input logic [15:0] zero, one, two, three,
	output logic [15:0] muxout
);

	assign nocares = 16'bxxxxxxxxxxxxxxxx;
	always_comb
	begin
		case (select)
			2'b00	:		muxout = zero;
			2'b01	:		muxout = one;
			2'b10	:		muxout = two;
			2'b11	:		muxout = three;
			default	:	muxout = nocares;
		endcase
	end
endmodule
