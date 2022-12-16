module testbench();

timeunit 10ns;
timeprecision 1ns;

//input arguments
logic Clk = 0;
logic CALB, Run;
logic [9:0] SW;
integer integerErrorCnt = 0;
integer passedCases = 0;

//display
logic [9:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

//outputs
logic [7:0] Aval, Bval;
logic Xval;
logic [15:0] multiply_result;

//logic [8:0] testA, testB, testSum;
//logic testaddercout;
//
//select_adder test_adder(.A(testA), .B(testB), .cin(0), .S(testSum), .cout(testaddercout));
eightbit_multiplier test(.Clk(Clk), .CALB(CALB), .Run(Run), 
								.SW(SW), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3),
								.Aval(Aval), .Bval(Bval), .Xval(Xval));


									
//Toggle the clock
always begin : CLOCK_GENERATION
	#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
	Clk = 0;
end

initial begin: TEST_VECTORS
#2
Run = 0;
CALB = 0;
#2
Aval = 8'bxxxxxxxx;
#2
SW = 8'b00000001;	//decimal 1
#2
CALB = 1;
#2
CALB = 0;

#2
SW = 8'b11111111;	//decimal -1
#2
Run = 1;
#2
Run = 0;
#50
//1(-1) = -1
Run = 1;
#2
Run = 0;
#50
//-1(-1) = 1

SW = 8'b00000100;
Run = 1;
#2
Run = 0;
//1 x 4 = 4
#50
SW = 8'b11111111;
#2
Run = 1;
#2;
Run = 0;
//4 x -1 = -4
#50
SW = 8'b00000010;
#2
Run = 1;
#2
Run = 0;
//-4(2) = -8
$display("------------------");
	
if (integerErrorCnt == 0)
	$display("All test cases passed!");  // Command line output in ModelSim
else
	$display("%d error(s) detected. Try again!", integerErrorCnt);
end
endmodule
