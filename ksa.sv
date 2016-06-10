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
	logic[7:0] s_address; assign s_address = task1_address | task2a_address | task2b_address; 
	logic[7:0] s_data; assign s_data = task1_data | task2a_data | task2b_data;  
	logic[7:0] s_q;
	logic s_wren; assign s_wren = task1_s_wren | task2a_s_wren | task2b_s_wren;
	 
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
	logic[7:0] rom_address; assign rom_address = task2b_address;
	logic[7:0] rom_q;
	rom_memory encrypted_message (
		.address(rom_address),
		.clock(clk),
		.q(rom_q)
	);
	 
	/*
	 * Decrypted Message RAM
	 */
	logic[7:0] decrypt_address; assign decrypt_address = task2b_address;
	logic[7:0] decrypt_data; assign decrypt_data = task2b_data;
	logic decrypt_wren; assign decrypt_wren = task2b_decrypt_wren;
	s_memory decrypted_message(
		.clock(clk),
		.address(decrypt_address),
		.data(decrypt_data),
		.q(),
		.wren(decrypt_wren)
	);
	
	/*
	 * State machines for each task
	 */ 
	logic[7:0] task1_data, task1_address;
	logic task1_s_wren;
	task1FSM(
		.clock(clk),
		.start(startTask1),
		.stop(finishTask1),
		.data(task1_data),
		.address(task1_address),
		.wren(task1_s_wren)
	);
	
	logic[7:0] task2a_data, task2a_address;
	logic task2a_s_wren;
	task2aFSM(
		.clock(clk),
		.start(startTask2a),
		.finish(finishTask2a),
		.secret_key({14'b0, SW[9:0]}),
		.q(s_q),
		.wren(task2a_s_wren),
		.address(task2a_address),
		.data(task2a_data)
	);
	
	logic[7:0] task2b_data, task2b_address;
	logic task2b_s_wren, task2b_decrypt_wren;
	task2bFSM #(.MESSAGE_LENGTH(32))(
		.clock(clk),
		.start(1'b0), //DEBUG
		.finish(finishTask2b),
		.s_q(s_q),
		.rom_q(rom_q),
		.s_wren(task2b_s_wren),
		.decrypt_wren(task2b_decrypt_wren),
		.data(task2b_data),
		.address(task2b_address)
	);
	
endmodule