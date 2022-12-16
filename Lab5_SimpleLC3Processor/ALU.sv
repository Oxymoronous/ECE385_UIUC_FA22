module ALU
(
	input logic[1:0] ALUK,
	input logic [15:0] sr1_in, sr2_in,	//sr1 is registerA, sr2 is registerB
	output logic [15:0] ALU_out
);
	always_comb
		begin
			unique case (ALUK)
				2'b00	:	ALU_out = sr1_in + sr2_in;
				2'b01	:	ALU_out = sr1_in & sr2_in;
				2'b10	:	ALU_out = ~sr1_in;
				2'b11	:	ALU_out = sr1_in;
			endcase
		end
endmodule
