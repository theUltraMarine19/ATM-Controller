----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:09:14 03/22/2017 
-- Design Name: 
-- Module Name:    Timer - Behavioral 
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
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Timer is
	 Generic ( N : integer := 25000000);
    Port ( start : in  STD_LOGIC;
           output : out  STD_LOGIC := '0';
			  clk : in  STD_LOGIC;
			  reset : in std_logic);
end Timer;

architecture Behavioral of Timer is
signal count : integer := 0;
signal started: std_logic := '0';
begin
	process(clk, reset,start) --changedJ
	begin
		if(reset = '1') then
			started <= '0';
			count <= 0;
			output <= '0';
		elsif(clk'event and clk = '1') then
			if (start = '1') then
				started <= '1';
			end if;
			if (started = '1') then
				if (count < (N-1)) then
					output <= '0';					
					count <= count + 1;
				else
					output <= '1';	
					count <= 0;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

