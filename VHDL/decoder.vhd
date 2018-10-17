library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
    port(
	        
	address : in  std_logic_vector(15 downto 0);
       	cs_buttons : out std_logic;
	cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic
    );
end decoder;

architecture synth of decoder is
begin
	process (address) is 
	variable addr_int : integer;
	begin	
	addr_int := to_integer(unsigned(address));
	cs_LEDS <= '0';
	cs_RAM <= '0';
	cs_ROM <= '0';
	if (16#0# <= addr_int AND addr_int <= 16#FFC#)
	then cs_ROM  <= '1';
	end if;
	if (16#1000# <= addr_int AND addr_int <= 16#1FFC#)
	then cs_RAM  <= '1';
	end if;
	if (16#2000# <= addr_int AND addr_int <= 16#200C#)
	then cs_LEDS  <= '1';
	end if;
	if (16#2030# <= addr_int AND addr_int <= 16#2034#)
	then cs_buttons  <= '1';
	end if;
	end process;
end synth;
