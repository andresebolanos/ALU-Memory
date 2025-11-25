library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram_128x8 is
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        address : in  std_logic_vector(6 downto 0);
        datain  : in  std_logic_vector(7 downto 0);
        write   : in  std_logic;
        dataout : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of ram_128x8 is
    type ram_type is array (0 to 127) of std_logic_vector(7 downto 0);
    signal RAM : ram_type;
    
begin
    process(clock, reset)
    begin
        if reset = '1' then
            -- Inicializar RAM a ceros
            for i in 0 to 127 loop
                RAM(i) <= x"00";
            end loop;
            dataout <= x"00";
        elsif rising_edge(clock) then
            if write = '1' then
                RAM(to_integer(unsigned(address))) <= datain;
            end if;
            dataout <= RAM(to_integer(unsigned(address)));
        end if;
    end process;
end architecture;
