module ninebit_AddSub
(
input logic [7:0] RegA_In, RegS_In, RegB_In,
input logic Add, Sub, PrevX,
output logic X,
output logic [7:0] RegA_Out
);

//Command = 0 (Add)
//Command = 1 (Subtract)
	logic [8:0] regAext, regSext, regSext_Flip;
	logic [8:0] sum_9bit, sub_9bit, same;	//sub_9bit1 is only adding the NOT
	logic cout;		//just assign it as output but not using it further
	logic [8:0] zeroes = {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
	assign regSext = {RegS_In[7], RegS_In[7:0]};
	assign regSext_Flip = ~regSext[8:0];		//performing the NOT here to prepare for subtraction
	assign regAext = {RegA_In[7], RegA_In[7:0]}; 
	
	//A+S
	select_adder csa_add(.A(regAext), .B(regSext), .cin(0), .S(sum_9bit), .cout(cout));
	//A-s
	select_adder csa_sub(.A(regAext), .B(regSext_Flip), .cin(1'b1), .S(sub_9bit), .cout(cout));		
	//A + Bitwise NOT of S + 1
	select_adder csa0(.A(regAext), .B(zeroes), .cin(1'b0), .S(same), .cout(cout));
	
	always_comb
		begin
			//if the last bit of B register is 1, decide whether add or subtract based on machine
			if (Add & RegB_In[0])
				begin
				//A + S
					RegA_Out = sum_9bit[7:0];
					X = sum_9bit[8];
				end
			else if (Sub & RegB_In[0])
				//A - S
				begin
					RegA_Out = sub_9bit[7:0];
					X = sub_9bit[8];
					
				end
			else
				//A + 0
				begin
					RegA_Out = same;
					X = RegA_Out[7];	//just extends the bit of register A.
				end
		end
		

endmodule
