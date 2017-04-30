----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:51:58 03/26/2017 
-- Design Name: 
-- Module Name:    sequencer - Behavioral 
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

entity sequencer is
    Port ( clk : in std_logic;
			  done : in  STD_LOGIC;
           start : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  load_bank_id : in STD_LOGIC;
           encrypt_done : in  STD_LOGIC;
           decrypt_done : in  STD_LOGIC;
           read_done : in  STD_LOGIC;
           read5_done : in  STD_LOGIC;
           comm_done : in  STD_LOGIC;
			  denominate_done : in STD_LOGIC;
			  denominate_do : out STD_LOGIC;
           encrypt_do : out  STD_LOGIC;
           decrypt_do : out  STD_LOGIC;
           read_do : out  STD_LOGIC;
			  read5_do : out  STD_LOGIC;
           comm_do : out  STD_LOGIC;
           fill_zero : out  STD_LOGIC;
           cash_state : out  STD_LOGIC);
end sequencer;

architecture Behavioral of sequencer is
signal curr_state : std_logic_vector(3 downto 0) := (others => '0');
begin
	process(clk, reset)
	begin
	if (reset = '1') then
			fill_zero <= '1';
			curr_state <= (others => '0'); -- Ready state
	elsif (rising_edge(clk)) then
			case curr_state is
			when "0000" =>
				if (load_bank_id = '1') then
					curr_state <= "1000";
				elsif (start = '1') then
					fill_zero <= '0';
					curr_state <= "0001"; -- Get user input state
				end if;
			when "1000" =>
				if (read5_done = '0') then
					read5_do <= '1';
				else
					read5_do <= '0';
					curr_state <= "0000"; -- Ready st
				end if;
			when "0001" =>
				if (read_done = '0') then
					read_do <= '1';
				else
					read_do <= '0';
					curr_state <= "0010"; -- encryption state
				end if;
			when "0010" =>
				if (denominate_done = '0') then
					denominate_do <= '1';
				else
					denominate_do <= '0';
					curr_state <= "0011";
				end if;
			when "0011" =>
				if (encrypt_done = '0') then
					encrypt_do <= '1';
				else
					encrypt_do <= '0';
					curr_state <= "0100"; -- communicating with backend state
				end if;
			when "0100" =>
				if (comm_done = '0') then
					comm_do <= '1';
				else
					comm_do <= '0';
					curr_state <= "0101"; -- decryption state					
				end if;
			when "0101" =>
				if (decrypt_done = '0') then
					decrypt_do <= '1';
				else
					decrypt_do <= '0';
					curr_state <= "0111"; -- cash state
					cash_state <= '1';	-- cash state to be handled by the atm controller
				end if;
			when "0111" =>
				if (done = '1') then
					cash_state <= '0';
					curr_state <= (others => '0'); -- Ready state
				end if;
			when others =>
				null;
			end case;
	end if;
	end process;

end Behavioral;

