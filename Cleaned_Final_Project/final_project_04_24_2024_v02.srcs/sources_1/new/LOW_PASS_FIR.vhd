library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LOW_PASS_FIR is
    Port ( 
        clk : in STD_LOGIC;
        data_i  : in real;
        data_o  : out real
    );
end LOW_PASS_FIR;
  
architecture Behavioral of LOW_PASS_FIR is

constant order : integer := 20;

-- note that "is array (order - 1 downto 0)" produces an array that is backwards := _[order-1], _[order-2], ...
type terms is array (0 to order - 1 ) of real;
--type MAC_terms is array (0 to order - 2 ) of real;

signal coefficients: terms :=(
0.006267590908424971, 0.008659005625104002, 0.015283188793872717, 0.02589120315656111, 0.03962116764832045, 
0.05509159031271929, 0.07057945982398485, 0.08425738318720775, 0.09445377510556144, 0.09989563543824329, 
0.09989563543824329, 0.09445377510556144, 0.08425738318720775, 0.07057945982398485, 0.05509159031271929, 
0.03962116764832045, 0.02589120315656111, 0.015283188793872717, 0.008659005625104002, 0.006267590908424971

); -- delay

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
