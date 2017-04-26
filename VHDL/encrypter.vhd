----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:34:41 01/25/2017 
-- Design Name: 
-- Module Name:    encrypter - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encrypter is
    Port ( clk : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
           plaintext : in  STD_LOGIC_VECTOR (63 downto 0);
           start : in  STD_LOGIC;
           ciphertext : out  STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           done : out  STD_LOGIC := '0');
end encrypter;

architecture Behavioral of encrypter is

signal started: std_logic := '0';
signal count: unsigned(5 downto 0) := (others => '0');
signal sum: std_logic_vector(31 downto 0) := x"00000000";
constant KEY: std_logic_vector(127 downto 0) := x"ff0f745743fd99f775f8c48f2927c18c";
constant DELTA: std_logic_vector(31 downto 0) := x"9e3779b9";

begin
	process (clk, reset)
		variable v0: std_logic_vector(31 downto 0);
		variable v1: std_logic_vector(31 downto 0);
	begin
		if (reset = '1') then
				done <= '0';
				started <= '0';
		elsif ((clk'event AND clk = '1')) then 
			if (start = '1' and started ='0') then
				started <= '1';
				v0 := plaintext(63 downto 32);
				v1 := plaintext(31 downto 0);
				sum <= x"00000000";
				count <= (others => '0');
				done <= '0';
			elsif (started = '1') then
				if (count < 32) then
					v0(31 downto 0) := v0 + ((v1(27 downto 0) & "0000" + KEY(127 downto 96)) XOR (v1 + sum + DELTA)
											 XOR ("00000" & v1(31 downto 5) + KEY(95 downto 64)));
					v1(31 downto 0) := v1 + ((v0(27 downto 0) & "0000" + KEY(63 downto 32)) XOR (v0 + sum + DELTA)
											 XOR ("00000" & v0(31 downto 5) + KEY(31 downto 0)));						 
					sum <= sum + DELTA;
					count <= count + 1;
				else
					done <= '1';
					started <= '0';
					ciphertext(63 downto 32) <= v0(31 downto 0);
					ciphertext(31 downto 0) <= v1(31 downto 0);
				end if;
			else
				done <= '0';
			end if;
		end if;
	end process;
end Behavioral;