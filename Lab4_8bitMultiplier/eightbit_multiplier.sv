module eightbit_multiplier
(
input logic Clk, CALB, Run,
input logic [7:0] SW,
output logic [6:0] HEX0, HEX1, HEX2, HEX3,
output logic [7:0] Aval, Bval,
output logic Xval
);

logic ctrladd, ctrlsub, ctrlld, ctrlshift;
logic [8:0] addersum;
logic [7:0] LoadedA, LoadedB;
logic adderX, LoadedX;
logic A_shiftout, B_shiftout;

logic [7:0] SW_sync;
logic CALB_sync, Run_sync;

assign Aval = LoadedA;
assign Bval = LoadedB;
assign Xval = LoadedX;

control_unit	control(.Clk(Clk), .Run(Run_sync), .CALB(CALB_sync), 
								.Clr_Ld(ctrlld), .Shift(ctrlshift), .Add(ctrladd), .Sub(ctrlsub));
//ctrlld will only be true determine by the statemachine
//ctrlld TRUE determines registerA clear								

//CALB_sync comes from button and only determines start state in Control Path
//CALB_sync also determines registerB clear in register unit

//instantiates registers and determines whether a shift is needed
register_unit	reg_unit(.Clk(Clk), .CA(ctrlld), .Clear_Ld(CALB_sync), .Shift(ctrlshift), .Add(ctrladd), .Sub(ctrlsub), .SW(SW_sync), .AdderSum(addersum),
								.A_out(A_shiftout), .LoadedA(LoadedA), .LoadedB(LoadedB), .X(LoadedX));

ninebit_AddSub adder9(.RegA_In(LoadedA), .RegS_In(SW_sync), .RegB_In(LoadedB), .Add(ctrladd), .Sub(ctrlsub), .PrevX(LoadedX),
								.X(addersum[8]), .RegA_Out(addersum[7:0]));
								
HexDriver        HexAL (.In0(LoadedB[3:0]),.Out0(HEX0) );
HexDriver        HexAU (.In0(LoadedB[7:4]),.Out0(HEX1) );	
								
HexDriver        HexBL (.In0(LoadedA[3:0]),.Out0(HEX2) );
HexDriver        HexBU (.In0(LoadedA[7:4]),
                        .Out0(HEX3) );
								
sync button_sync[1:0] (Clk, {CALB, Run}, {CALB_sync, Run_sync});
sync Din_sync[7:0] (Clk, SW, SW_sync);
	  

endmodule
