library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX4TO1 is
port ( in1     : in  std_logic_vector(15 downto 0);
       in2     : in  std_logic_vector(15 downto 0);
	   in3	   : in  std_logic_vector(15 downto 0);
	   in4	   : in  std_logic_vector(15 downto 0);
       s       : in  std_logic_vector(1 downto 0);
       mux_out : out std_logic_vector(15 downto 0)
      );
end MUX4TO1;

architecture BEHAVIOR of MUX4TO1 is
begin

	with s select
		 mux_out <= in1 when "00",    -- when s = 00 then mux_out becomes in1
						in2 when "01",    -- when s = 01 then mux_out becomes in2
						in3 when "10",    -- when s = 10 then mux_out becomes in3
						in4 when others;	-- otherwise mux_out becomes in4
					   
end BEHAVIOR;
