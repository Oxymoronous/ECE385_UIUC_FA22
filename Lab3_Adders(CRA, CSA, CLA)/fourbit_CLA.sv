//Generates P4 ... P0 and G4 ... G0
module fourbit_CLA
(input logic [3:0] A, B,
input logic Cin,
output logic [3:0] Propagate, Generate,
output logic PG, GG);

	always_comb
		begin
			Propagate[0] = A[0] ^ B[0];
			Propagate[1] = A[1] ^ B[1];
			Propagate[2] = A[2] ^ B[2];
			Propagate[3] = A[3] ^ B[3];
			
			Generate[0] = A[0] & B[0];
			Generate[1] = A[1] & B[1];
			Generate[2] = A[2] & B[2];
			Generate[3] = A[3] & B[3];
			
			PG = Propagate[0] & Propagate[1] & Propagate[2] & Propagate[3];
			GG = Generate[3] | (Generate[2] & Propagate[3]) | (Generate[1] & Propagate[3] & Propagate[2]) | (Generate[0] & Propagate[3] & Propagate[2] & Propagate[1]);
		end
	
endmodule
