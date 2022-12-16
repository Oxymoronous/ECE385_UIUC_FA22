//sign extend a certain slice to 16-bits
//slice length can be 5 (0->4), 6, (0->5), 9 (0->8), 11 (0->10) 


module SEXT
(
	input logic [4:0] slice_base,
	input logic slice5p1,
	input logic [2:0] slice6p3,
	input logic [1:0] slice9p2,
	output logic [15:0] sext16
);
	logic msb;
	always_comb
		begin
			msb = slice9p2[0];		//this is the leading bit that we want to sign extend
			sext16 = {msb, msb, msb, msb, msb, slice9p2, slice6p3, slice5p1, slice_base};
		end

endmodule
