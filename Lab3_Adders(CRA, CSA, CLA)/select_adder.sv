module select_adder (
	input logic [8:0] A, B,
	input logic        cin,
	output logic [8:0] S,
	output logic     cout
);

	logic c4;
	logic zero, one;
	logic B0_carry, B1_carry;
	logic [4:0] B0_s, B1_s;
	
	assign zero = 1'b0;
	assign one = 1'b1;
	fourbit_ripple fourbit_A1(.A(A[3:0]), .B(B[3:0]), .Cin(cin), .S(S[3:0]), .Cout(c4));
	
	fivebit_ripple fivebit_B0(.A(A[8:4]), .B(B[8:4]), .Cin(zero), .S(B0_s[4:0]), .Cout(B0_carry));
	fivebit_ripple fivebit_B1(.A(A[8:4]), .B(B[8:4]), .Cin(one), .S(B1_s[4:0]), .Cout(B1_carry));
	CSA_select select1(.cout1(B0_carry), .cout2(B1_carry), .prev_cout(c4), .next_cout(cout));
	CSA_mux		mux1(.adder0(B0_s[4:0]), .adder1(B1_s[4:0]), .select(c4), .s(S[8:4]));	
	
endmodule
