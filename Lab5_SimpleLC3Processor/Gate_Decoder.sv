module Gate_Decoder
(
input logic GateMARMUX, GateALU, GatePC, GateMDR,
output logic [1:0] GateSelect 
);
	logic [3:0] combinedgates;
	logic [3:0] marmux_d, alu_d, pc_d, mdr_d;
	
	always_comb
	begin
	marmux_d = 4'b1000;
	pc_d 		= 4'b0100;
	alu_d		= 4'b0010;
	mdr_d		= 4'b0001;
	combinedgates = {GateMARMUX, GatePC, GateALU, GateMDR};
		case(combinedgates)
			marmux_d : GateSelect = 2'b00;
			pc_d 		: GateSelect = 2'b01;
			alu_d 	: GateSelect = 2'b10;
			mdr_d		: GateSelect = 2'b11;
			default	: GateSelect = 2'bxx;
		endcase
	end

endmodule
