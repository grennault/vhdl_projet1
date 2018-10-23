library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
type State_Type is (FETCH1, FETCH2, DECODE, R_OP, STORE, BREAK, LOAD1, LOAD2, I_OP);
signal state : State_Type;
signal int_op : Integer;
signal int_opx : Integer;
begin
	int_op <= to_integer(unsigned(op));
	int_opx <= to_integer(unsigned(opx));

	process (op, opx) 
	begin
	case int_op is 
	when 16#04# => op_alu <= "000000";

	when 16#17# => op_alu <= "000000";

	when 16#15# => op_alu <= "000000";

	when OTHERS => case int_opx is 
		when 16#0E# => op_alu <= "100001";
		when 16#1B# => op_alu <= "110011";
		when OTHERS => op_alu <= "UUUUUU";
		end case;
	end case;
	end process;
	
	process (clk, reset_n)
	begin
	if (reset_n = '1') then state <= FETCH1;
	elsif rising_edge(clk) then 
	case state is 
		when FETCH1 =>  read <= '1';
				state <= FETCH2;
		when FETCH2 =>  pc_en <= '1';
				state <= DECODE;
		when DECODE =>  case int_op is
					when 16#15# => state <= STORE;
					when 16#17# => state <= LOAD1;
					when 16#04# => state <= I_OP;
					when OTHERS => case int_opx is 
						when 16#34# => state <= BREAK;
						when OTHERS => state <= R_OP;
						end case;
					end case;
		when R_OP =>    sel_b <= '1';
				sel_rC <= '1';
				rf_wren <= '1';
				state <= FETCH1;
		when STORE =>   write <= '1';
				sel_b <= '1';
				state <= FETCH1;
		when LOAD1 =>   sel_addr <= '1';
				read <= '1';
				state <= LOAD2;
		when LOAD2 =>   rf_wren <= '1';
				sel_mem <= '1';
				state <= FETCH1;
		when I_OP => 	rf_wren <= '1';
				imm_signed <= '1';
				state <= FETCH1;
		when OTHERS => 
		end case;
  	end if;
	end process;
end synth;
