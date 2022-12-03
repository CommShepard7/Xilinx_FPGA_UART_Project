library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity UART_FPGA_N4 is
  port (
	--leds
	led : out std_logic_vector(15 downto 0);
 	--reseT
	btnR : in std_logic; 
    --horloge
    mclk : in std_logic;
	--port serie 
    TXD_UART : in std_logic; 
    RXD_UART : out  std_logic
  );
end UART_FPGA_N4;

architecture synthesis of UART_FPGA_N4 is
	
   signal nclk : std_logic;
   signal cs_cpu,rd_cpu,wr_cpu : std_logic;
   signal Int_R, Int_T : std_logic;
   signal addr_cpu : std_logic_vector(1 downto 0);
   signal data_in_cpu, data_out_cpu : std_logic_vector (7 downto 0);
   signal data_1 : std_logic_vector(7 downto 0);
   signal data_2 : std_logic_vector(7 downto 0);
	
   component UARTunit
   		port (
			clk, reset : in  std_logic;
			cs, rd, wr : in  std_logic;
			RxD        : in  std_logic;
			TxD        : out std_logic;
			IntR, IntT : out std_logic;         
			addr       : in  std_logic_vector(1 downto 0);
			data_in    : in  std_logic_vector(7 downto 0);
			data_out   : out std_logic_vector(7 downto 0));
   end component;
   
   component diviseurClk
   		generic(facteur : natural);
   		port (
   			clk,reset : in std_logic;
   			nclk : out std_logic);
   end component;
   
   component echoUnit
   		port (
		   clk, reset : in  std_logic;
		   cs, rd, wr : out  std_logic;
		   IntR       : in std_logic;         -- interruption de réception
		   IntT       : in std_logic;         -- interruption d'émission
		   addr       : out  std_logic_vector(1 downto 0);
		   data_in    : in  std_logic_vector(7 downto 0);
		   data_out   : out std_logic_vector(7 downto 0));
	end component;
    
 
begin

  led(15 downto 0) <= (others => '0');

  divClk : diviseurClk
    generic map (645)
    
  	port map ( clk => mclk,
  			   reset => not btnR,
  			   nclk => nclk);
  
  uart_c : UARTunit
  	port map (clk => nclk,
  			  reset => not btnR,
  			  cs => cs_cpu,
  			  rd => rd_cpu,
  			  wr => wr_cpu,
  			  RxD => TXD_UART,
  			  TxD => RXD_UART,
  			  IntR => Int_R,
  			  IntT => Int_T,
  			  addr => addr_cpu,
  			  data_in => data_2,
  			  data_out => data_1);
  
  echo : echoUnit
  	  port map ( clk => nclk,
  	  			 reset => not btnR,
  	  			 cs => cs_cpu,
  	  			 rd => rd_cpu,
  	  			 wr => wr_cpu,
  	  			 IntR => Int_R,
  	  			 IntT => Int_T,
  	  			 addr => addr_cpu,
  	  			 data_in => data_1,
  	  			 data_out => data_2); 
  

end synthesis;
