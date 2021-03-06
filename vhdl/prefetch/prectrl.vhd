-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity prectrl is
	generic(
		pfetch_depth : integer := pfetch_depth
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		pctrl_i   : in  prefetch_in_type;
		pctrl_o   : out prefetch_out_type;
		pbuffer_i : out prebuffer_in_type;
		pbuffer_o : in  prebuffer_out_type
	);
end prectrl;

architecture behavior of prectrl is

	type reg_type is record
		pc     : std_logic_vector(63 downto 0);
		npc    : std_logic_vector(63 downto 0);
		fpc    : std_logic_vector(63 downto 0);
		instr  : std_logic_vector(31 downto 0);
		wren   : std_logic;
		rden   : std_logic;
		wrdis  : std_logic;
		wrbuf  : std_logic;
		equal  : std_logic;
		full   : std_logic;
		wid    : natural range 0 to 2**pfetch_depth-1;
		rid    : natural range 0 to 2**pfetch_depth-1;
		stall  : std_logic;
	end record;

	constant init_reg : reg_type := (
		pc     => start_base_addr,
		npc    => start_base_addr,
		fpc    => start_base_addr,
		instr  => nop,
		wren   => '0',
		rden   => '0',
		wrdis  => '0',
		wrbuf  => '0',
		equal  => '0',
		full   => '0',
		wid    => 0,
		rid    => 0,
		stall  => '0'
	);

	signal r, rin : reg_type := init_reg;

begin

	process(r,pctrl_i,pbuffer_o)

	variable v : reg_type;

	begin

		v := r;

		v.instr := nop;
		v.stall := '0';
		v.wrdis := '0';
		v.wrbuf := '0';

		v.pc := pctrl_i.pc;
		v.npc := pctrl_i.npc;

		if pctrl_i.fence = '1' then
			v.fpc := v.pc(63 downto 3) & "000";
		end if;

		if pctrl_i.valid = '1' then
			v.wid := to_integer(unsigned(v.fpc(pfetch_depth downto 1)));
			v.rid := to_integer(unsigned(v.pc(pfetch_depth downto 1)));
		end if;

		v.equal := nor_reduce(v.fpc(63 downto 3) xor v.pc(63 downto 3));
		v.full := nor_reduce(v.fpc(pfetch_depth downto 3) xor v.pc(pfetch_depth downto 3));

		if v.equal = '1' then
			v.wren := '1';
			v.rden := '0';
		elsif v.full = '1' then
			v.wren := '0';
		elsif v.full = '0' then
			v.wren := '1';
			v.rden := '1';
		end if;

		if pctrl_i.ready = '1' then
			if v.wren = '1' then
				v.wrbuf := '1';
				v.fpc := std_logic_vector(unsigned(v.fpc) + 8);
			end if;
		elsif pctrl_i.ready = '0' then
			if v.wren = '1' then
				v.wrdis := '1';
			end if;
		end if;

		if pctrl_i.spec = '1' then
			v.fpc := v.npc(63 downto 3) & "000";
		end if;

		pbuffer_i.raddr <= v.rid;

		if v.rden = '1' then
			if v.rid = 2**pfetch_depth-1 then
				if (v.wid = 0) then
					if v.wrdis = '1' then
						v.stall := '1';
					else
						v.instr := pctrl_i.rdata(15 downto 0) & pbuffer_o.rdata(15 downto 0);
					end if;
				else
					v.instr := pbuffer_o.rdata;
				end if;
			else
				if v.wid = (v.rid+1) then
					if v.wrdis = '1' then
						v.stall := '1';
					else
						v.instr := pctrl_i.rdata(15 downto 0) & pbuffer_o.rdata(15 downto 0);
					end if;
				else
					v.instr := pbuffer_o.rdata;
				end if;
			end if;
		elsif pctrl_i.ready = '1' then
			if v.pc(2 downto 1) = "00" then
				v.instr := pctrl_i.rdata(31 downto 0);
			elsif v.pc(2 downto 1) = "01" then
				v.instr := pctrl_i.rdata(47 downto 16);
			elsif v.pc(2 downto 1) = "10" then
				v.instr := pctrl_i.rdata(63 downto 32);
			elsif v.pc(2 downto 1) = "11" then
				if and_reduce(pctrl_i.rdata(49 downto 48)) = '0' then
					v.instr := X"0000" & pctrl_i.rdata(63 downto 48);
				else
					v.stall := '1';
				end if;
			end if;
		elsif pctrl_i.ready = '0' then
			v.stall := '1';
		end if;

		pctrl_o.fpc <= v.fpc;
		pctrl_o.instr <= v.instr;
		pctrl_o.stall <= v.stall;

		pbuffer_i.wren <= v.wrbuf;
		pbuffer_i.waddr <= v.wid;
		pbuffer_i.wdata <= pctrl_i.rdata;

		rin <= v;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then

				r <= init_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
