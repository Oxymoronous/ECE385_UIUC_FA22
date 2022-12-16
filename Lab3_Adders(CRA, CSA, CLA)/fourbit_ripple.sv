module fourbit_ripple
(input logic [3:0] A, B,
input logic Cin, 
output logic [3:0] S,
output logic Cout);

	logic c1, c2, c3;
	single_rippleadder sra1(.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .CarryOut(c1));
	single_rippleadder sra2(.A(A[1]), .B(B[1]), .Cin(c1), .S(S[1]), .CarryOut(c2));
	single_rippleadder sra3(.A(A[2]), .B(B[2]), .Cin(c2), .S(S[2]), .CarryOut(c3));
	single_rippleadder sra4(.A(A[3]), .B(B[3]), .Cin(c3), .S(S[3]), .CarryOut(Cout));
	
endmodule
