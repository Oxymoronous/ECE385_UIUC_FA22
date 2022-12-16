module ari_rightshift_XAB
(
input logic X,
input logic [7:0] RegA_In, RegB_In,
output logic [7:0] RegA_Out, RegB_Out,
output logic Xout
);
	//discard least significant bit of B_input
	//extend most significant bit of A into X
	logic moveX;
	always_comb
		begin
				moveX = RegA_In[7];
				RegA_Out = {X, RegA_In[7:1]};
				RegB_Out = {RegA_In[0], RegB_In[7:1]};
				Xout = RegA_Out[7];
		end

endmodule
