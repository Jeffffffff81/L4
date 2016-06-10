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
	wire startTask1, finishTask1, startTask2a, finishTask2a,
	startTask2b, finishTask2b;
	 
	ControllerFSM(
		.clock(clk),
		.startTask1(startTask1),
		.finishTask1(finishTask1),
		.startTask2a(startTask2a),
		.finishTask2a(finishTask2a),
		.startTask2b(startTask2b),
		.finishTask2b(finishTask2b)
	);
	
	
	/*
	 * S memory (pseudo random bytes)
	 */
	logic[7:0] s_address; assign s_address = task1_s_address | task2a_s_address; 
	logic[7:0] s_data; assign s_data = task1_s_data | task2a_s_data;  
	logic[7:0] s_q;
	logic s_wren; assign s_wren = task1_s_wren | task2a_s_wren;
	 
	s_memory working_memory(
		.clock(clk),
		.address(s_address),
		.data(s_data),
		.q(s_q),
		.wren(s_wren)
	);
	
  /*
	* ROM (encrypted message)
	*/
	rom_memory encrypted_message (
		.address(),
		.clock(clk),
		.q()
	);
	 
	/*
	 * Decrypted Message RAM
	 */
	logic[7:0] decrypted_address, decrypted_data;
	logic decrypted_wren;
	s_memory decrypted_message(
		.clock(clk),
		.address(decrypted_address),
		.data(decrypted_data),
		.q(),
		.wren(decrypted_wren)
	);
	
	/*
	 * State machines for each task
	 */ 
	logic[7:0] task1_s_data, task1_s_address;
	logic task1_s_wren;
	task1FSM(
		.clock(clk),
		.start(startTask1),
		.stop(finishTask1),
		.data(task1_s_data),
		.address(task1_s_address),
		.wren(task1_s_wren)
	);
	
	logic[7:0] task2a_s_data, task2a_s_address;
	logic task2a_s_wren;
	task2aFSM(
		.clock(clk),
		.start(startTask2a),
		.finish(finishTask2a),
		.secret_key({14'b0, SW[9:0]}),
		.q(s_q),
		.wren(task2a_s_wren),
		.address(task2a_s_address),
		.data(task2a_s_data)
	);
	
endmodule