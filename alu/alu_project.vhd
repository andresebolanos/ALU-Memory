library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_project is
   port(
      -- Entradas
      A     : in  std_logic_vector(7 downto 0);
      B     : in  std_logic_vector(7 downto 0);
      Sel   : in  std_logic; -- '0' suma, '1' resta
      
      -- Salidas
      Y     : out std_logic_vector(7 downto 0);
      Carry : out std_logic;
      Ovf   : out std_logic;
      Neg   : out std_logic;
      Zero  : out std_logic;
      
      -- Displays 7-segmentos
      hex0  : out std_logic_vector(6 downto 0);  -- Y nibble bajo
      hex1  : out std_logic_vector(6 downto 0);  -- Y nibble alto
      hex2  : out std_logic_vector(6 downto 0);  -- B nibble bajo
      hex3  : out std_logic_vector(6 downto 0)   -- B nibble alto
   );
end entity;

architecture rtl of alu_project is

   signal sum_result  : unsigned(8 downto 0);  -- 9 bits para capturar carry
   signal Y_int       : std_logic_vector(7 downto 0);
   signal A_unsigned  : unsigned(8 downto 0);  -- 9 bits
   signal B_unsigned  : unsigned(8 downto 0);  -- 9 bits
   signal A_signed    : signed(7 downto 0);
   signal B_signed    : signed(7 downto 0);
   signal result_sign : signed(7 downto 0);

   -- Función decodificador hexadecimal a 7 segmentos (activo bajo)
   function hex_to_7seg(hex : std_logic_vector(3 downto 0)) return std_logic_vector is
      variable segs : std_logic_vector(6 downto 0);
   begin
      case hex is
         when "0000" => segs := "1000000"; -- 0
         when "0001" => segs := "1111001"; -- 1
         when "0010" => segs := "0100100"; -- 2
         when "0011" => segs := "0110000"; -- 3
         when "0100" => segs := "0011001"; -- 4
         when "0101" => segs := "0010010"; -- 5
         when "0110" => segs := "0000010"; -- 6
         when "0111" => segs := "1111000"; -- 7
         when "1000" => segs := "0000000"; -- 8
         when "1001" => segs := "0010000"; -- 9
         when "1010" => segs := "0001000"; -- A
         when "1011" => segs := "0000011"; -- b
         when "1100" => segs := "1000110"; -- C
         when "1101" => segs := "0100001"; -- d
         when "1110" => segs := "0000110"; -- E
         when "1111" => segs := "0001110"; -- F
         when others => segs := "1111111"; -- blank
      end case;
      return segs;
   end function;

begin

   -- Extender A y B a 9 bits (unsigned) para evitar errores de tamaño
   A_unsigned <= "0" & unsigned(A);
   B_unsigned <= "0" & unsigned(B);

   -- Suma o resta según Sel
   process(A_unsigned, B_unsigned, Sel)
   begin
       if Sel = '0' then
           -- Suma
           sum_result <= A_unsigned + B_unsigned;
       else
           -- Resta (A - B)
           sum_result <= A_unsigned - B_unsigned;
       end if;
   end process;

   -- Resultado de 8 bits
   Y_int <= std_logic_vector(sum_result(7 downto 0));
   Y <= Y_int;

   -- Carry bit (bit 8 del resultado)
   Carry <= sum_result(8);

   -- Cálculo de Overflow usando aritmética signed
   A_signed <= signed(A);
   B_signed <= signed(B);
   result_sign <= signed(Y_int);

   -- Overflow ocurre cuando:
   -- Suma: operandos del mismo signo dan resultado de signo opuesto
   -- Resta: operandos de signo opuesto dan resultado de signo opuesto a A
   process(Sel, A_signed, B_signed, result_sign)
   begin
       if Sel = '0' then
           -- Overflow en suma
           if (A_signed(7) = B_signed(7)) and (result_sign(7) /= A_signed(7)) then
               Ovf <= '1';
           else
               Ovf <= '0';
           end if;
       else
           -- Overflow en resta
           if (A_signed(7) /= B_signed(7)) and (result_sign(7) /= A_signed(7)) then
               Ovf <= '1';
           else
               Ovf <= '0';
           end if;
       end if;
   end process;

   -- Flag NEGATIVO: se activa cuando el bit más significativo es 1
   Neg <= Y_int(7);

   -- Flag CERO: se activa cuando el resultado es exactamente cero
   Zero <= '1' when Y_int = "00000000" else '0';

   -- Displays 7-segmentos
   hex0 <= hex_to_7seg(Y_int(3 downto 0));   -- Resultado Y nibble bajo
   hex1 <= hex_to_7seg(Y_int(7 downto 4));   -- Resultado Y nibble alto
   hex2 <= hex_to_7seg(B(3 downto 0));       -- B nibble bajo
   hex3 <= hex_to_7seg(B(7 downto 4));       -- B nibble alto

end architecture;
