-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use std.textio.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity top_cpu is
	port(
		rst   : in  std_logic;
		clk   : in  std_logic;
		rx    : in  std_logic;
		tx    : out std_logic
	);
end entity top_cpu;

architecture behavior of top_cpu is

	component cpu
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			rtc   : in  std_logic;
			rx    : in  std_logic;
			tx    : out std_logic
		);
	end component;

	signal rtc   : std_logic := '0';
	signal count : unsigned(31 downto 0) := (others => '0');

	signal clk_pll   : std_logic := '0';
	signal count_pll : unsigned(31 downto 0) := (others => '0');

begin

	process (clk)

	begin

		if (rising_edge(clk)) then
			if count = clk_divider_rtc then
				rtc <= not rtc;
				count <= (others => '0');
			else
				count <= count + 1;
			end if;

			if count_pll = clk_divider_pll then
				clk_pll <= not clk_pll;
				count_pll <= (others => '0');
			else
				count_pll <= count_pll + 1;
			end if;
		end if;

	end process;

	cpu_comp : cpu
		port map(
			reset => rst,
			clock => clk_pll,
			rtc   => rtc,
			rx    => rx,
			tx    => tx
		);

end architecture;
