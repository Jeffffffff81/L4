`default_nettype none

/*
 * This FSM will scramble the contents of s_RAM.
 * 
 * int j = 0;
 * for(int i = 0; i < 256; i++) {
 *   j = (j + s[i] + secret_key[i%3]) % 256;
 *   swap(s[i],s[j]);
 * }
 *
 * Inputs:   clock: the clock it runs on
 *           start: tells it to start scrambling
 *           secret_key_sw: comes from SW[9:0]. Sets the lowest 10 bits, The upper 14 are 0.
 *           q: data from s_RAM
 *           
 * Outputs   stop: pulsed when FSM is done
 *           wren: set when we want to write 'data' to s_RAM
 *           i: the i into s_RAM
 *           data: data to be written to s_RAM
 */
module task2aFSM(clock, start, stop, secret_key_sw, wren, data, address, q);
	input logic clock, start;
	input logic[9:0] secret_key_sw;
	input logic[7:0] q;

	output logic stop, wren;
	output logic[7:0] address, data;

	//internal wires:
	logic [23:0] secret_key = {14'b0, secret_key_sw};
	reg [7:0] i, j, si, sj;
	logic enable_j, enable_si, enable_sj, i_inc, i_reset, j_reset, address_use_i;

	//counter. outputs i:
	always_ff @(posedge clock) begin
		if(i_reset)
			i <= 0;
		else if(i_inc)
			i <= i + 1;
		else if (i == 8'b1111_1111)
			i <= 0;
		else	
			i <= i;
	end

	//logic for calculating j
	//note: %256 may not be needed
	always_ff @(posedge clock) begin
		if (enable_j) begin
			if(i%3 == 0)
				j <= (j + si + secret_key[7:0]) % 256;
			else if(i%3 == 1)
				j <= (j + si + secret_key[15:8]) % 256;
			else
				j <= (j + si + secret_key[23:16]) % 256;
		end
		else
			j <= j;
	end

	//logic for calculating si
	always_ff @(posedge clock) begin
		if (enable_si) 
			si <= q;
		else
			si <= si;
	end

	//logic for calculating sj
	always_ff @(posedge clock) begin
		if (enable_sj) 
			sj <= q;
		else
			sj <= sj;
	end
		

	//state encoding: {state bits}, {stop}, {enable_j}, {enable_si}, {enable_sj}, {i_inc}, {i_reset}, {j_reset}, {address_use_i}, {wren}
	reg[12:0] state = 0;
	parameter idle          = 13'b0000_0_0_0_0_0_0_0_0_0;
	parameter initialize    = 13'b0001_0_0_0_0_0_0_1_1_0;
	parameter check_if_done = 13'b0010_0_0_0_0_0_0_0_0_0;
	parameter get_si_1      = 13'b0011_0_0_0_0_0_0_0_1_0;
	parameter get_si_2      = 13'b0100_0_0_1_0_0_0_0_1_0;

	assign wren = state[0];
	assign address_use_i = state[1];
	assign j_reset = state[2];
	assign i_reset = state[3];
	assign i_inc = state[4];
	assign enable_sj = state[5];
	assign enable_si = state[6];
	assign enable_j = state[7];
	assign stop = state[8];

	//other output logic:
	assign address = (address_use_i) ? i : j;
	
	

endmodule