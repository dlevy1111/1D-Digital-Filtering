library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AVG_FIR is
    Port ( 
        clk : in STD_LOGIC;
        data_i  : in real;
        data_o  : out real
    );
end AVG_FIR;
  
architecture Behavioral of AVG_FIR is

constant order : integer := 10;

-- note that "is array (order - 1 downto 0)" produces an array that is backwards := _[order-1], _[order-2], ...
type terms is array (0 to order - 1 ) of real;
--type MAC_terms is array (0 to order - 2 ) of real;

signal coefficients: terms :=(
0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1
); -- 1/10

-- Multiplication (at i)
signal M : terms := (others=>0.0);

-- Registered Multiplication (at i)
signal RM : terms := (others=>0.0);

-- Make into arrays of (order - 2 downto 0) of signals
-- Multiply Accumulate (at i)
signal MAC : terms := (others=>0.0);

begin

-- Multiply (data with coefficients)
process (data_i)
begin 
    for i in 0 to (order - 1) loop
        M(i) <= coefficients(i) * data_i;
    end loop;
end process;

-- Accumulate (with previous values)
process (RM, M)
begin 
    for i in 0 to (order - 2) loop
        MAC(i) <= RM (i + 1) + M(i);
    end loop;
end process;

-- next state (pipelined between coeffficients, not between adders and multipliers)
process(clk)
begin
    if (clk'event and clk = '1') then
        RM <= MAC;
        RM(order - 1) <= M(order - 1); -- override the last value
    end if;
end process;

data_o <= RM(0);

end Behavioral;
