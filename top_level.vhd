library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
 
entity top_level is
    Port ( clk                           : in  STD_LOGIC;
           reset_n                       : in  STD_LOGIC;
		     SW                            : in  STD_LOGIC_VECTOR (9 downto 0);
		     PB2							        : in  STD_LOGIC;							-- added
           LEDR                          : out STD_LOGIC_VECTOR (9 downto 0);
           HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out STD_LOGIC_VECTOR (7 downto 0)
          );
           
end top_level;

architecture Behavioral of top_level is

Signal Num_Hex0, Num_Hex1, Num_Hex2, Num_Hex3, Num_Hex4, Num_Hex5 : STD_LOGIC_VECTOR (3 downto 0):= (others=>'0');   
Signal DP_in, Blank:  STD_LOGIC_VECTOR (5 downto 0);
Signal switch_inputs: STD_LOGIC_VECTOR (12 downto 0);
Signal bcd:           STD_LOGIC_VECTOR(15 DOWNTO 0);
signal mux_out:       STD_LOGIC_VECTOR(15 DOWNTO 0);
signal in2:           STD_LOGIC_VECTOR(15 DOWNTO 0);

--edited/added signals
signal s:             STD_LOGIC_VECTOR(1 downto 0); -- now a vector of length 2
signal in3: 		  STD_LOGIC_VECTOR(15 DOWNTO 0);
signal SW_int:		  STD_LOGIC_VECTOR(9 downto 0);
signal EN:			  STD_LOGIC;

--edited/added component declarations
Component Synchronizer is
	Port(
		SW_ext : in  STD_LOGIC_VECTOR(9 downto 0); -- external switch inputs coming into the system
		clk    : in  STD_LOGIC;
		SW_int : out STD_LOGIC_VECTOR(9 downto 0)  -- synchronized, internal switch inputs
		);
End Component;

Component debounce is
	Generic(
		clk_freq    : INTEGER := 50_000_000;
		stable_time : INTEGER := 30					 -- set to 30ms for the required stable threshold time
		   );        
	Port(
		clk     : IN  STD_LOGIC; 
		reset_n : IN  STD_LOGIC;
		button  : IN  STD_LOGIC;
		result  : OUT STD_LOGIC
		); 
End Component;

Component DFF_EN is
	Port(
		D			 : in std_logic_vector (15 downto 0);
		RST, EN, clk : in std_logic;
		Q			 : out std_logic_vector (15 downto 0)
		);
End Component;

Component MUX4TO1 is
    Port(
		 in1       : in  std_logic_vector(15 downto 0);
		 in2       : in  std_logic_vector(15 downto 0);
		 in3	     : in  std_logic_vector(15 downto 0);
		 in4	     : in  std_logic_vector(15 downto 0);
		 s         : in  std_logic_vector(1 downto 0);
		 mux_out   : out std_logic_vector(15 downto 0)
	    );
End Component;

Component SevenSegment is
    Port( 
		Num_Hex0,Num_Hex1,Num_Hex2,Num_Hex3,Num_Hex4,Num_Hex5 : in  STD_LOGIC_VECTOR (3 downto 0);
        Hex0,Hex1,Hex2,Hex3,Hex4,Hex5                         : out STD_LOGIC_VECTOR (7 downto 0);
        DP_in,Blank                                           : in  STD_LOGIC_VECTOR (5 downto 0)
		);
End Component;

Component binary_bcd is
   port(
      clk     : IN  STD_LOGIC;
      reset_n : IN  STD_LOGIC;       
      binary  : IN  STD_LOGIC_VECTOR(12 DOWNTO 0);
      bcd     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)   
		);           
END Component;

begin
   Num_Hex0 <= mux_out(3  downto  0); 
   Num_Hex1 <= mux_out(7  downto  4);
   Num_Hex2 <= mux_out(11 downto  8);
   Num_Hex3 <= mux_out(15 downto 12);
   Num_Hex4 <= "0000";
   Num_Hex5 <= "0000";   
   DP_in    <= "000000";
   Blank    <= "110000"; 
   
	-- edited signal mapping, SW goes to SW_int
   LEDR(9 downto 0) <=SW_int(9 downto 0);
   switch_inputs <= "00000" & SW_int(7 downto 0);
   in2 <= "000" & switch_inputs(12 downto 0);
   s <= SW_int(9 downto 8); -- now connected to 2 switch inputs to determine mode
	
--added/edited component instantiations
Synchronizer_ins: Synchronizer
	PORT MAP(
		SW_ext => SW,    -- takes in external SW inputs
		clk	   => clk,
		SW_int => SW_int -- outputs synchronized SW input signals
		);
		
debounce_ins: debounce
	PORT MAP(
		clk     => clk,
		reset_n => reset_n,
		button  => PB2,
		result  => EN -- connects to EN signal of DFF_EN
		);
	
DFF_EN_ins: DFF_EN
	PORT MAP(
		D   => mux_out, -- when enabled, DFF will output the currently displayed value
		RST => reset_n,
		EN  => EN, -- active-low enable such that when the button is pressed, we store the current displayed value
		clk => clk,
		Q   => in3
		);

MUX4TO1_ins: MUX4TO1                               
   PORT MAP(
      s        => s,                          
      mux_out  => mux_out,   
	   in1      => bcd,								 -- mode 1: decimal value
      in2      => in2, 							    -- mode 2: hexadecimal value
	   in3 	   => in3, 								 -- mode 3: stored output
	   in4	   => "0101"&"1010"&"0101"&"1010" -- mode 4: hard-coded "5A5A" output
      );	
  
SevenSegment_ins: SevenSegment  
  PORT MAP( 
		Num_Hex0 => Num_Hex0,
		Num_Hex1 => Num_Hex1,
		Num_Hex2 => Num_Hex2,
		Num_Hex3 => Num_Hex3,
		Num_Hex4 => Num_Hex4,
		Num_Hex5 => Num_Hex5,
		Hex0     => Hex0,
		Hex1     => Hex1,
		Hex2     => Hex2,
		Hex3     => Hex3,
		Hex4     => Hex4,
		Hex5     => Hex5,
		DP_in    => DP_in,
		Blank    => Blank
		);

binary_bcd_ins: binary_bcd                               
   PORT MAP(
      clk      => clk,                          
      reset_n  => reset_n,                                 
      binary   => switch_inputs,    
      bcd      => bcd         
      );
		
end Behavioral;