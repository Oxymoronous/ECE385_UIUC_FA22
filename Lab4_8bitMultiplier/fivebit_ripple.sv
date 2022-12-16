module fivebit_ripple
(input logic [4:0] A, B,
input logic Cin, 
output logic [4:0] S,
output logic Cout);

	logic c1, c2, c3, c4;
	single_rippleadder sra1(.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .CarryOut(c1));
	single_rippleadder sra2(.A(A[1]), .B(B[1]), .Cin(c1), .S(S[1]), .CarryOut(c2));
	single_rippleadder sra3(.A(A[2]), .B(B[2]), .Cin(c2), .S(S[2]), .CarryOut(c3));
	single_rippleadder sra4(.A(A[3]), .B(B[3]), .Cin(c3), .S(S[3]), .CarryOut(c4));
	single_rippleadder sra5(.A(A[4]), .B(B[4]), .Cin(c4), .S(S[4]), .CarryOut(Cout));
	
endmodule
