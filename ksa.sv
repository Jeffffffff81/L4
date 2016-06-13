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
	logic clk;
	assign clk = CLOCK_50;
	
	logic[23:0] display_key;
	logic[7:0] s_q, rom_q, decrypt_q, s_data, s_address, decrypt_data;
	logic[4:0] rom_address, decrypt_address;
	logic s_wren, decrypt_wren;
	task3FSM(
		.clock(clk),
		.found(LEDR[0]),
		.not_found(LEDR[1]),
		.display_key(display_key),
		.s_q(s_q),
		.rom_q(rom_q),
		.decrypt_q(decrypt_q),
		.s_address(s_address),
		.s_data(s_data),
		.s_wren(s_wren),
		.rom_address(rom_address),
		.decrypt_address(decrypt_address),
		.decrypt_data(decrypt_data),
		.decrypt_wren(decrypt_wren)
	);
	
	
	/*
	 * S memory (pseudo random bytes)
	 */
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
		.address(rom_address),
		.clock(clk),
		.q(rom_q)
	);
	 
	/*
	 * Decrypted Message RAM
	 */
	decrypt_ram decrypted_message(
		.clock(clk),
		.address(decrypt_address),
		.data(decrypt_data),
		.q(decrypt_q),
		.wren(decrypt_wren)
	);
	
	/*
	 * Seven Segment Displays
	 */
	 
	 SevenSegmentDisplayDecoder byte_0a(
		.nIn(display_key[3:0]),
		.ssOut(HEX0)
	 );
	 
	 SevenSegmentDisplayDecoder byte_0b(
		.nIn(display_key[7:4]),
		.ssOut(HEX1)
	 );
	 
	 SevenSegmentDisplayDecoder byte_1a(
		.nIn(display_key[11:8]),
		.ssOut(HEX2)
	 );
	 
	 SevenSegmentDisplayDecoder byte_1b(
		.nIn(display_key[15:12]),
		.ssOut(HEX3)
	 );
	 
    SevenSegmentDisplayDecoder byte_2a(
		.nIn(display_key[19:16]),
		.ssOut(HEX4)
	 );
	 
	 SevenSegmentDisplayDecoder byte_2b(
		.nIn(display_key[23:20]),
		.ssOut(HEX5)
	 );
	 
	
endmodule