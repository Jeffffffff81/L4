`default_nettype none

module ksa(
	CLOCK_50,
	KEY,
	SW,
	LEDR,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5
);

	//////////// CLOCK //////////
	input                       CLOCK_50;

	//////////// KEY //////////
	input            [3:0]      KEY;

	//////////// SW //////////
	input            [9:0]      SW;

	//////////// LED //////////
	output           [9:0]      LEDR;

	//////////// SEG7 //////////
	output           [6:0]      HEX0;
	output           [6:0]      HEX1;
	output           [6:0]      HEX2;
	output           [6:0]      HEX3;
	output           [6:0]      HEX4;
	output           [6:0]      HEX5;

	/*
	 * General wires:
	 */
	logic clk, reset_n;
	assign clk = CLOCK_50;
	assign reset_n = KEY[3];

	/*
	 * Control
	 */
	wire startTask1, stopTask1;
	 
	ControllerFSM(
		.clock(clk),
		.startTask1(startTask1),
		.stopTask1(stopTask1)
	);
	
	
	/*
	 * S memory and controllers
	 */
	logic[7:0] s_address, s_data,  s_q;
	logic s_wren;
	 
	s_memory(
		.clock(clk),
		.address(s_address),
		.data(s_data),
		.q(s_q),
		.wren(s_wren)
	);
	
	task1FSM(
		.clock(clk),
		.start(startTask1),
		.stop(),
		.data(s_data),
		.address(s_address),
		.wren(s_wren)
	);
	
endmodule