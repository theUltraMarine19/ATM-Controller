----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    15:39:00 01/25/2017
-- Design Name:
-- Module Name:    read_multiple_data_bytes - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity read_multiple_data_bytes is
    Port ( clk : in  STD_LOGIC;
				start : in std_logic;
           reset : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           next_data : in  STD_LOGIC;
           data_read : out  STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
	   num_bytes_read : out std_logic_vector(6 downto 0) := (others => '0');
	   done : out std_logic := '0');
end read_multiple_data_bytes;

architecture Behavioral of read_multiple_data_bytes is

signal count: unsigned(6 downto 0) := (others => '0');
signal old_next_data: std_logic := '0';
signal data: std_logic_vector (63 downto 0) := (others => '0');
signal started: std_logic := '0';
begin
    process(clk, reset)
    begin
        if (reset = '1') then
            count <= (others => '0');
				done <= '0';
				num_bytes_read <= (others => '0');
            data <= (others => '0');
        elsif (clk'event AND clk = '1') then
				if (start = '1' and started = '0') then
					started <= '1';
					count <= (others => '0');
					num_bytes_read <= (others => '0');
					done <= '0';
				elsif (started = '1') then
					if (old_next_data /= next_data) then
						old_next_data <= next_data;
						if (next_data = '1' and count < 64) then
							done <= '0';
							data((63-to_integer(count)) downto (56-to_integer(count))) <= data_in;
							count <= count + 8;
							if (count /= 56) then
								num_bytes_read <= std_logic_vector((count/8)+1);
							else
								done <= '1';
								started <= '0';
							end if;
						end if;
					end if;
				else

					done <= '0';
            end if;
					data_read <= data;
        end if;
    end process;
end Behavioral;
