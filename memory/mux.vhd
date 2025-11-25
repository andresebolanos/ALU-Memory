library IEEE;
use IEEE.std_logic_1164.all;

entity mux is
    port (
        address     : in  std_logic_vector(7 downto 0);
        rom_data    : in  std_logic_vector(7 downto 0);
        ram_data    : in  std_logic_vector(7 downto 0);
        port_data   : in  std_logic_vector(7 downto 0);
        data_out    : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of mux is
begin
    process(address, rom_data, ram_data, port_data)
    begin
        if address(7) = '0' then
            -- ROM: 0x00 - 0x7F
            data_out <= rom_data;
        elsif address = x"F0" then
            -- Puerto de entrada: 0xF0
            data_out <= x"E0";
        else
            -- RAM: 0x80 - 0xEF (excepto 0xF0)
            data_out <= ram_data;
        end if;
    end process;
end architecture;
