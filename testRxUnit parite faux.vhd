--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:09:49 10/31/2018
-- Design Name:   
-- Module Name:   testRxUnit.vhd
-- Project Name:  uart
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RxUnit
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
 
ENTITY testRxUnit IS
END testRxUnit;
 
ARCHITECTURE behavior OF testRxUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RxUnit
    PORT(
      clk, reset       : in  std_logic;
      enable           : in  std_logic;
      read             : in  std_logic;
      rxd              : in  std_logic;
      data             : out std_logic_vector(7 downto 0);
      FErr, OErr, DRdy : out std_logic);
    END COMPONENT;
   
    COMPONENT clkUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enableTX : OUT  std_logic;
         enableRX : OUT  std_logic
        );
    END COMPONENT;	

   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enableTx : std_logic := '0';
   signal enableRx : std_logic := '0';
   signal read : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');

   signal rxd : std_logic;
   signal FErr : std_logic;
   signal OErr : std_logic;
   signal DRdy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant enableTX_periode : time := 160 ns;
BEGIN
 
	-- Instantiate the Unit Under Test
   uut0: RxUnit PORT MAP
        (
          clk => clk,
          reset => reset,
          enable => enableRX,
          read => read,
          rxd => rxd,
          data => data,
          FErr => FErr,
          OErr => OErr,
          DRdy => DRdy
        );
   -- Instantiate the clkUnit
   clkUnit1: clkUnit PORT MAP (
          clk => clk,
          reset => reset,
          enableTX => enableTX,
          enableRX => enableRX
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
     rxd <='1';
     -- maintien du reset durant 100 ns.
     wait for 100 ns;	
     reset <= '1';

     wait for 100 ns;	
     rxd <= '0' ;

     wait for enableTX_periode;
     rxd <= '1';
     wait for enableTX_periode;
     rxd <= '0';
     wait for enableTX_periode;
     rxd <= '1';
     wait for enableTX_periode;
     rxd <= '1';
     wait for enableTX_periode;
     rxd <= '0';
     wait for enableTX_periode;
     rxd <= '0';
     wait for enableTX_periode;
     rxd <= '1';
     wait for enableTX_periode;
     rxd <= '0';

     wait for enableTX_periode;
     rxd <= '1';
     wait for enableTX_periode;
     rxd <= '1';
     
     wait;
   end process;

END;
