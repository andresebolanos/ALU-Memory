library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memory is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        address     : in  std_logic_vector(7 downto 0);
        datain      : in  std_logic_vector(7 downto 0);
        write       : in  std_logic;
        port_in_00  : in  std_logic_vector(7 downto 0);  -- Un solo puerto de entrada
        port_out_00 : out std_logic_vector(7 downto 0); -- Un solo puerto de salida (conecta a LEDs)
        dataout     : out std_logic_vector(7 downto 0);

        hex0        : out std_logic_vector(6 downto 0);
        hex1        : out std_logic_vector(6 downto 0);
        hex2        : out std_logic_vector(6 downto 0);
        hex3        : out std_logic_vector(6 downto 0)
    );
end entity;

architecture structural of memory is

    -- Declaración de componentes
    component rom_128x8
        port (
            clock   : in  std_logic;
            address : in  std_logic_vector(6 downto 0);
            data    : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component ram_128x8
        port (
            clock   : in  std_logic;
            reset   : in  std_logic;
            address : in  std_logic_vector(6 downto 0);
            datain  : in  std_logic_vector(7 downto 0);
            write   : in  std_logic;
            dataout : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component mux
        port (
            address     : in  std_logic_vector(7 downto 0);
            rom_data    : in  std_logic_vector(7 downto 0);
            ram_data    : in  std_logic_vector(7 downto 0);
            port_data   : in  std_logic_vector(7 downto 0);
            data_out    : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component hex7seg
        port (
            hex : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Señales internas
    signal rom_data       : std_logic_vector(7 downto 0);
    signal ram_data       : std_logic_vector(7 downto 0);
    signal dataout_int    : std_logic_vector(7 downto 0);
    signal write_ram      : std_logic;
    signal write_port     : std_logic;

begin

    -- Instancia ROM
    U_ROM: rom_128x8
        port map (
            clock   => clock,
            address => address(6 downto 0),
            data    => rom_data
        );

    -- Instancia RAM
    U_RAM: ram_128x8
        port map (
            clock   => clock,
            reset   => reset,
            address => address(6 downto 0),
            datain  => datain,
            write   => write_ram,
            dataout => ram_data
        );

    -- Lógica de control de escritura
    -- RAM: escribir solo si address >= 0x80 Y address != 0xE0 (puerto de salida)
    write_ram  <= '1' when (write = '1' and address(7) = '1' and address /= x"E0") else '0';
    write_port <= '1' when (write = '1' and address = x"E0") else '0';

    -- Puerto de salida (registro en 0xE0)
    process(clock, reset)
    begin
        if reset = '1' then
            port_out_00 <= x"00";
        elsif rising_edge(clock) then
            if write_port = '1' then
                port_out_00 <= datain;
            end if;
        end if;
    end process;

    -- Instancia MUX
    U_MUX: mux
        port map (
            address   => address,
            rom_data  => rom_data,
            ram_data  => ram_data,
            port_data => port_in_00,
            data_out  => dataout_int
        );

    dataout <= dataout_int;

    -- Displays de 7 segmentos
    U_HEX0: hex7seg port map (hex => dataout_int(3 downto 0), seg => hex0);
    U_HEX1: hex7seg port map (hex => dataout_int(7 downto 4), seg => hex1);
    U_HEX2: hex7seg port map (hex => address(3 downto 0),     seg => hex2);
    U_HEX3: hex7seg port map (hex => address(7 downto 4),     seg => hex3);

end architecture;
