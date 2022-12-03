library IEEE;
use IEEE.std_logic_1164.all;

entity RxUnit is
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    read             : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    FErr, OErr, DRdy : out std_logic);
end RxUnit;

architecture RxUnit_arch of RxUnit is

  signal tmpClk, tmpRxd : std_logic := '0';

  signal registerR : std_logic_vector (7 downto 0) := "00000000";

  type t_etatC is(repos, attente_start, envoie_bit,attente_bit);	--états de l'automate
  signal etatC : t_etatC;

  type t_etatR is(repos, reception_donnee, reception_parite, reception_fin, fin_transmission, fin_transmission_err);	--états de l'automate
  signal etatR : t_etatR;

begin 

  process(enable,reset)				--process synchrone
    variable cpt_controle : natural := 0;
    variable cpt_envoi : natural := 1;
    variable cpt_tmpClk : natural := 1;		--compteur pour regler l'horloge tmpClk	

    begin

    if(reset = '0') then				--reset du circuit	
      cpt_tmpClk := 1;	
      cpt_envoi := 1;			
      tmpClk <= '0';
      tmpRxd <= '1';
      etatC <= repos;

    elsif (enable = '1') then
      case etatC is 							--automate à états 

      when repos => 
        if (rxd = '0') then
          etatC <= attente_start;
        end if;

      when attente_start => 
        if (cpt_tmpClk < 8) then		--compteur de cycles du clock 
          tmpClk <= '0';
          cpt_tmpClk := cpt_tmpClk + 1;
        else 
          cpt_tmpClk := 1;
        	tmpClk <= '1';				--enableTX passe a 1 apres 16 (facteur) cycles de clk
          tmpRxd <= '0';
          etatC <= envoie_bit;         
        end if;
                                  
      when envoie_bit =>
        tmpClk <= '0';
        if (cpt_envoi <= 10) then
          cpt_envoi := cpt_envoi + 1;
          etatC <= attente_bit;
        else
          if (rxd = '1') then
            cpt_envoi := 1;
            etatC <= repos;
          end if;
        end if;

      when attente_bit => 
        if (cpt_tmpClk < 15) then		--compteur de cycles du clock 
          tmpClk <= '0';
          cpt_tmpClk := cpt_tmpClk + 1;
        else 
          cpt_tmpClk := 1;
          tmpClk <= '1';				--enableTX passe a 1 apres 16 (facteur) cycles de clk
          tmpRxd <= rxd;
          etatC <= envoie_bit;       
        end if;
      end case;
    end if; 
  end process;

  
  process(clk, reset)		  --process synchrone

    variable parite_recu, stop_recu, donnee_recu : std_logic := '0';
    variable parite : std_logic := '0';
    variable cpt_controle : natural := 0;
    
    begin
    
    if(reset = '0') then
      DRdy <= '0';
      FErr <= '0';
      OErr <= '0';
      etatR <= repos;
    elsif(rising_edge(clk)) then
      if(tmpClk = '1') then
          case etatR is
          
          when repos =>
            if (tmpRxd = '0') then
              etatR <= reception_donnee;
            end if;
          
          when reception_donnee =>
            if (cpt_controle = 0) then
              registerR(cpt_controle) <= tmpRxd;
              parite := registerR(cpt_controle);
            elsif (cpt_controle < 7) then
              registerR(cpt_controle) <= tmpRxd;
              parite := parite xor registerR(cpt_controle); 			--calcul du bit de parité
            else
              cpt_controle := 0;
              etatR <= reception_parite;
            end if;
            cpt_controle := cpt_controle + 1;
          
          when reception_parite => 
            parite_recu := tmpRxd;
            etatR <= reception_fin;
          
          when reception_fin =>
            stop_recu := tmpRxd;
            if(not(parite_recu = parite and stop_recu = '1')) then
              FErr <= '1';
              etatR <= fin_transmission_err;
            else
              FErr <= '0';
              DRdy <= '1';
              donnee_recu := '1';
              data <= registerR(0)&registerR(1)&registerR(2)&registerR(3)&registerR(4)&registerR(5)&registerR(6)&registerR(7);
              etatR <= fin_transmission;
            end if;
          when others =>
            null;
          end case;
      else
        case etatR is
          when fin_transmission =>
            DRdy <= '0';
            if (read = '0') then
              OErr <= '1';
              donnee_recu := '0';
            end if;
            etatR <= repos;
          when fin_transmission_err =>
            FErr <= '0';
            etatR <= repos;
          when repos =>
            OErr <= '0';
          
          when others =>
              null;
          end case;
      end if;
    end if;

 end process;


end RxUnit_arch;
