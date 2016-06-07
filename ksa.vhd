library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa is
  port(
    CLOCK_50            : in  std_logic;  -- Clock pin
    KEY                 : in  std_logic_vector(3 downto 0);  -- push button switches
    SW                 : in  std_logic_vector(9 downto 0);  -- slider switches
    LEDR : out std_logic_vector(9 downto 0);  -- red lights
    HEX0 : out std_logic_vector(6 downto 0);
    HEX1 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX3 : out std_logic_vector(6 downto 0);
    HEX4 : out std_logic_vector(6 downto 0);
    HEX5 : out std_logic_vector(6 downto 0));
end ksa;

architecture rtl of ksa is
   COMPONENT SevenSegmentDisplayDecoder IS
    PORT
    (
        ssOut : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        nIn : IN STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
    END COMPONENT;
	 
	 COMPONENT s_memory IS
	 PORT
	 (
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	 );
    END COMPONENT;
	 
	 COMPONENT task1FSM IS
	 PORT
	 (
		start : IN STD_LOGIC := '1'; -- DEBUG
		clock	: IN STD_LOGIC;
		restart : IN STD_LOGIC := '1'; -- DEBUG
		data : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren : OUT STD_LOGIC
	 );
	 END COMPONENT;
	 
	 
	 -- memory signals
	 SIGNAL s_address : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  s_data : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL s_wren : STD_LOGIC;
	 SIGNAL s_q : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
    -- clock and reset signals  
	 signal clk, reset_n : STD_LOGIC;										

begin

    clk <= CLOCK_50;
    reset_n <= KEY(3);

	 memoryArray : s_memory port map(s_address, clk, s_data, s_wren, s_q);
	 initializer : task1FSM port map(null, clk, null, s_data, s_address, s_wren);
end RTL;


