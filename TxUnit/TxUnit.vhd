library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;						--clock du CPU,reset du circuit
    enable : in std_logic;					        --clock lente d'envoi d'un octet
    ld : in std_logic;						        --commande de chargement de l'octet suivant dans le buffer d'envoi
    txd : out std_logic;						        --bits envoyés par
    regE : out std_logic; 						--indique si le registre d'envoi est occupé
    bufE : out std_logic;						--indique si le buffer d'envoi est occupé
    data : in std_logic_vector(7 downto 0));				--octet à envoyer
end TxUnit;

architecture behavorial of TxUnit is

type t_etat is(idle_ld, reg_preparation, transmission,end_transmission);	--états de l'automate
signal bufferT,registerT : std_logic_vector (7 downto 0);			--buffer et registre d'envoi
signal etat : t_etat;


begin

  process(clk, reset)							--process synchrone

  variable cpt_envoi : natural := 0;					--compteur d'envoi
  variable varBuf : std_logic;						--variable d'accès à bufE
  variable varReg : std_logic;						--variable d'accès à regE
  variable even : std_logic := '0';					--bit de parité
  variable start,stop : std_logic := '0';				--bool pour envoyer le bit de start/stop
  variable cpt_xor: natural := 1;					--compteur du bit de parité
  
  begin

    if (reset = '0') then
      bufferT <= (others => '0');
      registerT <= (others => '0');
      bufE <= '1';
      varBuf := '1';							--reset du circuit
      varReg := '1';
      regE <= '1';
      txd <= '1';
      etat <= idle_ld;

    elsif (rising_edge(clk)) then					
      
      case etat is 							--automate à états 

      when idle_ld => 

        if(ld = '1') then 

            bufferT <= data;
            bufE <= '0';							--chargement de l'octet dans le buffer d'envoi après un repos
            varBuf := '0';
            etat <= reg_preparation;
               
        end if;
          
      when reg_preparation =>

          registerT <= bufferT;
          bufE <= '1';
          varBuf := '1';
          regE <= '0';							--chargement de l'octet dans le registre d'envoi après le repos ou après une transmission
          varReg := '0';
          start := '1';
          etat <= transmission;
  
      when transmission =>

        if(ld = '1' and varBuf = '1') then

            bufferT <= data;						--chargement de l'octet dans le buffer d'envoi pendant une transmission s'il y a un load
            bufE <= '0';							--le buffer d'envoi devient occupé
            varBuf := '0';

        end if;
   
        if(enable = '1') then
    
            if(start = '1') then
            
              txd <= '0';
              even := registerT(0);					--envoi du bit de start en début de transmission
              start := '0';
          
              elsif(cpt_envoi <= 7) then
        
                txd <= registerT(7-cpt_envoi);				--envoi de l'octet
      
                cpt_envoi := cpt_envoi + 1;
                
                if (cpt_xor <= 7) then
                
                    even := even xor registerT(cpt_xor); 			--calcul du bit de parité
                
                    cpt_xor := cpt_xor + 1;
                
                end if;
             
             else
   	      
   	      txd <= even;
              regE <= '1';						--envoi du bit de parité en fin de transmission
              etat <= end_transmission;
            
            end if;
          end if;
                        
          when end_transmission =>
         
          if(enable = '1') then

                txd <= '1';						--envoi du bit de stop en fin de transmission
                even := '0';						
                cpt_envoi := 0;
                cpt_xor := 1;
            								
              if(ld = '1' and varBuf = '1') then				

                  bufferT <= data;					--chargement d'un octet en fin de transmission s'il y un load 
                  bufE <= '0';
                  varBuf := '0';

       	      end if;
       	      
              if (varBuf = '0') then
    
                etat <= reg_preparation;					--s'il y un load, le circuit transmet l'octet chargé dans le buffer
              
              else 
    
                etat <= idle_ld;						--repos s'il n'y a pas de load
    
              end if;

          end if;
  
          end case;
            
        end if;

            
 
 end process;


 end behavorial;
