library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is
    signal addr : integer;
    signal data : std_logic_vector(31 downto 0);
    signal buff : std_logic;
    
    type mem_type is array(0 to 1023) of std_logic_vector(31 downto 0);
    signal mem_block : mem_type;
begin
    process(buff, address, mem_block, clk, addr, data, cs, read) is
    begin
        if(buff = '1') then
            rddata <= mem_block(addr);
        else
        	rddata <= (31 downto 0 => 'Z');
        end if;
    end process;

    process(buff, address, mem_block, clk, addr, data, cs, read) is
    begin
        if(rising_edge(clk)) then
        	if((cs and read) = '1') then
        		addr <= to_integer(unsigned(address));
            	buff <= '1';
            else
            	buff <= '0';
            end if;
        end if;
    end process;
end synth;
