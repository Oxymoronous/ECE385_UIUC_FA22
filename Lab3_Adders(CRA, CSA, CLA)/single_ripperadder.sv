module single_rippleadder (input logic A, B, Cin,
									output logic S, CarryOut);
	always_comb
	begin
		S = A ^ B ^ Cin;
		CarryOut = (A&B) | (B&Cin) | (A&Cin);
	end
	
endmodule
