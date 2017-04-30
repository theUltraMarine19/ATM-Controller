----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:41:47 03/25/2017 
-- Design Name: 
-- Module Name:    top_module - Behavioral 
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

entity top_module is
    Port (
        -- FX2LP interface ---------------------------------------------------------------------------
        fx2Clk_in       : in    std_logic;                    -- 48MHz clock from FX2LP
        fx2Addr_out     : out   std_logic_vector(1 downto 0); -- select FIFO: "00" for EP2OUT, "10" for EP6IN
        fx2Data_io      : inout std_logic_vector(7 downto 0); -- 8-bit data to/from FX2LP

        -- When EP2OUT selected:
        fx2Read_out     : out   std_logic;                    -- asserted (active-low) when reading from FX2LP
        fx2OE_out       : out   std_logic;                    -- asserted (active-low) to tell FX2LP to drive bus
        fx2GotData_in   : in    std_logic;                    -- asserted (active-high) when FX2LP has data for us

        -- When EP6IN selected:
        fx2Write_out    : out   std_logic;                    -- asserted (active-low) when writing to FX2LP
        fx2GotRoom_in   : in    std_logic;                    -- asserted (active-high) when FX2LP has room for more data from us
        fx2PktEnd_out   : out   std_logic;                    -- asserted (active-low) when a host read needs to be committed early

        sw_in           : in  STD_LOGIC_VECTOR (7 downto 0);
        led_out            : out  STD_LOGIC_VECTOR (7 downto 0);
        reset           : in  STD_LOGIC;
        start           : in  STD_LOGIC;
		  load_bank_id		: in  STD_LOGIC;
        done            : in  STD_LOGIC;
        next_data_in    : in std_logic
    );
end top_module;

architecture Behavioral of top_module is
    -- Channel read/write interface -----------------------------------------------------------------
    signal chanAddr                 : std_logic_vector(6 downto 0);  -- the selected channel (0-127)

    -- Host >> FPGA pipe:
    signal h2fData                  : std_logic_vector(7 downto 0);  -- data lines used when the host writes to a channel
    signal h2fValid                 : std_logic;                     -- '1' means "on the next clock rising edge, please accept the data on h2fData"
    signal h2fReady                 : std_logic;                     -- channel logic can drive this low to say "I'm not ready for more data yet"

    -- Host << FPGA pipe:
    signal f2hData                  : std_logic_vector(7 downto 0);  -- data lines used when the host reads from a channel
    signal f2hValid                 : std_logic;                     -- '1' means "on the next clock rising edge, put your next byte of data on f2hData"
    signal f2hReady                 : std_logic;                     -- channel logic can drive this low to say "I don't have data ready for you"
    -- ----------------------------------------------------------------------------------------------

    -- Needed so that the comm_fpga_fx2 module can drive both fx2Read_out and fx2OE_out
    signal fx2Read                  : std_logic;

    -- Reset signal so host can delay startup
    signal fx2Reset                 : std_logic;

    signal data_read_sig            : std_logic_vector(63 downto 0); 
    signal num_bytes_sig            : std_logic_vector(6 downto 0); 
    signal read_done_sig            : std_logic; 
    -- Debounced Signals
    signal debounced_next_data_in	: STD_LOGIC;
	 signal debounced_load_bank_id	: STD_LOGIC;
    signal debounced_done			: STD_LOGIC;
    signal debounced_start			: STD_LOGIC;
    signal debounced_reset			: STD_LOGIC;
    signal in_data					: STD_LOGIC_VECTOR (63 downto 0);
    signal out_data_enc				: STD_LOGIC_VECTOR (63 downto 0);
    signal out_data_dec				: STD_LOGIC_VECTOR (63 downto 0);
    signal start_read				: STD_LOGIC;
    signal start_encrypt			: STD_LOGIC;
    signal start_decrypt			: STD_LOGIC;
    signal encryption_over			: STD_LOGIC;
    signal decryption_over			: STD_LOGIC;
	 signal data5_start				: STD_LOGIC;
	 signal data5_done_sig			: STD_LOGIC;
	 signal data5_out					: STD_LOGIC_VECTOR (4 downto 0);
    begin
        -- CommFPGA module
        fx2Read_out     <= fx2Read;
        fx2OE_out       <= fx2Read;
        fx2Addr_out(0)  <=  -- So fx2Addr_out(1)='0' selects EP2OUT, fx2Addr_out(1)='1' selects EP6IN
            '0' when fx2Reset = '0'
            else 'Z';

        comm_fpga_fx2 : entity work.comm_fpga_fx2
        port map(
            clk_in          => fx2Clk_in,
            reset_in        => '0',
            reset_out       => fx2Reset,

            -- FX2LP interface
            fx2FifoSel_out  => fx2Addr_out(1),
            fx2Data_io      => fx2Data_io,
            fx2Read_out     => fx2Read,
            fx2GotData_in   => fx2GotData_in,
            fx2Write_out    => fx2Write_out,
            fx2GotRoom_in   => fx2GotRoom_in,
            fx2PktEnd_out   => fx2PktEnd_out,

            -- DVR interface -> Connects to application module
            chanAddr_out    => chanAddr,
            h2fData_out     => h2fData,
            h2fValid_out    => h2fValid,
            h2fReady_in     => h2fReady,
            f2hData_in      => f2hData,
            f2hValid_in     => f2hValid,
            f2hReady_out    => f2hReady
        );

        debouncer1: entity work.debouncer
        port map (
            clk             => fx2Clk_in,
            button          => start,
            button_deb      => debounced_start
        );

        debouncer2: entity work.debouncer
        port map (
            clk             => fx2Clk_in,
            button          => reset,
            button_deb      => debounced_reset
        );

        debouncer3: entity work.debouncer
        port map (
            clk             => fx2Clk_in,
            button          => next_data_in,
            button_deb      => debounced_next_data_in
        );

        debouncer4: entity work.debouncer
        port map (
            clk             => fx2Clk_in,
            button          => done,
            button_deb      => debounced_done
        );

		  debouncer5: entity work.debouncer
        port map (
            clk             => fx2Clk_in,
            button          => load_bank_id,
            button_deb      => debounced_load_bank_id
        );
		  
        reader: entity work.read_multiple_data_bytes
        Port map( 
            clk 			=> fx2Clk_in,
            reset 			=> debounced_reset,
            data_in 		=> sw_in,
            start 			=> start_read,
            next_data 		=> debounced_next_data_in,
            data_read 		=> data_read_sig,
            num_bytes_read  => num_bytes_sig,
            done 			=> read_done_sig
        );


        encrypt: entity work.encrypter
        port map (
            clk 			=> fx2Clk_in,
            reset 			=> debounced_reset,
            plaintext		=> in_data,
            start 			=> start_encrypt,
            ciphertext		=> out_data_enc,
            done 			=> encryption_over
        );

        decrypt: entity work.decrypter
        port map (
            clk 	       	=> fx2Clk_in,
            reset 			=> debounced_reset,
            ciphertext 		=> in_data,
            start 			=> start_decrypt,
            plaintext 		=> out_data_dec,
            done 			=> decryption_over
        );
			read5: entity work.read5bits
			    Port map (
				 sliders => sw_in(4 downto 0),
           data_out => data5_out,
           start => data5_start,
           done => data5_done_sig,
			  clk => fx2Clk_in,
			  reset => debounced_reset);
        atm_cont: entity work.atmController
        port map (
            -- DVR interface -> Connects to comm_fpga module
            chanAddr_in  	=> chanAddr,
            h2fData_in   	=> h2fData,
            h2fValid_in  	=> h2fValid,
            h2fReady_out 	=> h2fReady,
            f2hData_out  	=> f2hData,
            f2hValid_out 	=> f2hValid,
            f2hReady_in  	=> f2hReady,
            leds 			=> led_out,
				load_bank_id	=> debounced_load_bank_id,
            reset 			=> debounced_reset,
            start 			=> debounced_start,
            done  			=> debounced_done,
            data_in 		=> data_read_sig,
            num_bytes 		=> num_bytes_sig,
            read_done 		=> read_done_sig,
            read_do			=>	start_read,
				data5_done 		=> data5_done_sig,
            data5_do			=>	data5_start,
				data5_in			=> data5_out,
            data_out		=> in_data,
            enc_data		=>	out_data_enc,
            dec_data		=>	out_data_dec,
            encrypt_done	=> encryption_over,
            decrypt_done	=> decryption_over,
            encrypt_do		=> start_encrypt,
            decrypt_do		=> start_decrypt,
            fx2Clk_in		=> fx2Clk_in 
        );
end Behavioral;