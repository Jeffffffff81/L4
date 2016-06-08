module task1FSM(start, clock, data, wren, stop, address);
	input logic clock, start;
	output logic wren, stop;
	output logic [7:0] data, address;
	
	//state encoding {state bits}, {wren}, {inc}, {stop}
	logic[6:0] state;
	parameter idle = 7'b0000_0_0_0;
	parameter initialize_a = 7'b0001_1_0_0;
	parameter initialize_b = 7'b0010_0_1_0;
	parameter finished = 7'b0010_0_0_1;
	
	//output logic:
	logic inc;
	
	assign wren = state[2];
	assign inc = state[1];
	assign stop = state[0];
	
	reg[7:0] counter = 0;
	always_ff @(posedge clock) begin
		if(inc)
			counter <= counter + 1;
		else if (inc == 8'b1111_1111)
			counter <= 0;
		else
			counter <= counter;
	end
	
	assign data = counter;
	assign address = counter;
	
	//state transition
	always_ff @(posedge clock) begin
		case(state) 
			idle: state <= (start) ? initialize_a : idle;
			
			initialize_a: state <= (counter == 8'b1111_1111) ? finished : initialize_b;
			
			initialize_b: state <= (counter == 8'b1111_1111) ? finished : initialize_a;
			
			finished: state <= idle;
			
			default: state <= idle;
		endcase
	end

endmodule
	