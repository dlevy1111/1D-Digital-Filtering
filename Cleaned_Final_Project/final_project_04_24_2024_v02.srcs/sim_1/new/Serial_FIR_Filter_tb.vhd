library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all; 

entity Serial_FIR_Filter_tb is
--  Port ( );
end Serial_FIR_Filter_tb;

architecture Behavioral of Serial_FIR_Filter_tb is

    -- see calculations
    CONSTANT f1 : real := 100.0; -- 100 Hz
    CONSTANT f2 : real := 20000.0; -- 20 KHz
    CONSTANT fs : real := 5.0 * f2; -- 10 * (highest frequency) <-- which is f2.
    CONSTANT clk_period : time := integer((10.0 ** 12.0) / fs) * 1ps;
    signal clk : std_logic := '0';


    -- values for the first sine wave
    CONSTANT N1 : integer := integer(ceil( fs / f1 ));
    CONSTANT d_theta1 : real := MATH_2_PI / real(N1);
    CONSTANT d_y1 : real := 1.0 - cos(d_theta1);
    CONSTANT n_fraction1 : integer := integer(ceil(abs(log2(d_y1))));
    CONSTANT n_integer1 : integer := 2; -- for signed y (i.e. -1 and +1)
    CONSTANT n_bits1 : integer := n_integer1 + n_fraction1; -- of y
    CONSTANT scaling_factor1 : real := 2.0 ** n_fraction1;
    
    
    -- values for the second sine wave
    CONSTANT N2 : integer := integer(ceil( fs / f2 ));
    CONSTANT d_theta2 : real := MATH_2_PI / real(N2);
    CONSTANT d_y2 : real := 1.0 - cos(d_theta2);
    CONSTANT n_fraction2 : integer := integer(ceil(abs(log2(d_y2))));
    CONSTANT n_integer2 : integer := 2; -- for signed y (i.e. -1 and +1)
    CONSTANT n_bits2 : integer := n_integer2 + n_fraction2; -- of y
    CONSTANT scaling_factor2 : real := 2.0 ** n_fraction2;

    -- values for all sine waves 
    signal y1, y2, y3 : real;
    signal sine_wave1 : std_logic_vector(n_bits1 - 1 downto 0); -- y 
    signal sine_wave2 : std_logic_vector(n_bits1 - 1 downto 0); -- y 
    signal sine_wave3 : std_logic_vector(n_bits1 downto 0); -- y 
    
    signal i1 : integer range 0 to N1 - 1 := 0; -- sampling counter
    signal i2 : integer range 0 to N2 - 1 := 0; -- sampling counter
    
    
    signal filter_out : real;
    signal sine_wave_out : std_logic_vector(n_bits1 downto 0);
    
    signal filter_out_avg : real;
    signal sine_wave_out_avg : std_logic_vector(n_bits1 downto 0);
    
    signal filter_out_lpf : real;
    signal sine_wave_out_lpf : std_logic_vector(n_bits1 downto 0);
    
    signal amplitude_factor : real := 0.1;
    
 -- Component definitions
component FIR_Informed is
    Port ( 
        clk : in STD_LOGIC;
        data_i  : in real;
        data_o  : out real
    );
end component;

component AVG_FIR is
    Port ( 
        clk : in STD_LOGIC;
        data_i  : in real;
        data_o  : out real
    );
end component;

component LOW_PASS_FIR is
    Port ( 
        clk : in STD_LOGIC;
        data_i  : in real;
        data_o  : out real
    );
end component;


-----------------------------------------------------------------------------------------


begin
-- Clock process 
    clk_process: process 
    begin 
        clk <= '0'; 
        wait for clk_period/2; 
        clk <= '1'; 
        wait for clk_period/2;
    end process; 
    
    
    -- counter
    process (clk)
    begin
        if (clk'event and clk = '1') then
            i1 <= i1 + 1;
            i2 <= i2 + 1;
            if (i1 = N1 - 1) then
                i1 <= 0;
            end if;
            if (i2 = N2 - 1) then
                i2 <= 0;
            end if;
        end if;
    end process;
    
    
    
    y1 <= scaling_factor1 * sin( d_theta1 * real(i1));
    y2 <= scaling_factor1 * sin( d_theta2 * real(i2));
    y3 <= y1 + y2 * amplitude_factor;
    
    sine_wave1 <= std_logic_vector(to_signed(integer(y1), n_bits1));
    sine_wave2 <= std_logic_vector(to_signed(integer(y2), n_bits1));
    sine_wave3 <= std_logic_vector(to_signed(integer(y3), n_bits1 + 1));
    
    
    
    dut1: FIR_Informed
    port map(
        clk => clk,
        data_i => y3,
        data_o => filter_out
    );
    
    dut2: AVG_FIR
    port map(
        clk => clk,
        data_i => y3,
        data_o => filter_out_avg
    );
    
    dut3: LOW_PASS_FIR
    port map(
        clk => clk,
        data_i => y3,
        data_o => filter_out_lpf
    );
    
    sine_wave_out <= std_logic_vector(to_signed(integer(filter_out), n_bits1 + 1));
    sine_wave_out_avg <= std_logic_vector(to_signed(integer(filter_out_avg), n_bits1 + 1));
    sine_wave_out_lpf <= std_logic_vector(to_signed(integer(filter_out_lpf), n_bits1 + 1));


end Behavioral;
