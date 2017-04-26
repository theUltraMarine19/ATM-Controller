--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:28:47 04/05/2017
-- Design Name:   
-- Module Name:   /home/aadhavan/Downloads/ATMController/test_decrypt.vhd
-- Project Name:  ATMController
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: decrypter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_decrypt IS
END test_decrypt;
 
ARCHITECTURE behavior OF test_decrypt IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT decrypter
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         ciphertext : IN  std_logic_vector(63 downto 0);
         start : IN  std_logic;
         plaintext : OUT  std_logic_vector(63 downto 0);
         done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal ciphertext : std_logic_vector(63 downto 0) := (others => '0');
   signal start : std_logic := '0';

 	--Outputs
   signal plaintext : std_logic_vector(63 downto 0);
   signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: decrypter PORT MAP (
          clk => clk,
          reset => reset,
          ciphertext => ciphertext,
          start => start,
          plaintext => plaintext,
          done => done
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
	      -- hold reset state for 100 ns.
			ciphertext <= x"0000001000000000";
	start <= '1';
		wait for 5*clk_period;
		start <= '0';
		wait for 5*clk_period;
		--plaintext <= x"00010020ffffffff";

		--plaintext <= "0110010011001001010100110011011101100001110100000000101011001001";
      -- insert stimulus here 
wait for 200*clk_period;
	
	start <= '1';
		wait for 5*clk_period;
		start <= '0';
		wait for 5*clk_period;
			wait for 200*clk_period;
	start <= '1';
		wait for 5*clk_period;
		start <= '0';
		wait for 5*clk_period;
      --wait;
					wait for 200*clk_period;
	start <= '1';
		wait for 5*clk_period;
		start <= '0';
		wait for 5*clk_period;
      --wait;
					wait for 200*clk_period;
	start <= '1';
		wait for 5*clk_period;
		start <= '0';
		wait for 5*clk_period;
      wait;
   end process;

END;
