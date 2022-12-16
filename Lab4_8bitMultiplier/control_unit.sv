module control_unit(input  logic Clk, Run, CALB,
                output logic Clr_Ld, Shift, Add, Sub);

    // Declare signals curr_state, next_state of type enum
    // with enum values of A, B, ..., F as the state values
	 // Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
    enum logic [4:0] {Start, Pressed_Run, Add1, Shift1, Add2, Shift2, Add3, Shift3, Add4, Shift4, 
	 Add5, Shift5, Add6, Shift6, Add7, Shift7, Add8, Shift8, RESULT}   curr_state, next_state; 

	//updates flip flop, current state is the only one
    always_ff @ (posedge Clk)  
    begin
        if (CALB)
            curr_state <= Start;
        else 
            curr_state <= next_state;
    end

    // Assign outputs based on state
	always_comb
    begin
        //Run is pressed -> S+A or (Clear AX, S+A)
		  //CALB is pressed -> CALB
		  next_state  = curr_state;	
        unique case (curr_state)
				Start			 :		if (Run) next_state = Pressed_Run;	//next state clears AX
            Pressed_Run :    next_state = Add1;
            Add1 		:    	next_state = Shift1;
				Shift1	:		next_state = Add2;
				Add2 		:    	next_state = Shift2;
				Shift2	:		next_state = Add3;
				Add3 		:    	next_state = Shift3;
				Shift3	:		next_state = Add4;
				Add4 		:    	next_state = Shift4;
				Shift4	:		next_state = Add5;
				Add5 		:    	next_state = Shift5;
				Shift5	:		next_state = Add6;
				Add6 		:    	next_state = Shift6;
				Shift6	:		next_state = Add7;
				Add7		:		next_state = Shift7;
				Shift7	:		next_state = Add8;
				Add8		:		next_state = Shift8;
				Shift8	:		next_state = RESULT;
            RESULT 	:    if (~Run) next_state = Start;	
				//if Run is hold here, can't go anywhere
				//if Run is released, we can move on to the next state and wait for the next start
							  
        endcase
   
		  // Assign outputs based on ‘state’
		  //total of 2 + 7 + 8 + 1+1
        case (curr_state)
				Start:
				begin
					Clr_Ld = 0;
					Shift = 0;
					Add = 0;
					Sub = 0;
				end
	   	   Pressed_Run: 
	         begin
					Clr_Ld = 1;		//this will clear XA
					Shift = 0;
					Add = 0;
					Sub = 0;
		      end
	   	   
				Add1, Add2, Add3, Add4, Add5, Add6, Add7:
				begin
					Clr_Ld = 0;
					Shift = 0;
					Add = 1;
					Sub = 0;
				end
				
				Shift1, Shift2, Shift3, Shift4, Shift5, Shift6, Shift7, Shift8:
				begin
					Clr_Ld = 0;
					Shift = 1;
					Add = 0;
					Sub = 0;
				end
				
				Add8:
				begin
					Clr_Ld = 0;
					Shift = 0;
					Add = 0;
					Sub = 1;
				end
				
				RESULT:
				begin
					Clr_Ld = 0;
					Shift = 0;
					Add = 0;
					Sub = 0;
				end

	   	   default:  //default case the states is always all set to low, start and hold case will fall in here
		      begin 
					Clr_Ld = 0;
					Shift = 0;
					Add = 0;
					Sub = 0;
		      end
        endcase
    end

endmodule