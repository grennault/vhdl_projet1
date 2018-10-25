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
    type State_Type is (
        FETCH1, 
        FETCH2, 
        DECODE, 
        R_OP, 
        STORE, 
        BREAK, 
        LOAD1, 
        LOAD2, 
        I_OP, 
        BRANCH, 
        CALL, 
        CALLR, 
        JUMP, 
        JUMPI
    );
    signal state : State_Type;
    signal next_state : State_Type;
    signal int_op : Integer;
    signal int_opx : Integer;
begin
    
	process (clk, op, opx) 
	begin
        int_op <= to_integer(unsigned(op));
        int_opx <= to_integer(unsigned(opx));

        case int_op is
            -- I_TYPE
            when 16#04# => op_alu <= "000" & op(5 downto 3);
            when 16#17# => op_alu <= "000" & op(5 downto 3);
            when 16#15# => op_alu <= "000" & op(5 downto 3);
            when 16#06# => op_alu <= "100" & op(5 downto 3);
            when 16#0E# => op_alu <= "011" & op(5 downto 3);
            when 16#16# => op_alu <= "011" & op(5 downto 3);
            when 16#1E# => op_alu <= "011" & op(5 downto 3);
            when 16#26# => op_alu <= "011" & op(5 downto 3);
            when 16#2E# => op_alu <= "011" & op(5 downto 3);
            when 16#36# => op_alu <= "011" & op(5 downto 3);
            -- R_TYPE
            when 16#3A# => 
                case int_opx is 
                    when 16#0E# => op_alu <= "100" & opx(5 downto 3);
                    when 16#1B# => op_alu <= "110" & opx(5 downto 3);
                    when OTHERS =>
                end case;
            when OTHERS =>
        end case;
    end process;
        
    process (clk, reset_n)
    begin
        if (reset_n = '0') then 
            state <= FETCH1;
        elsif rising_edge(clk) then 
            state <= next_state;
        end if;
    end process;

    process (state, next_state)
    begin

        case state is 
            when FETCH1 => 
                read <= '1';
                next_state <= FETCH2;
                    
            when FETCH2 =>  
                pc_en <= '1';
                ir_en <= '1';
                next_state <= DECODE;
                    
            when DECODE =>  
                case int_op is
                    when 16#15# => next_state <= STORE;
                    when 16#17# => next_state <= LOAD1;
                    when 16#04# => next_state <= I_OP;
                    when 16#3A# => 
                        case int_opx is 
                            when 16#34# => next_state <= BREAK;
                            when 16#00# => next_state <= CALLR;
                            when 16#0D# => next_state <= JUMP;
                            when 16#05# => next_state <= JUMP;
                            when OTHERS => next_state <= R_OP;
                        end case;
                    when 16#00# => next_state <= CALL;
                    when 16#01# => next_state <= JUMPI;
                    when others => next_state <= BRANCH;
                end case;
                
            when R_OP =>
                sel_b <= '1';
                sel_rC <= '1';
                rf_wren <= '1';
                next_state <= FETCH1;
                    
            when STORE =>
                sel_addr <= '1';
                write <= '1';
                imm_signed <= '1';
                next_state <= FETCH1;
                    
            when LOAD1 =>   
                sel_addr <= '1';
                read <= '1';
                imm_signed <= '1';
                next_state <= LOAD2;
                    
            when LOAD2 =>   
                rf_wren <= '1';
                sel_mem <= '1';
                next_state <= FETCH1;
                    
            when I_OP => 
                rf_wren <= '1';
                imm_signed <= '1';
                next_state <= FETCH1;

            when BRANCH =>
                branch_op <= '1';
                sel_b <= '1';
                pc_add_imm <= '1';
                next_state <= FETCH1;

            when CALL =>
                rf_wren <= '1';
                pc_en <= '1';
                pc_sel_imm <= '1';
                sel_pc <= '1';
                sel_ra <= '1';
                next_state <= FETCH1;

            when CALLR =>
                rf_wren <= '1';
                pc_en <= '1';
                pc_sel_a <= '1';
                sel_pc <= '1';
                sel_ra <= '1';
                next_state <= FETCH1;
            
            when JUMP => 
                pc_en <= '1';
                pc_sel_a <= '1';
                next_state <= FETCH1;

            when JUMPI =>
                pc_en <= '1';
                pc_sel_imm <= '1';
                next_state <= FETCH1;
                    
            when OTHERS => 
        end case;
	end process;
end synth;