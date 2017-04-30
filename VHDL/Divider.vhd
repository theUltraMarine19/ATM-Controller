----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:14:53 04/28/2017 
-- Design Name: 
-- Module Name:    Divider - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Divider is
    Port ( a : in  STD_LOGIC_VECTOR(31 downto 0);
           b : in  STD_LOGIC_VECTOR(31 downto 0);
           clk : in  STD_LOGIC;
           start : in  STD_LOGIC;
			  reset : in STD_LOGIC := '0';
           q : out  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
           done : out  STD_LOGIC := '0');
end Divider;

architecture Behavioral of Divider is
	signal res : std_logic_vector(31 downto 0) := (others=>'0');
	signal q_sig : unsigned(31 downto 0) := (others=>'0');
	signal started : boolean := false;
	signal done1 : STD_LOGIC := '0';
	
begin
	process(clk, start, reset, done1)
	
	begin
	if (reset = '1') then
		done <= '0';
		started <= false;
		
	elsif (clk'event and clk = '1') then
		
		if (start = '1' and started /= true and done1 /= '1') then
			started <= true;
			res <= a;
			q_sig <= (others => '0');
		end if;	
		
		if (started) then			
			if (unsigned(b) < unsigned(res) or unsigned(b) = unsigned(res)) then
				res <= STD_LOGIC_VECTOR(unsigned(res) - unsigned(b));
				q_sig <= q_sig+1;
			else
				q <= std_logic_vector(q_sig);
				done <= '1';
				done1 <= '1';
				started <= false;
			end if;
		else
			done <= '0'; 
			done1 <= '0';
		end if;
		
	end if;
	end process;
	
	
end Behavioral;

