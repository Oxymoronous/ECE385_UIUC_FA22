module testbench();

timeunit 10ns;
timeprecision 1ns;

logic [15:0] A, B;
logic cin;
logic [15:0] S;
logic cout;
logic Clk = 0;
logic Reset_Clear, Run_Accumulate;
logic [9:0] SW;
integer integerErrorCnt = 0;
integer passedCases = 0;
logic [9:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

lookahead_adder lha(.*);
										
//Toggle the clock
always begin : CLOCK_GENERATION
	#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
	Clk = 0;
end

initial begin: TEST_VECTORS
A = 16'h0000;
B = 16'h1111;
cin = 1'b0;

#2

if (S != 16'h0000 + 16'h1111) 
	integerErrorCnt++;
else
	begin
		$display("Passed test case %x! %x + %x = %x  .", passedCases, A, B, S);
		passedCases++;
	end
#2
A = 16'h1111;
B = 16'h1111;

#2
if (S != 16'h2222)
	integerErrorCnt++;
else
	begin
		$display("Passed test case %x! %x + %x = %x  .", passedCases, A, B, S);
		passedCases++;
	end
#2

A = 16'hFFFF;
B = 16'hFFFF;

#2
if (S != 16'hFFFF + 16'hFFFF)
	integerErrorCnt++;
else
	begin
		$display("Passed test case %x! %x + %x = %x  .", passedCases, A, B, S);
		passedCases++;
	end
#2
A = 16'hABCD;
B = 16'hDCBA;

#2
if (S != 16'hABCD + 16'hDCBA)
	integerErrorCnt++;
else
	begin
		$display("Passed test case %x! %x + %x = %x  .", passedCases, A, B, S);
		passedCases++;
	end
	
#2
A = 16'h0000;
B = 16'h0000;

#2
if (S != 0)
	integerErrorCnt++;
else
	begin
		$display("Passed test case %x! %x + %x = %x  .", passedCases, A, B, S);
		passedCases++;
	end
	
if (integerErrorCnt == 0)
	$display("All test cases passed!");  // Command line output in ModelSim
else
	$display("%d error(s) detected. Try again!", integerErrorCnt);
end
endmodule
