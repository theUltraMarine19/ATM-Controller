----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:39:18 03/15/2017 
-- Design Name: 
-- Module Name:    atmController - Behavioral 
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

entity atmController is
		generic (num_bits : integer := 8);
    Port ( -- DVR interface -----------------------------------------------------------------------------
		chanAddr_in  : in  std_logic_vector(6 downto 0);  -- the selected channel (0-127)

		-- Host >> FPGA pipe:
		h2fData_in   : in  std_logic_vector(7 downto 0);  -- data lines used when the host writes to a channel
		h2fValid_in  : in  std_logic;                     -- '1' means "on the next clock rising edge, please accept the data on h2fData"
		h2fReady_out : out std_logic;                     -- channel logic can drive this low to say "I'm not ready for more data yet"

		-- Host << FPGA pipe:
		f2hData_out  : out std_logic_vector(7 downto 0);  -- data lines used when the host reads from a channel
		f2hValid_out : out std_logic;                     -- channel logic can drive this low to say "I don't have data ready for you"
		f2hReady_in  : in  std_logic;                     -- '1' means "on the next clock rising edge, put your next byte of data on f2hData"
				
           leds : out  STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
			  reset : in  STD_LOGIC;
			  start : in  STD_LOGIC;
			  load_bank_id : in STD_LOGIC;
			  done : in STD_LOGIC;
			  encrypt_done : in std_logic;
			  decrypt_done : in std_logic;
			  read_done : in std_logic;
			  encrypt_do : out std_logic := '0';
			  decrypt_do : out std_logic := '0';
			  read_do : out std_logic := '0';
			  data5_in : in STD_LOGIC_VECTOR (4 downto 0);
			  data5_done : in std_logic;
			  data5_do : out std_logic;
			  data_in : in STD_LOGIC_VECTOR (63 downto 0);
			  data_out : out STD_LOGIC_VECTOR (63 downto 0);
			  enc_data : in STD_LOGIC_VECTOR (63 downto 0);
			  dec_data : in STD_LOGIC_VECTOR (63 downto 0);
			  num_bytes : in STD_LOGIC_VECTOR (6 downto 0);
			  fx2Clk_in : in  STD_LOGIC
			  );
end atmController;

architecture Behavioral of atmController is

 	--Outputs
signal bank_id : std_logic_vector (4 downto 0) := "00000";
signal timer_out : std_logic;
signal ccount_t : unsigned (0 downto 0)	:= "0";
signal count_t : unsigned (1 downto 0)	:= "00";
signal count_tt : unsigned (2 downto 0)	:= "000";
signal count_ttt : unsigned (2 downto 0)	:= "000";
signal comm_done_sig: std_logic := '0';
signal comm_do_sig: std_logic := '0';
signal denominate_do_sig : std_logic := '0';
signal denominate_done_sig : std_logic := '0';
signal fill_zero_sig: std_logic := '0';
signal cash_state_sig: std_logic := '0';
signal read_do_sig: std_logic := '0';
signal read5_do_sig: std_logic := '0';
signal data5_done_sig: std_logic := '0';
signal encrypt_do_sig: std_logic := '0';
signal decrypt_do_sig: std_logic := '0';
signal n2000 : unsigned (num_bits-1 downto 0) := (others=>'0');
signal n1000 : unsigned (num_bits-1 downto 0) := (others=>'0');
signal n500 : unsigned (num_bits-1 downto 0)	:= (others=>'0');
signal n100 : unsigned (num_bits-1 downto 0)	:= (others=>'0');
signal chan9data : std_logic_vector (7 downto 0) := (others => '0');
signal chan9data_reg : std_logic_vector (7 downto 0) := (others => '0');
signal chan10to17data : std_logic_vector (63 downto 0) := (others => '0');
signal chan10to17data_reg : std_logic_vector (63 downto 0) := (others => '0');
signal chan0data : std_logic_vector (7 downto 0) := (others => '0');
signal cash_available : std_logic := '0';
signal done_sig : std_logic := '0';
signal count_cycles : unsigned(2 downto 0) := (others => '0');
signal n2000d : integer := 0;
signal n1000d : integer := 0;
signal n500d : integer := 0;
signal n100d : integer := 0;
signal start_sig : std_logic := '0';
signal denominate_state : unsigned(1 downto 0) := (others => '0');
signal a_sig : std_logic_vector (31 downto 0) := (others => '0');
signal b_sig : std_logic_vector (31 downto 0) := (others => '0');
signal q_sig : std_logic_vector (31 downto 0) := (others => '0');
signal div_done_sig : std_logic := '0';
begin
   uut: entity work.Timer 
				PORT MAP (
          start => start,
			 reset => reset,
          output => timer_out,
          clk => fx2Clk_in
        );
	
	div: entity work.Divider
	PORT MAP (
			start => start_sig,
			a => a_sig,
			b => b_sig,
			q => q_sig,
			clk => fx2Clk_in,
			done => div_done_sig
	);
	
	seq: entity work.sequencer
    Port map( 
			  clk => fx2Clk_in,
			  done => done_sig,
			  load_bank_id => load_bank_id,
           start => start,
           reset => reset,
           encrypt_done => encrypt_done,
           decrypt_done => decrypt_done,
           read_done => read_done,
			  read5_done => data5_done_sig,
			  denominate_done => denominate_done_sig,
			  denominate_do => denominate_do_sig,
           comm_done => comm_done_sig,
           encrypt_do => encrypt_do_sig,
           decrypt_do => decrypt_do_sig,
           read_do => read_do_sig,
			  read5_do => read5_do_sig,
           comm_do => comm_do_sig,
           fill_zero => fill_zero_sig,
           cash_state => cash_state_sig
			  );
			  
	process(fx2Clk_in, reset)
	begin
		if(reset = '1') then
				done_sig <= '0';
				start_sig <= '0';
				data5_done_sig <= '0';
				ccount_t <= (others=>'0');
				count_t <= (others=>'0');
				count_tt <= (others=>'0');
				denominate_done_sig <= '0';
				denominate_state <= "00";
				count_ttt <= (others=>'0');
				comm_done_sig <= '0';
				chan0data <= x"00";
				chan9data_reg <= (others=>'0');
				chan10to17data_reg <= (others=>'0');
				count_cycles <= (others=>'0');
		elsif (rising_edge(fx2Clk_in)) then	
			if (done_sig = '1') then
				leds <= "00000000";
				done_sig <= '0';
				data5_done_sig <= '0';
				start_sig <= '0';
				denominate_state <= "00";
				denominate_done_sig <= '0';
				ccount_t <= (others=>'0');
				count_t <= (others=>'0');
				count_tt <= (others=>'0');
				count_ttt <= (others=>'0');
				comm_done_sig <= '0';
				chan0data <= x"00";
				chan9data_reg <= (others=>'0');
				chan10to17data_reg <= (others=>'0');
				count_cycles <= (others=>'0');
			elsif (read5_do_sig = '1') then
				if (data5_done = '1') then
					data5_done_sig <= '1';
					data5_do <= '0';
					bank_id <= data5_in;
				else
					data5_do <= '1';
				end if;
			elsif (fill_zero_sig = '1') then
				leds <= "00000000";
				n2000 <= (others=>'0');
				n1000 <= (others=>'0');
				n500 <= (others=>'0');
				n100 <= (others=>'0');
			elsif (read_do_sig = '1') then
				data5_done_sig <= '0';
				if (count_cycles < 2) then
					read_do <= '1';
					count_cycles <= count_cycles + 1;
				else
					read_do <= '0';
				end if;
				leds(3 downto 1) <= num_bytes(2 downto 0);
				leds(7 downto 4) <= bank_id(3 downto 0);
				if (timer_out = '1' and to_integer(count_t) = 0) then
					leds(0) <= '1';
					count_t <= "01";
				elsif (timer_out = '1' and to_integer(count_t) /= 0) then
					leds(0) <= '0';
					count_t <= count_t - 1;
				end if;
			elsif (denominate_do_sig = '1') then
			--n2000d <= 1073741825;
--			n1000d <= 2;
			n500d <= 3;
			n100d <= 4;
--			denominate_done_sig <= '1';
				case denominate_state is
				when "00" =>
					if(div_done_sig = '1') then
						denominate_state <= "01";
						denominate_done_sig <= '1';
						n1000d <= to_integer(n2000);
						n2000d <= to_integer(unsigned(q_sig(31 downto 0)));
						if(n2000d > to_integer(n2000)) then
							leds(7) <= '1';
							leds(6) <= '0';
							n2000d <= to_integer(n2000);
						end if;
					else
						leds(6) <= '1';
						leds(7) <= '0';
						if (count_cycles < 5) then
							start_sig <= '1';
							count_cycles <= count_cycles + 1;
						else
							start_sig <= '0';
						end if;
						a_sig <= data_in (31 downto 0);
						b_sig <= std_logic_vector(to_unsigned(2000,32));
					end if;
--				when "01" =>
--					if(div_done_sig = '1') then
--						denominate_state <= "10";
--						n1000d <= to_integer(unsigned(q_sig(31 downto 0)));
--						if(n1000d > to_integer(n1000)) then
--							n1000d <= to_integer(n1000);
--						end if;
--					else
--						start_sig <= '1';
--						a_sig <= std_logic_vector(to_unsigned((to_integer(unsigned(data_in (31 downto 0)))-n2000d*2000),32));
--						b_sig <= std_logic_vector(to_unsigned(1000,32));
--					end if;
--				when "10" =>
--					if(div_done_sig = '1') then
--						denominate_state <= "11";
--						n500d <= to_integer(unsigned(q_sig(31 downto 0)));
--						if(n500d > to_integer(n500)) then
--							n500d <= to_integer(n500);
--						end if;
--					else
--						start_sig <= '1';
--						a_sig <= std_logic_vector(to_unsigned((to_integer(unsigned(data_in (31 downto 0)))-(n2000d*2000+n1000d*1000)),32));
--						b_sig <= std_logic_vector(to_unsigned(500,32));
--					end if;
--				when "11" =>
--					if(div_done_sig = '1') then
--						denominate_done_sig <= '1';
--						n100d <= to_integer(unsigned(q_sig(31 downto 0)));
--						if(n100d > to_integer(n100)) then
--							n100d <= to_integer(n100);
--						end if;
--					else
--						start_sig <= '1';
--						a_sig <= std_logic_vector(to_unsigned(to_integer(unsigned((data_in (31 downto 0)))-(n2000d*2000+n1000d*1000+n500d*500)),32));
--						b_sig <= std_logic_vector(to_unsigned(100,32));
--					end if;
				when others =>
					null;
				end case;
			elsif (encrypt_do_sig = '1' or comm_do_sig = '1' or decrypt_do_sig = '1') then
				leds(5 downto 2) <= "0000";
				if (timer_out = '1' and to_integer(count_t) = 0) then
					leds(0) <= '1';
					leds(1) <= '1';
					count_t <= "01";
				elsif (timer_out = '1' and to_integer(count_t) /= 0) then
					leds(0) <= '0';
					leds(1) <= '0';
					count_t <= count_t - 1;
				end if;
				if (encrypt_do_sig = '1') then
					data_out(63 downto 32) <= data_in(63 downto 32);
					data_out(31 downto 24) <= std_logic_vector (to_unsigned(n2000d,8));
					data_out(23 downto 16) <= std_logic_vector (to_unsigned(n1000d,8));
					data_out(15 downto 8) <= std_logic_vector (to_unsigned(n500d,8));
					data_out(7 downto 0) <= std_logic_vector (to_unsigned(n100d,8));
					if (count_cycles < 10) then
						encrypt_do <= '1';
						count_cycles <= count_cycles + 1;
					else
						encrypt_do <= '0';
					end if;
				elsif (comm_do_sig = '1') then
					chan9data_reg <= chan9data;
					chan10to17data_reg <= chan10to17data;
					case chan9data_reg is
						when x"00" =>
--							if (to_integer(unsigned(data_in(31 downto 0)))>n2000d*2000+n1000d*1000+n500d*500+n100d*100) then
							if (n2000d*2000+n1000d*1000+n500d*500+n100d*100=to_integer(to_unsigned(750,32))) then
								chan0data <= x"02";
								cash_available <= '0';
							else
								cash_available <= '1';
								chan0data <= x"01";
							end if;
							comm_done_sig <= '0';
						when others =>
							chan0data <= x"03";
							comm_done_sig <= '1';
					end case;
				elsif (decrypt_do_sig = '1') then
					data_out <= chan10to17data_reg;
					if (count_cycles < 15) then
						decrypt_do <= '1';
						count_cycles <= count_cycles + 1;
					else
						decrypt_do <= '0';
					end if;
				end if;
			elsif (cash_state_sig = '1') then
				if (chan9data_reg = x"04") then
					done_sig <= '1';
				elsif (chan9data_reg = x"03") then
					if(to_integer(count_tt) < 6) then
						if (timer_out = '1' and to_integer(count_t) = 0) then
							if(to_integer(count_tt) /= 5) then
								leds(2 downto 0) <= "111";
							end if;
							count_t <= "01";
							count_tt <= count_tt +1;
						elsif (timer_out = '1' and to_integer(count_t) /= 0) then
							leds(2 downto 0) <= "000";
							count_t <= count_t - 1;
						end if;
					end if;
					n2000 <= unsigned(data_in(31 downto 24));
					n1000 <= unsigned(data_in(23 downto 16));
					n500 <= unsigned(data_in(15 downto 8));
					n100 <= unsigned(data_in(7 downto 0));
					done_sig <= done;
				else
					if (timer_out = '1' and to_integer(ccount_t) = 0) then
						leds(3 downto 0) <= "1111";
						ccount_t <= "1";
					elsif (timer_out = '1' and to_integer(ccount_t) /= 0) then
						leds(3 downto 0) <= "0000";
						ccount_t <= ccount_t - 1;
					end if;
					if (chan9data = x"01") then
						if(cash_available = '1') then
							if (to_integer(count_ttt) < 4) then
								if(to_integer(count_tt) < to_integer(unsigned(dec_data(63-8*(to_integer(count_ttt)+4) downto 56-8*(to_integer(count_ttt)+4))))+1) then
									if (timer_out = '1' and to_integer(count_t) = 0) then
										if(to_integer(count_tt) /= to_integer(unsigned(dec_data(63-8*(to_integer(count_ttt)+4) downto 56-8*(to_integer(count_ttt)+4))))) then
											leds(to_integer(count_ttt)+4) <=  '1';
										end if;
										count_t <= "11";
										count_tt <= count_tt +1;
									elsif (timer_out = '1' and to_integer(count_t) /= 0) then
										leds(to_integer(count_ttt)+4) <= '0';
										count_t <= count_t - 1;
									end if;
								else
									count_ttt <= count_ttt +1;
									count_tt <= "000";
								end if;
							else
								leds <= "00000000";
								n2000 <= n2000 - unsigned(dec_data(31 downto 24));
								n1000 <= n1000 - unsigned(dec_data(23 downto 16));
								n500 <= n500 - unsigned(dec_data(15 downto 8));
								n100 <= n100 - unsigned(dec_data(7 downto 0));
								done_sig <= done;
							end if;
						else
							if(to_integer(count_tt) < 4) then
								if (timer_out = '1' and to_integer(count_t) = 0) then
									leds(7 downto 4) <= "1111";
									count_t <= "01";
									count_tt <= count_tt +1;
								elsif (timer_out = '1' and to_integer(count_t) /= 0) then
									leds(7 downto 4) <= "0000";
									count_t <= count_t - 1;
								end if;
							else
								leds <= "00000000";
								done_sig <= done;
							end if;
						end if;
					else
						if(to_integer(count_tt) < 7) then
							if (timer_out = '1' and to_integer(count_t) = 0) then
								leds(7 downto 4) <= "1111";
								count_t <= "01";
								count_tt <= count_tt +1;
							elsif (timer_out = '1' and to_integer(count_t) /= 0) then
								leds(7 downto 4) <= "0000";
								count_t <= count_t - 1;
							end if;
						else
							leds <= "00000000";
							done_sig <= done;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
    -- Drive register inputs for each channel when the host is writing
    chan9data <= h2fData_in when h2fValid_in = '1' and chanAddr_in = "0001001" else chan9data_reg;
    chan10to17data(7 downto 0) <= h2fData_in when h2fValid_in = '1' and chanAddr_in = "0010001" else chan10to17data_reg(7 downto 0);
	 chan10to17data(15 downto 8) <= h2fData_in when h2fValid_in = '1' and chanAddr_in = "0010000" else chan10to17data_reg(15 downto 8);
	 chan10to17data(23 downto 16) <= h2fData_in when h2fValid_in = '1' and chanAddr_in = "0001111" else chan10to17data_reg(23 downto 16);
	 chan10to17data(31 downto 24) <= h2fData_in when h2fValid_in = '1' and chanAddr_in = "0001110" else chan10to17data_reg(31 downto 24);
	 chan10to17data(39 downto 32) <= h2fData_in when h2fValid_in = '1' and chanAddr_in = "0001101" else chan10to17data_reg(39 downto 32);
	 chan10to17data(47 downto 40) <= h2fData_in when h2fValid_in = '1' and chanAddr_in = "0001100" else chan10to17data_reg(47 downto 40);
	 chan10to17data(55 downto 48) <= h2fData_in when h2fValid_in = '1' and chanAddr_in = "0001011" else chan10to17data_reg(55 downto 48);
	 chan10to17data(63 downto 56) <= h2fData_in when h2fValid_in = '1' and chanAddr_in = "0001010" else chan10to17data_reg(63 downto 56);
	 
	 -- Select values to return for each channel when the host is reading
	 	with chanAddr_in select f2hData_out <=
		chan0data             when "0000000",
		enc_data(63 downto 56) when "0000001",
		enc_data(55 downto 48)  when "0000010",
		enc_data(47 downto 40)  when "0000011",
		enc_data(39 downto 32)  when "0000100",
		enc_data(31 downto 24)  when "0000101",
		enc_data(23 downto 16)  when "0000110",
		enc_data(15 downto 8)  when "0000111",
		enc_data(7 downto 0)  when "0001000",
		x"00" when others;
	 -- Assert that there's always data for reading, and always room for writing
    f2hValid_out <= '1';
    h2fReady_out <= '1'; 
	 
end Behavioral;
