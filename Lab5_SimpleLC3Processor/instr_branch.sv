module instr_branch
(
	input logic [2:0] IR_br,
	input logic n_in, z_in, p_in,
	output logic branch_bool
);

//only one of the nzp in can be zero
//but IR_br can have multiple ones 
//IR[0] = n ...
always_comb
	begin
		branch_bool = (n_in & IR_br[2]) | (z_in & IR_br[1]) | (p_in & IR_br[0]);
	end

endmodule
