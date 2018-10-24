library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
	signal temp : std_logic_vector(32 downto 0);
	
begin
	process(a, b, sub_mode) is
	begin
		case sub_mode is
			when '0' => temp <= std_logic_vector(signed('0' & a) + signed('0' & b));
			when '1' => temp <= std_logic_vector(signed('0' & a) + signed(not('0' & b)) + 1);
			when others => temp <= (others => 'U');
		end case;
	end process;
	
	zero <= '1' when (temp(31 downto 0) = (31 downto 0 => '0')) else '0';
	r <= temp(31 downto 0);
	carry <= temp(32);
end synth;
