module fourbitCLA_carryunit
(input logic [3:0] Propagate, Generate,
input logic Cin,
output logic [3:0] CarryOut);

	always_comb
		begin
			CarryOut[0] = (Cin & Propagate[0]) | Generate[0];
			CarryOut[1] = (Cin & Propagate[0] & Propagate[1]) | (Generate[0] & Propagate[1]) | Generate[1];
			CarryOut[2] = (Cin & Propagate[0] & Propagate[1] & Propagate[2]) | 
								(Generate[0] & Propagate[1] & Propagate[2]) | 
								(Generate[1] & Propagate[2]) | 
								Generate[2];
			CarryOut[3] = (Cin & Propagate[0] & Propagate[1] & Propagate[2] & Propagate[3]) | 
								(Generate[0] & Propagate[1] & Propagate[2] & Propagate[3]) | 
								(Generate[1] & Propagate[2] & Propagate[3]) | 
								(Generate[2] & Propagate[3]);
			
		end

endmodule

//The speed up of LookAhead Adder from RippleAdder is because carry bits are no longer dependent on previous adders
//From above, we can see that each CarryOut depends only on the first Carryin, and GP values
//GP values are immediately calculated when we perform Parallel load on the AB slice
