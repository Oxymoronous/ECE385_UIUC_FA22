module single_CLA
(input logic [3:0] A, B, Cin,
output logic [3:0] S);

	always_comb
		begin
			S[0] = A[0] ^ B[0] ^ Cin[0];
			S[1] = A[1] ^ B[1] ^ Cin[1];
			S[2] = A[2] ^ B[2] ^ Cin[2];
			S[3] = A[3] ^ B[3] ^ Cin[3];
		end

endmodule
