//
module register_unit
(
	input logic Clk, LD_REG, Reset,
	input logic [2:0] sr1_in, sr2_in,	//sr1 is either from IR[6:8] or [9:11], comes from a mux 
													//sr2 is always from IR[0:2], tells us which register to load into
	input logic [2:0] dr_mux,
	input logic [15:0] data_in,
	output logic [15:0] sr1_out, sr2_out
);
	
	logic [15:0] all_registers[8];
	always_ff @ (posedge Clk or posedge Reset)
	begin
		if (Reset)
			begin
				all_registers[0] <= 16'h0000;
				all_registers[1] <= 16'h0000;
				all_registers[2] <= 16'h0000;
				all_registers[3] <= 16'h0000;
				all_registers[4] <= 16'h0000;
				all_registers[5] <= 16'h0000;
				all_registers[6] <= 16'h0000;
				all_registers[7] <= 16'h0000;
			end
		else begin
			if (LD_REG) begin
				all_registers[dr_mux] <= data_in;
			end
		end
	end
	
	assign sr1_out = all_registers[sr1_in];
	assign sr2_out = all_registers[sr2_in];
	
		

endmodule
