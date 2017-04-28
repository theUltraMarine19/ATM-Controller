--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:16:27 04/29/2017
-- Design Name:   
-- Module Name:   C:/Users/HP PC/divider/divtest.vhd
-- Project Name:  divider
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: div
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
 
ENTITY Dividertest IS
END Dividertest;
 
ARCHITECTURE behavior OF Dividertest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Divider
    PORT(
         a : IN  std_logic_vector(31 downto 0);
         b : IN  std_logic_vector(31 downto 0);
         clk : IN  std_logic;
         start : IN  std_logic;
         reset : IN  std_logic;
         q : OUT  std_logic_vector(31 downto 0);
         done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal a : std_logic_vector(31 downto 0) := (others => '0');
   signal b : std_logic_vector(31 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal start : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal q : std_logic_vector(31 downto 0);
   signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Divider PORT MAP (
          a => a,
          b => b,
          clk => clk,
          start => start,
          reset => reset,
          q => q,
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
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		start <= '1';
		a <= x"0000000a";
		b <= x"0000000a";

      wait; 
   end process;

END;
