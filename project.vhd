----------------------------------------------------------------------------------
-- Alessandro Piani
-- Matricola: 910280 
-- Module Name: project_reti_logiche
-- Project Name: Progetto Reti Logiche
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
    port (     i_clk: in std_logic;
               i_rst: in std_logic;
               i_data: in std_logic_vector(7 downto 0);
               o_data: out std_logic_vector(7 downto 0);
               o_addrRead: out std_logic_vector(15 downto 0);
               o_addrWrite: out std_logic_vector(15 downto 0);
               r1_load: in std_logic;
               r2_load: in std_logic;
               r3_load: in std_logic;
               r4_load: in std_logic;
               r5_load: in std_logic;
               r6_load: in std_logic;
               r7_load: in std_logic;
               r8_load: in std_logic;
               r10_load: in std_logic;
               r4_sel: in std_logic;
               r5_sel: in std_logic;
               r8_sel: in std_logic;
               r10_sel: in std_logic;
               o_end0: out std_logic;
               o_end1: out std_logic;
               o_zero: out std_logic );
end datapath;

--datapath
architecture Behavioral of datapath is
    signal o_reg1, o_reg2: std_logic_vector(7 downto 0);
    signal o_reg3: std_logic_vector(7 downto 0);
    signal o_reg4, o_reg5: std_logic_vector(7 downto 0);
    signal o_reg6: std_logic_vector(7 downto 0);
    signal o_reg7: std_logic_vector(7 downto 0);
    signal o_reg8: std_logic_vector(15 downto 0);
    signal o_reg10: std_logic_vector(15 downto 0);
    signal mux_reg4, mux_reg5: std_logic_vector(7 downto 0);
    signal mux_reg8: std_logic_vector(15 downto 0);
    signal mux_reg10: std_logic_vector(15 downto 0);
    signal mul: unsigned(15 downto 0);
    signal addrEnd: unsigned(15 downto 0);
    signal shiftLevel: unsigned(3 downto 0);
    signal tempPixel, tmp: unsigned(15 downto 0);
    signal tmpMax, tmpMin: unsigned(7 downto 0);
    signal sub: unsigned(7 downto 0);
    signal deltaValue: unsigned(7 downto 0);
    
begin
    process(i_clk, i_rst) --registro il num colonne
    begin
        if(i_rst= '1') then
            o_reg1 <= "00000000";
        elsif rising_edge(i_clk) then  --i_clk'event and i_clk= '1'
            if(r1_load= '1') then
                o_reg1 <= i_data;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst) --registro il num righe
    begin
        if(i_rst= '1') then
            o_reg2 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r2_load= '1') then
                o_reg2 <= i_data;
            end if;
        end if;
    end process;
    
    mul <= TO_UNSIGNED((TO_INTEGER(UNSIGNED(o_reg1))*TO_INTEGER(UNSIGNED(o_reg2))),16); --dimensione immagine
    o_zero <= '1' when (mul = 0) else '0';
    addrEnd <= TO_UNSIGNED((TO_INTEGER(mul)*2),16) + "0000000000000001"; --indirizzo ultimo byte immagine equalizzata
    
    process(i_clk, i_rst) --registro il current pixel da trasformare
    begin
        if(i_rst= '1') then
            o_reg3 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r3_load= '1') then
                o_reg3 <= i_data;
            end if;
        end if;
    end process;
    
    tmpMax <= UNSIGNED(o_reg3) when (UNSIGNED(o_reg3) > UNSIGNED(o_reg4)) else UNSIGNED(o_reg4);
    
    with r4_sel select
        mux_reg4 <= "00000000" when '0',
                    std_logic_vector(tmpMax) when '1',
                    "XXXXXXXX" when others;
    
    process(i_clk, i_rst) --registro il max pixel
    begin
        if(i_rst= '1') then
            o_reg4 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r4_load= '1') then
                o_reg4 <= mux_reg4;
            end if;
        end if;
    end process;
    
    tmpMin <= UNSIGNED(o_reg3) when (UNSIGNED(o_reg3) < UNSIGNED(o_reg5)) else UNSIGNED(o_reg5);
    
    with r5_sel select
        mux_reg5 <= "11111111" when '0',
                    std_logic_vector(tmpMin) when '1',
                    "XXXXXXXX" when others;
    
    process(i_clk, i_rst) --registro il min pixel
    begin
        if(i_rst= '1') then
            o_reg5 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r5_load= '1') then
                o_reg5 <= mux_reg5;
            end if;
        end if;
    end process;
    
    with r8_sel select
        mux_reg8 <= std_logic_vector((mul + "0000000000000010")) when '0',
                    (o_reg8 + "0000000000000001") when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    process(i_clk, i_rst) --registro l'indirizzo in cui vado a scrivere il pixel equalizzato
    begin
        if(i_rst= '1') then
            o_reg8 <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(r8_load= '1') then
                o_reg8 <= mux_reg8;
            end if;
        end if;
    end process;
    
    o_addrWrite <= o_reg8; --indirizzo in cui vado a scrivere il pixel equalizzato
    o_end1 <= '1' when (addrEnd = UNSIGNED(o_reg8)) else '0';
    
    with r10_sel select
        mux_reg10 <= "0000000000000010" when '0',
                    (o_reg10 + "0000000000000001") when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    process(i_clk, i_rst) --registro l'indirizzo in cui vado a leggere il pixel da trasformare
    begin
        if(i_rst= '1') then
            o_reg10 <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(r10_load= '1') then
                o_reg10 <= mux_reg10;
            end if;
        end if;
    end process;
    
    o_addrRead <= o_reg10; --indirizzo in cui vado a leggere il pixel da trasformare
    o_end0 <= '1' when (o_reg10 = o_reg8) else '0';
    
    deltaValue <= UNSIGNED(o_reg4) - UNSIGNED(o_reg5);
    
    process(i_clk, i_rst) --registro delta value
    begin
        if(i_rst= '1') then
            o_reg6 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r6_load= '1') then
                o_reg6 <= std_logic_vector(deltaValue);
            end if;
        end if;
    end process;
    
    process(o_reg6) --calcolo shift_level
    begin
        if UNSIGNED(o_reg6) = 0 then
            shiftLevel <= TO_UNSIGNED(8,4);
        elsif UNSIGNED(o_reg6) >= 1 and UNSIGNED(o_reg6) <= 2 then
            shiftLevel <= TO_UNSIGNED(7,4);
        elsif UNSIGNED(o_reg6) >= 3 and UNSIGNED(o_reg6) <= 6 then
            shiftLevel <= TO_UNSIGNED(6,4);
        elsif UNSIGNED(o_reg6) >= 7 and UNSIGNED(o_reg6) <= 14 then
            shiftLevel <= TO_UNSIGNED(5,4);
        elsif UNSIGNED(o_reg6) >= 15 and UNSIGNED(o_reg6) <= 30 then
            shiftLevel <= TO_UNSIGNED(4,4);
        elsif UNSIGNED(o_reg6) >= 31 and UNSIGNED(o_reg6) <= 62 then
            shiftLevel <= TO_UNSIGNED(3,4);
        elsif UNSIGNED(o_reg6) >= 63 and UNSIGNED(o_reg6) <= 126 then
            shiftLevel <= TO_UNSIGNED(2,4);
        elsif UNSIGNED(o_reg6) >= 127 and UNSIGNED(o_reg6) <= 254 then
            shiftLevel <= TO_UNSIGNED(1,4);
        else
            shiftLevel <= TO_UNSIGNED(0,4);
        end if;
    end process;
    
    sub <= UNSIGNED(o_reg3) - UNSIGNED(o_reg5); --differenza tra current e min pixel
    
    process(i_clk, i_rst) --registro differenza tra current e min pixel
    begin
        if(i_rst= '1') then
            o_reg7 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r7_load= '1') then
                o_reg7 <= std_logic_vector(sub);
            end if;
        end if;
    end process;
    
    process(o_reg7, i_clk, tmp, shiftLevel) --calcolo temp_pixel
    begin
        tmp <= UNSIGNED("00000000" & o_reg7);
        tempPixel <= shift_left(tmp, TO_INTEGER(shiftLevel));
    end process;
    
    o_data <= std_logic_vector(tempPixel(7 downto 0)) when (tempPixel < 255) else "11111111";
    
end Behavioral;

-- FSM di Moore
architecture Behavioral of project_reti_logiche is
    component datapath is
        port ( i_clk: in std_logic;
               i_rst: in std_logic;
               i_data: in std_logic_vector(7 downto 0);
               o_data: out std_logic_vector(7 downto 0);
               o_addrRead: out std_logic_vector(15 downto 0);
               o_addrWrite: out std_logic_vector(15 downto 0);
               r1_load: in std_logic;
               r2_load: in std_logic;
               r3_load: in std_logic;
               r4_load: in std_logic;
               r5_load: in std_logic;
               r6_load: in std_logic;
               r7_load: in std_logic;
               r8_load: in std_logic;
               r10_load: in std_logic;
               r4_sel: in std_logic;
               r5_sel: in std_logic;
               r8_sel: in std_logic;
               r10_sel: in std_logic;
               o_end0: out std_logic;
               o_end1: out std_logic;
               o_zero: out std_logic );
    end component;
    signal o_addrRead: std_logic_vector(15 downto 0);
    signal o_addrWrite: std_logic_vector(15 downto 0);
    signal r1_load, r2_load: std_logic;
    signal r3_load: std_logic;
    signal r4_load, r5_load: std_logic;
    signal r6_load: std_logic;
    signal r7_load: std_logic;
    signal r8_load: std_logic;
    signal r10_load: std_logic;
    signal r4_sel, r5_sel: std_logic;
    signal r8_sel: std_logic;
    signal r10_sel: std_logic;
    signal o_end0, o_end1: std_logic;
    signal o_zero: std_logic;
    type stateType is (Sreset, Senable, Scol, SaddrRow, Srow, SaddrPix, SreadPix, SnextPix, Sdelta, SpixToConv, Ssub, Swrite, SnextPixWrite, 
                        SaddrPixConv, SnextPixConv, Sdone);
    signal curr_state, next_state : stateType;

begin
    DATAPATH0: datapath port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_data => i_data,
        o_data => o_data,
        o_addrRead => o_addrRead,
        o_addrWrite => o_addrWrite,
        r1_load => r1_load,
        r2_load => r2_load,
        r3_load => r3_load,
        r4_load => r4_load,
        r5_load => r5_load,
        r6_load => r6_load,
        r7_load => r7_load,
        r8_load => r8_load,
        r10_load => r10_load,
        r4_sel => r4_sel,
        r5_sel => r5_sel,
        r8_sel => r8_sel,
        r10_sel => r10_sel,
        o_end0 => o_end0,
        o_end1 => o_end1,
        o_zero => o_zero );
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            curr_state <= Sreset;
        elsif rising_edge(i_clk) then  --al posto di i_clk'event and i_clk= '1'
            curr_state <= next_state;
        end if;
    end process;
    
    --funzione stato prossimo
    process(curr_state, i_start, o_end0, o_end1, o_zero)
    begin
        next_state <= curr_state;
        case curr_state is
            when Sreset =>
                if i_start= '1' then
                    next_state <= Senable;
                end if;
            when Senable =>
                next_state <= Scol;
            when Scol =>
                next_state <= SaddrRow;
            when SaddrRow =>
                next_state <= Srow;
            when Srow =>
                next_state <= SaddrPix;
            when SaddrPix =>
                if o_zero= '1' then
                    next_state <= Sdone;
                else
                    next_state <= SreadPix;
                end if;
            when SreadPix =>
                next_state <= SnextPix;
            when SnextPix =>
                if o_end0= '1' then
                    next_state <= Sdelta;
                else
                    next_state <= SaddrPix;
                end if;
            when Sdelta =>
                next_state <= SpixToConv;
            when SpixToConv =>
                next_state <= Ssub;
            when Ssub =>
                next_state <= Swrite;
            when Swrite =>
                if o_end1= '1' then
                    next_state <= Sdone;
                else
                    next_state <= SnextPixWrite;
                end if;
            when SnextPixWrite =>
                next_state <= SaddrPixConv;
            when SaddrPixConv =>
                next_state <= SnextPixConv;
            when SnextPixConv =>
                next_state <= Ssub;
            when Sdone =>
                if i_start = '1' then
                    next_state <= Sdone;
                else
                    next_state <= Sreset;
                end if;
        end case;                            
    end process;
    
    --funzione di uscita
    process(curr_state, o_addrRead, o_addrWrite)
    begin
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        r4_load <= '0';
        r5_load <= '0';
        r6_load <= '0';
        r7_load <= '0';
        r8_load <= '0';
        r10_load <= '0';
        r4_sel <= '0';
        r5_sel <= '0';
        r8_sel <= '0';
        r10_sel <= '0';
        o_address <= "0000000000000000";
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        case curr_state is
            when Sreset =>
            when Senable =>
                o_en <= '1';
            when Scol =>
                o_address <= "0000000000000000";
                o_en <= '1';
                r1_load <= '1';
                r4_load <= '1';
                r5_load <= '1';
                r10_load <= '1';
            when SaddrRow =>
                o_address <= "0000000000000001";
                o_en <= '1';
                r1_load <= '0';
            when Srow =>
                o_address <= "0000000000000001";
                o_en <= '1';
                r1_load <= '0';
                r2_load <= '1';
                r4_load <= '0';
                r5_load <= '0';
                r10_load <= '0';
                r10_sel <= '1';
            when SaddrPix =>
                o_address <= o_addrRead;
                o_en <= '1';
                r3_load <= '0';
                r4_sel <= '1';
                r5_sel <= '1';
                r8_load <= '1';
                r10_sel <= '1';
                r10_load <= '0';
            when SreadPix =>
                o_address <= o_addrRead;
                o_en <= '1';
                r3_load <= '1';
                r4_sel <= '1';
                r5_sel <= '1';
                r4_load <= '0';
                r5_load <= '0';
                r8_load <= '0';
                r10_load <= '1';
                r10_sel <= '1';
            when SnextPix =>
                o_address <= o_addrRead;
                o_en <= '1';
                r3_load <= '0';
                r4_sel <= '1';
                r5_sel <= '1';
                r4_load <= '1';
                r5_load <= '1';
                r8_load <= '1';
                r10_load <= '0';
                r10_sel <= '1';
            when Sdelta =>
                o_address <= "0000000000000010";
                o_en <= '1';
                r4_load <= '0';
                r5_load <= '0';
                r6_load <= '1';
                r8_sel <= '1';
                r10_sel <= '0';
                r10_load <= '1';
            when SpixToConv =>
                o_address <= "0000000000000010";
                o_en <= '1';
                r3_load <= '1';
                r6_load <= '0';
                r8_sel <= '1';
                r10_sel <= '1';
            when Ssub =>
                o_address <= o_addrRead;
                o_en <= '1';
                r3_load <= '1';
                r7_load <= '1';
                r8_sel <= '1';
                r10_sel <= '1';
            when Swrite =>
                o_address <= o_addrWrite;
                o_en <= '1';
                o_we <= '1';
                r7_load <= '0';
                r8_sel <= '1';
                r10_sel <= '1';
                r10_load <= '1';
            when SnextPixWrite =>
                o_address <= o_addrRead;
                o_en <= '1';
                o_we <= '0';
                r7_load <= '0';
                r8_sel <= '1';
                r8_load <= '1';
                r10_load <= '0';
            when SaddrPixConv =>
                o_address <= o_addrRead;
                o_en <= '1';
                r3_load <= '0';
                r8_sel <= '1';
                r10_sel <= '1';
            when SnextPixConv =>
                o_address <= o_addrRead;
                o_en <= '1';
                r3_load <= '1';
                r8_sel <= '1';
                r10_sel <= '1';
            when Sdone =>
                o_done <= '1';
                o_en <= '0';
                o_we <= '0';
        end case;
    end process;
end Behavioral;