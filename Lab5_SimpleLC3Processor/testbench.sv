module testbench();

timeunit 10ns;
timeprecision 1ns;

//input arguments
logic Clk = 0;
logic Run, Continue;
logic [9:0] SW;
integer integerErrorCnt = 0;
integer passedCases = 0;

//display
logic [9:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3;
//logic [6:0] HEX4, HEX5;

//dictionary for HEX mapping to actual digits

slc3_testtop test(.SW(SW), .Clk(Clk), .Run(Run), .Continue(Continue),
								.LED(LED), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3));
									
//Toggle the clock
always begin : CLOCK_GENERATION
	#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
	Clk = 0;
end

initial begin: TEST_VECTORS
//----------------------------------------------------------------------------------------
#2
Run = 0;
Continue = 0;
#2
Run = 1;
Continue = 1;
#2
Run = 0;
Continue = 0;
#2
SW = 10'b0000110001;		//0x0031 ; test5
#2
Run = 1;
#2
Run = 0;
#200
SW = 10'b0000000010;	//input 1 = 2
#10
Continue = 1;
#2
Continue = 0;
#200
#100
SW = 10'b0000000001; //input 2 = 1
#10
Continue = 1;
#2
Continue = 0;

$display("------------------");

#2																							
$display("------------------");



	
if (integerErrorCnt == 0)
	$display("All test cases passed!");  // Command line output in ModelSim
else
	$display("%d error(s) detected. Try again!", integerErrorCnt);
end
endmodule
