----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:10:40 04/30/2017 
-- Design Name: 
-- Module Name:    read5bits - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity read5bits is
    Port ( sliders : in  STD_LOGIC_VECTOR (4 downto 0);
           data_out : out  STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
           start : in  STD_LOGIC;
           done : out  STD_LOGIC := '0';
			  clk: in std_logic;
			  reset: in std_logic);
end read5bits;

architecture Behavioral of read5bits is
begin
    process(clk, reset)
    begin
        if (reset = '1') then
				done <= '0';
            data_out <= (others => '0');
        elsif (clk'event AND clk = '1') then
				if (start = '1') then
					data_out <= sliders;
					done <= '1';
				else
					done <= '0';
				end if;
			end if;
    end process;
end Behavioral;

