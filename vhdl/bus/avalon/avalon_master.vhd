-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity avalon_master is
	port(
		reset             : in  std_logic;
		clock             : in  std_logic;
		-- Avalon Master Interface
		avm_address       : out std_logic_vector(63 downto 0);
		avm_burstcount    : out std_logic_vector(10 downto 0);
		avm_byteenable    : out std_logic_vector(7 downto 0);
		avm_read          : out std_logic;
		avm_readdata      : in  std_logic_vector(63 downto 0);
		avm_readdatavalid : in  std_logic;
		avm_write         : out std_logic;
		avm_writedata     : out std_logic_vector(63 downto 0);
		avm_waitrequest   : in  std_logic;
		-- Memory Interface
		mem_valid         : in  std_logic;
		mem_ready         : out std_logic;
		mem_instr         : in  std_logic;
		mem_addr          : in  std_logic_vector(63 downto 0);
		mem_wdata         : in  std_logic_vector(63 downto 0);
		mem_wstrb         : in  std_logic_vector(7 downto 0);
		mem_rdata         : out std_logic_vector(63 downto 0)
	);
end avalon_master;

architecture behavior of avalon_master is

	type bus_state_type is (idle, active, busy);

	type reg_type is record
		bus_state         : bus_state_type;
		mem_valid         : std_logic;
		mem_instr         : std_logic;
		mem_addr          : std_logic_vector(63 downto 0);
		mem_wdata         : std_logic_vector(63 downto 0);
		mem_wstrb         : std_logic_vector(7 downto 0);
		mem_we            : std_logic;
		mem_re            : std_logic;
	end record;

	constant init_reg  : reg_type := (
		bus_state => idle,
		mem_valid => '0',
		mem_instr => '0',
		mem_addr => (others => '0'),
		mem_wdata => (others => '0'),
		mem_wstrb => (others => '0'),
		mem_we => '0',
		mem_re => '0'
	);

	signal r, rin      : reg_type := init_reg;

begin

	process(avm_readdata,avm_readdatavalid,avm_waitrequest,
					mem_valid,mem_instr,mem_addr,mem_wdata,mem_wstrb)

		variable v        : reg_type;

	begin

		v := r;

		case r.bus_state is
			when idle =>
				if mem_valid = '1' then
					v.bus_state := active;
				end if;
			when active =>
				if avm_waitrequest = '1' then
					v.bus_state := busy;
				end if;
			when busy =>
				if avm_waitrequest = '0' then
					if mem_valid = '1' then
						v.bus_state := active;
					elsif mem_valid = '0' then
						v.bus_state := idle;
					end if;
				end if;
		end case;

		case r.bus_state is
			when idle =>
				avm_address <= mem_addr;
				avm_burstcount <= "00000000001";
				avm_byteenable <= mem_wstrb;
				avm_writedata <= mem_wdata;
				avm_write <= mem_valid and or_reduce(mem_wstrb);
				avm_read <= mem_valid and nor_reduce(mem_wstrb);
				----------------------------------------------------
				mem_rdata <= avm_readdata;
				mem_ready <= not(avm_waitrequest) or avm_readdatavalid;
			when active =>
				v.mem_valid := mem_valid;
				v.mem_instr := mem_instr;
				v.mem_addr := mem_addr;
				v.mem_wstrb := mem_wstrb;
				v.mem_wdata := mem_wdata;
				v.mem_we := mem_valid and or_reduce(mem_wstrb);
				v.mem_re := mem_valid and nor_reduce(mem_wstrb);
				----------------------------------------------------
				avm_address <= v.mem_addr;
				avm_burstcount <= "00000000001";
				avm_byteenable <= v.mem_wstrb;
				avm_writedata <= v.mem_wdata;
				avm_write <= v.mem_we;
				avm_read <= v.mem_re;
				----------------------------------------------------
				mem_rdata <= avm_readdata;
				mem_ready <= not(avm_waitrequest) or avm_readdatavalid;
			when busy =>
				avm_address <= r.mem_addr;
				avm_burstcount <= "00000000001";
				avm_byteenable <= r.mem_wstrb;
				avm_writedata <= r.mem_wdata;
				avm_write <= r.mem_we;
				avm_read <= r.mem_re;
				----------------------------------------------------
				mem_rdata <= avm_readdata;
				mem_ready <= not(avm_waitrequest) or avm_readdatavalid;
		end case;

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
