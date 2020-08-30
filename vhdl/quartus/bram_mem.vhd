-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_misc.all;

use work.configure.all;

library std;
use std.textio.all;

entity bram_mem is
	generic(
		bram_depth : integer := bram_depth
	);
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		-- BRAM Interface
		bram_wen   : in  std_logic;
		bram_ren   : in  std_logic;
		bram_ready : out std_logic;
		bram_instr : in  std_logic;
		bram_addr  : in  std_logic_vector(bram_depth-1 downto 0);
		bram_wdata : in  std_logic_vector(63 downto 0);
		bram_wstrb : in  std_logic_vector(7 downto 0);
		bram_rdata : out std_logic_vector(63 downto 0)
	);
end bram_mem;

architecture behavior of bram_mem is

	type word_type is array (0 to 7) of std_logic_vector(7 downto 0);
	type memory_type is array (0 to 2**bram_depth-1) of word_type;

	impure function init_memory(
		file_name : in string
	)
	return memory_type is
		file memory_file      : text open read_mode is file_name;
		variable memory_line  : line;
		variable memory_block : memory_type;
		variable memory_word  : std_logic_vector(63 downto 0);
	begin
		for i in 0 to 2**bram_depth-1 loop
			readline(memory_file, memory_line);
			hread(memory_line, memory_word);
			memory_block(i)(7) := memory_word(63 downto 56);
			memory_block(i)(6) := memory_word(55 downto 48);
			memory_block(i)(5) := memory_word(47 downto 40);
			memory_block(i)(4) := memory_word(39 downto 32);
			memory_block(i)(3) := memory_word(31 downto 24);
			memory_block(i)(2) := memory_word(23 downto 16);
			memory_block(i)(1) := memory_word(15 downto 8);
			memory_block(i)(0) := memory_word(7 downto 0);
		end loop;
		return memory_block;
	end function;

	signal memory_block : memory_type := init_memory("bram_mem.dat");

	attribute ramstyle : string;
	attribute ramstyle of memory_block : signal is "M10K";

	signal rdata : word_type := (others => (others => '0'));
	signal ready : std_logic := '0';

begin

	bram_rdata <= rdata(7) & rdata(6) & rdata(5) & rdata(4) &
					rdata(3) & rdata(2) & rdata(1) & rdata(0);
	bram_ready <= ready;

	process(clock)
	begin

		if rising_edge(clock) then

			if bram_wen = '1' then

				if bram_wstrb(7) = '1' then
					memory_block(to_integer(unsigned(bram_addr)))(7) <= bram_wdata(63 downto 56);
				end if;
				if bram_wstrb(6) = '1' then
					memory_block(to_integer(unsigned(bram_addr)))(6) <= bram_wdata(55 downto 48);
				end if;
				if bram_wstrb(5) = '1' then
					memory_block(to_integer(unsigned(bram_addr)))(5) <= bram_wdata(47 downto 40);
				end if;
				if bram_wstrb(4) = '1' then
					memory_block(to_integer(unsigned(bram_addr)))(4) <= bram_wdata(39 downto 32);
				end if;
				if bram_wstrb(3) = '1' then
					memory_block(to_integer(unsigned(bram_addr)))(3) <= bram_wdata(31 downto 24);
				end if;
				if bram_wstrb(2) = '1' then
					memory_block(to_integer(unsigned(bram_addr)))(2) <= bram_wdata(23 downto 16);
				end if;
				if bram_wstrb(1) = '1' then
					memory_block(to_integer(unsigned(bram_addr)))(1) <= bram_wdata(15 downto 8);
				end if;
				if bram_wstrb(0) = '1' then
					memory_block(to_integer(unsigned(bram_addr)))(0) <= bram_wdata(7 downto 0);
				end if;

				ready <= '1';
			
			elsif bram_ren = '1' then
			
				rdata <= memory_block(to_integer(unsigned(bram_addr)));

				ready <= '1';

			else

				ready <= '0';

			end if;

		end if;

	end process;

end architecture;
