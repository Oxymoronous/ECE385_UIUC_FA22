module register_unit 
(input  logic Clk, CA, Clear_Ld, Shift, Add, Sub,
//CA is clearA only, comes from state machine
//Clear_Ld comes from button
input  logic [7:0]  SW,
input logic [8:0] AdderSum,
output logic A_out, 
output logic [7:0]  LoadedA,
output logic [7:0]  LoadedB,
output logic X);
		
		logic dummy, shiftAintoB, shiftXintoA, check1, check2;
		
		assign shiftAintoB = A_out;
		assign check1 = CA | Clear_Ld;
		assign check2 = Add | Sub;
		
		always_ff @(posedge Clk)
		begin
			if (check1)
				dummy <= 1'b0;
			else
				dummy <= AdderSum[8];
		end
				
		reg8_A	registerA(.Clk(Clk), .CA(CA), .Reset_CALB(Clear_Ld), .Shift(Shift), .Shift_In(dummy), .Add(Add), .Sub(Sub),
									.Din(AdderSum[7:0]), .Shift_Out(A_out), .Data_Out(LoadedA));
									
		reg8_B	registerB(.Clk(Clk), .Shift(Shift), .Shift_In(shiftAintoB), .Load(Clear_Ld),
									.Din(SW), .Data_Out(LoadedB));
    

endmodule
