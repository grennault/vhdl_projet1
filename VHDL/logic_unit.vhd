library ieee;
use ieee.std_logic_1164.all;

entity logic_unit is
    port(
        a  : in  std_logic_vector(31 downto 0);
        b  : in  std_logic_vector(31 downto 0);
        op : in  std_logic_vector(1 downto 0);
        r  : out std_logic_vector(31 downto 0)
    );
end logic_unit;

architecture synth of logic_unit is
begin
	process(a, b, op)
	begin
		case op is
			when "00" => r <= (a NOR b);
			when "01" => r <= (a AND b);
			when "10" => r <= (a OR b);
			when others => r <= (a XNOR b);
		end case;
	end process;
end synth;
