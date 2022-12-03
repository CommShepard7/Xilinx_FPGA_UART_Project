library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
  generic (facteur_TX : natural := 16);		--frequence_enableRX = frequence_enableTX*facteur, facteur = 16 par defaut
 port (		
   clk, reset : in  std_logic;			--clock du CPU, reset du circuit 
   enableTX   : out std_logic;			--clock de transmission de basse frequence
   enableRX   : out std_logic);			--clock de reception de haute frequence
    
end clkUnit;

architecture behavorial of clkUnit is

begin

enableRX <= clk when (reset = '1') else '0';

process(clk,reset)				--process synchrone

  variable cpt_clk_TX : natural := 1;		--compteur pour regler la frequence de enableTX	
  
  begin
    
    
    
    if(reset = '0') then				--reset du circuit
			
      cpt_clk_TX := 1;				
      enableTX <= '0';

    else 
    
    								--par hypothese enableRX est de meme frequence que le clock du CPU
    	
    	if (rising_edge(clk)) then		 
       
        	if (cpt_clk_TX < facteur_TX) then		--compteur de cycles du clock 
		     enableTX <= '0';
          	     cpt_clk_TX := cpt_clk_TX + 1;
      
        	else 
	
        	    enableTX <= '1';				--enableTX passe a 1 apres 16 (facteur) cycles de clk
                     cpt_clk_TX := 1;
        
                end if;
               
                                 
       end if;
      
   end if;
    
  
  end process;

end behavorial;
