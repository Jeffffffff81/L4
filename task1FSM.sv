module task1FSM(start, clock, restart, data, wren, address);
	
	//inputs to FSM
	input logic start; 
	input logic clock;
	input logic restart; 
	
	//outputs from FSM 
	output logic [7:0] data; 
	output logic [7:0] address; 
	output logic wren; 
	
	//states
	//state bits: wren_choose_inc
	parameter [2:0] idle = 3'b0_0_0; 
	parameter [2:0] write = 3'b1_1_0; 
	parameter [2:0] incr_counter = 3'b0_0_1; 
	
	//wire declarations 
	logic [2:0] state, next;
	logic choose, inc; 
	reg [8:0] counter = 9'b0; //9 bits for counter variable  
	
	
	//restat logic 
	always_ff @(posedge clock or negedge restart)
		if(!restart) state <= idle; 
		else 		state <= next; 
		
	//next state combinational logic 
	always_comb begin
		next = 3'b000; 
		case(state)
			
			idle: if(start) next = write; 
				  else 		next = idle; 
			
			write: 	next = incr_counter; 
			
			incr_counter: 	if(counter < 256) next = write; 
							else 			  next = idle; 
		endcase
	end 
	
	//output logic of FSM 
	assign wren = state[2]; 	//output signal 
	assign choose = state[1]; 	//for the mux 
	assign inc = state[0]; 		//for the counter 
	
	//outputs for address and data 
	assign data = choose ? counter : 9'bzzzzzzzzz;
	assign address = choose ? counter : 9'bzzzzzzzzz;
	
	//counter logic 
	always_ff @(posedge inc) begin
			if(!restart) begin
				counter <= 0;
			end else begin
				counter <= counter + 1;
			end
		end
	
	
	
endmodule 
	