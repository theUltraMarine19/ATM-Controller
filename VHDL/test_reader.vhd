--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:21:44 03/28/2017
-- Design Name:   
-- Module Name:   /home/aadhavan/Downloads/ATMController/test_reader.vhd
-- Project Name:  ATMController
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: read_multiple_data_bytes
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
 
ENTITY test_reader IS
END test_reader;
 
ARCHITECTURE behavior OF test_reader IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT read_multiple_data_bytes
    PORT(
         clk : IN  std_logic;
         start : IN  std_logic;
         reset : IN  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         next_data : IN  std_logic;
         data_read : OUT  std_logic_vector(63 downto 0);
         num_bytes_read : OUT  std_logic_vector(6 downto 0);
         done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal start : std_logic := '0';
   signal reset : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal next_data : std_logic := '0';

 	--Outputs
   signal data_read : std_logic_vector(63 downto 0);
   signal num_bytes_read : std_logic_vector(6 downto 0);
   signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: read_multiple_data_bytes PORT MAP (
          clk => clk,
          start => start,
          reset => reset,
          data_in => data_in,
          next_data => next_data,
          data_read => data_read,
          num_bytes_read => num_bytes_read,
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
		start <= '1';
		wait for 5*clk_period;
		start <= '0';
		wait for 5*clk_period;
		data_in <= x"02";
		next_data <= '1';
				wait for 5*clk_period;
		data_in <= x"03";
		next_data <= '0';
				wait for 5*clk_period;
				data_in <= x"04";
		next_data <= '1';
				wait for 5*clk_period;
				data_in <= x"05";
		next_data <= '0';
				wait for 5*clk_period;
				data_in <= x"06";
		next_data <= '1';
				wait for 5*clk_period;
				data_in <= x"07";
		next_data <= '0';
				wait for 5*clk_period;
				data_in <= x"08";
		next_data <= '1';
				wait for 5*clk_period;
				data_in <= x"09";
		next_data <= '0';
				wait for 5*clk_period;
				data_in <= x"0a";
		next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		data_in <= x"0b";
		next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
						wait for 5*clk_period;

		next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
				start <= '1';
		wait for 5*clk_period;
		start <= '0';
		wait for 5*clk_period;
				data_in <= x"03";
				next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
		wait for 5*clk_period;
						next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
		wait for 5*clk_period;
						next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
		wait for 5*clk_period;
						next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
		wait for 5*clk_period;
						next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
		wait for 5*clk_period;
								next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
		wait for 5*clk_period;
								next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
		wait for 5*clk_period;
								next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
						data_in <= x"04";
		wait for 5*clk_period;
								next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
		wait for 5*clk_period;
								next_data <= '1';
						wait for 5*clk_period;
		next_data <= '0';
				wait for 5*clk_period;
		next_data <= '1';
								wait for 5*clk_period;
		next_data <= '0';
		wait for 5*clk_period;
      -- insert stimulus here 

      wait;
   end process;

END;
