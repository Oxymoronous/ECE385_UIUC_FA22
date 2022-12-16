module ripple_adder
(
	input logic [15:0] A, B,
	input logic        cin,
	output logic [15:0] S,
	output logic       cout
);

logic c1, c2, c3;
fourbit_ripple fbr1(.A(A[3:0]), .B(B[3:0]), .Cin(cin), .S(S[3:0]), .Cout(c1));
fourbit_ripple fbr2(.A(A[7:4]), .B(B[7:4]), .Cin(c1), .S(S[7:4]), .Cout(c2));
fourbit_ripple fbr3(.A(A[11:8]), .B(B[11:8]), .Cin(c2), .S(S[11:8]), .Cout(c3));
fourbit_ripple fbr4(.A(A[15:12]), .B(B[15:12]), .Cin(c3), .S(S[15:12]), .Cout(cout));


     
endmodule
