module lookahead_adder (
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output        cout
);
	
	logic [3:0] pg, gg, cc;	//these are for pg0, pg4, pg8, pg12 (same for gg); cc is for C4, C8, C12, C16
	logic [15:0] p, g, c, mc;

	//use A, B to get p, g, use those p, g to get PG, GG
	fourbit_CLA mycla0(.A(A[3:0]), .B(B[3:0]), .Propagate(p[3:0]), .Generate(g[3:0]), .PG(pg[0]), .GG(gg[0]));
	fourbit_CLA mycla1(.A(A[7:4]), .B(B[7:4]), .Propagate(p[7:4]), .Generate(g[7:4]), .PG(pg[1]), .GG(gg[1]));
	fourbit_CLA mycla2(.A(A[11:8]), .B(B[11:8]), .Propagate(p[11:8]), .Generate(g[11:8]), .PG(pg[2]), .GG(gg[2]));
	fourbit_CLA mycla3(.A(A[15:12]), .B(B[15:12]), .Propagate(p[15:12]), .Generate(g[15:12]), .PG(pg[3]), .GG(gg[3]));
	
	//use PG, GG and C0 to get C4, C8, C12, C16
	fourbitCLA_carryunit carrybits0(.Propagate(pg[3:0]), .Generate(gg[3:0]), .Cin(cin), .CarryOut(cc[3:0]));
	
	//use C0, C4, C8, C12 to get small carry-ins
	fourbitCLA_carryunit carrybits1(.Propagate(p[3:0]), .Generate(g[3:0]), .Cin(cin), .CarryOut(c[3:0]));
	fourbitCLA_carryunit carrybits2(.Propagate(p[7:4]), .Generate(g[7:4]), .Cin(cc[0]), .CarryOut(c[7:4]));
	fourbitCLA_carryunit carrybits3(.Propagate(p[11:8]), .Generate(g[11:8]), .Cin(cc[1]), .CarryOut(c[11:8]));
	fourbitCLA_carryunit carrybits4(.Propagate(p[15:12]), .Generate(g[15:12]), .Cin(cc[2]), .CarryOut(c[15:12]));
	
	assign mc[3:0] = {c[2], c[1], c[0], cin};	// cin == C0, c[3] == C4
	assign mc[7:4] = {c[6], c[5], c[4], cc[0]}; //cc[0] == C4, c[4] == C5
	assign mc[11:8] = {c[10], c[9], c[8], cc[1]}; //cc[1] == C8, c[8] == C9
	assign mc[15:12] = {c[14], c[13], c[12], cc[2]}; //cc[2] == C12, c[12] == C13
	
	//use small carry-ins to calculate sums
	single_CLA				sum0(.A(A[3:0]), .B(B[3:0]), .Cin(mc[3:0]), .S(S[3:0]));
	single_CLA				sum1(.A(A[7:4]), .B(B[7:4]), .Cin(mc[7:4]), .S(S[7:4]));
	single_CLA				sum2(.A(A[11:8]), .B(B[11:8]), .Cin(mc[11:8]), .S(S[11:8]));
	single_CLA				sum3(.A(A[15:12]), .B(B[15:12]), .Cin(mc[15:12]), .S(S[15:12]));
	
	assign cout = cc[3];
endmodule

