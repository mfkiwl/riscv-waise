-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity ctrl is
	generic(
		cache_type      : integer;
		cache_set_depth : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		ctrl_i  : in  ctrl_in_type;
		ctrl_o  : out ctrl_out_type;
		cache_i : in  cache_in_type;
		cache_o : out cache_out_type;
		mem_o   : in  mem_out_type;
		mem_i   : out mem_in_type
	);
end ctrl;

architecture behavior of ctrl is

	type state_type is (HIT,MISS,UPDATE,INVALIDATE);

	type ctrl_type is record
		state   : state_type;
		count   : integer range 0 to 3;
		addr    : std_logic_vector(63 downto 0);
		invalid : std_logic;
		valid   : std_logic;
		tag     : std_logic_vector(58-cache_set_depth downto 0);
		cline   : std_logic_vector(255 downto 0);
		sid     : integer range 0 to 2**cache_set_depth-1;
		lid     : integer range 0 to 4;
		wid     : integer range 0 to 7;
		wvec    : std_logic_vector(7 downto 0);
		hit     : std_logic;
		miss    : std_logic;
		en      : std_logic;
		wen     : std_logic_vector(7 downto 0);
	end record;

	constant init_ctrl_type : ctrl_type := (
		state   => INVALIDATE,
		count   => 0,
		addr    => (others => '0'),
		valid   => '0',
		invalid => '0',
		tag     => (others => '0'),
		cline   => (others => '0'),
		sid     => 0,
		lid     => 0,
		wid     => 0,
		wvec    => (others => '0'),
		hit     => '0',
		miss    => '0',
		en      => '0',
		wen     => (others => '0')
	);

	type data_type is record
		state : state_type;
		cline : std_logic_vector(255 downto 0);
		rdata : std_logic_vector(63 downto 0);
		ready : std_logic;
		lid   : integer range 0 to 4;
		wid   : integer range 0 to 7;
		en    : std_logic;
	end record;

	constant init_data_type : data_type := (
		state => HIT,
		cline => (others => '0'),
		rdata => (others => '0'),
		ready => '0',
		lid   => 0,
		wid   => 0,
		en    => '0'
	);

	signal r,rin : ctrl_type := init_ctrl_type;
	signal r_next,rin_next : data_type := init_data_type;

begin

	process(ctrl_i,cache_i,mem_o,r)

	variable v : ctrl_type;

	begin

		v := r;

		v.hit := '0';
		v.miss := '0';
		v.invalid := '0';

		case r.state is

			when HIT =>

				if cache_i.mem_valid = '1' then
					v.en := cache_i.mem_valid;
					v.addr := cache_i.mem_addr(63 downto 5) & "00000";
					v.tag := cache_i.mem_addr(63 downto cache_set_depth+5);
					v.sid := to_integer(unsigned(cache_i.mem_addr(cache_set_depth+4 downto 5)));
					v.lid := to_integer(unsigned(cache_i.mem_addr(4 downto 3)));
				else
					v.en := '0';
				end if;

			when UPDATE =>

				v.en := '0';

			when others =>

				v.en := '0';

		end case;

		ctrl_o.data0_i.raddr <= v.sid;
		ctrl_o.data1_i.raddr <= v.sid;
		ctrl_o.data2_i.raddr <= v.sid;
		ctrl_o.data3_i.raddr <= v.sid;
		ctrl_o.data4_i.raddr <= v.sid;
		ctrl_o.data5_i.raddr <= v.sid;
		ctrl_o.data6_i.raddr <= v.sid;
		ctrl_o.data7_i.raddr <= v.sid;

		ctrl_o.tag0_i.raddr <= v.sid;
		ctrl_o.tag1_i.raddr <= v.sid;
		ctrl_o.tag2_i.raddr <= v.sid;
		ctrl_o.tag3_i.raddr <= v.sid;
		ctrl_o.tag4_i.raddr <= v.sid;
		ctrl_o.tag5_i.raddr <= v.sid;
		ctrl_o.tag6_i.raddr <= v.sid;
		ctrl_o.tag7_i.raddr <= v.sid;

		ctrl_o.valid_i.raddr <= v.sid;

		ctrl_o.hit_i.tag <= v.tag;
		ctrl_o.hit_i.tag0 <= ctrl_i.tag0_o.rdata;
		ctrl_o.hit_i.tag1 <= ctrl_i.tag1_o.rdata;
		ctrl_o.hit_i.tag2 <= ctrl_i.tag2_o.rdata;
		ctrl_o.hit_i.tag3 <= ctrl_i.tag3_o.rdata;
		ctrl_o.hit_i.tag4 <= ctrl_i.tag4_o.rdata;
		ctrl_o.hit_i.tag5 <= ctrl_i.tag5_o.rdata;
		ctrl_o.hit_i.tag6 <= ctrl_i.tag6_o.rdata;
		ctrl_o.hit_i.tag7 <= ctrl_i.tag7_o.rdata;
		ctrl_o.hit_i.valid <= ctrl_i.valid_o.rdata;

		case r.state is

			when HIT =>

				v.wvec := ctrl_i.valid_o.rdata;
				v.wen := (others => '0');

				v.hit := ctrl_i.hit_o.hit and v.en;
				v.miss := ctrl_i.hit_o.miss and v.en;
				v.wid := ctrl_i.hit_o.wid;

				if v.miss = '1' then
					v.state := MISS;
					v.count := 0;
					v.valid := '1';
				else
					v.valid := '0';
				end if;

			when MISS =>

				if r.miss = '1' then
					v.wid := ctrl_i.lru_o.wid;
				end if;

				if mem_o.mem_ready = '1' then

					case r.count is
						when 0 =>
							v.cline(63 downto 0) := mem_o.mem_rdata;
						when 1 =>
							v.cline(127 downto 64) := mem_o.mem_rdata;
						when 2 =>
							v.cline(191 downto 128) := mem_o.mem_rdata;
						when 3 =>
							v.cline(255 downto 192) := mem_o.mem_rdata;
							v.state := UPDATE;
						when others =>
							null;
					end case;

					v.addr(63 downto 3) := std_logic_vector(unsigned(v.addr(63 downto 3))+1);
					if v.count /= 3 then
						v.count := v.count + 1;
					end if;

				end if;

				if (cache_i.mem_valid and cache_i.mem_spec) = '1' then
					v.state := HIT;
				end if;

			when UPDATE =>

				v.wen(v.wid) := '1';
				v.wvec(v.wid) := '1';
				v.state := HIT;

			when INVALIDATE =>

				v.wen := (others => '0');
				v.wvec := (others => '0');
				v.invalid := '1';

			when others =>

				null;

		end case;

		if (cache_i.mem_valid and cache_i.mem_invalid) = '1' then
			v.sid := 0;
			v.state := INVALIDATE;
		end if;

		ctrl_o.data0_i.waddr <= v.sid;
		ctrl_o.data1_i.waddr <= v.sid;
		ctrl_o.data2_i.waddr <= v.sid;
		ctrl_o.data3_i.waddr <= v.sid;
		ctrl_o.data4_i.waddr <= v.sid;
		ctrl_o.data5_i.waddr <= v.sid;
		ctrl_o.data6_i.waddr <= v.sid;
		ctrl_o.data7_i.waddr <= v.sid;

		ctrl_o.data0_i.wen <= v.wen(0);
		ctrl_o.data1_i.wen <= v.wen(1);
		ctrl_o.data2_i.wen <= v.wen(2);
		ctrl_o.data3_i.wen <= v.wen(3);
		ctrl_o.data4_i.wen <= v.wen(4);
		ctrl_o.data5_i.wen <= v.wen(5);
		ctrl_o.data6_i.wen <= v.wen(6);
		ctrl_o.data7_i.wen <= v.wen(7);

		ctrl_o.data0_i.wdata <= v.cline;
		ctrl_o.data1_i.wdata <= v.cline;
		ctrl_o.data2_i.wdata <= v.cline;
		ctrl_o.data3_i.wdata <= v.cline;
		ctrl_o.data4_i.wdata <= v.cline;
		ctrl_o.data5_i.wdata <= v.cline;
		ctrl_o.data6_i.wdata <= v.cline;
		ctrl_o.data7_i.wdata <= v.cline;

		ctrl_o.tag0_i.waddr <= v.sid;
		ctrl_o.tag1_i.waddr <= v.sid;
		ctrl_o.tag2_i.waddr <= v.sid;
		ctrl_o.tag3_i.waddr <= v.sid;
		ctrl_o.tag4_i.waddr <= v.sid;
		ctrl_o.tag5_i.waddr <= v.sid;
		ctrl_o.tag6_i.waddr <= v.sid;
		ctrl_o.tag7_i.waddr <= v.sid;

		ctrl_o.tag0_i.wen <= v.wen(0);
		ctrl_o.tag1_i.wen <= v.wen(1);
		ctrl_o.tag2_i.wen <= v.wen(2);
		ctrl_o.tag3_i.wen <= v.wen(3);
		ctrl_o.tag4_i.wen <= v.wen(4);
		ctrl_o.tag5_i.wen <= v.wen(5);
		ctrl_o.tag6_i.wen <= v.wen(6);
		ctrl_o.tag7_i.wen <= v.wen(7);

		ctrl_o.tag0_i.wdata <= v.tag;
		ctrl_o.tag1_i.wdata <= v.tag;
		ctrl_o.tag2_i.wdata <= v.tag;
		ctrl_o.tag3_i.wdata <= v.tag;
		ctrl_o.tag4_i.wdata <= v.tag;
		ctrl_o.tag5_i.wdata <= v.tag;
		ctrl_o.tag6_i.wdata <= v.tag;
		ctrl_o.tag7_i.wdata <= v.tag;

		ctrl_o.valid_i.waddr <= v.sid;
		ctrl_o.valid_i.wen <= or_reduce(v.wen) or v.invalid;
		ctrl_o.valid_i.wdata <= v.wvec;

		ctrl_o.lru_i.sid <= v.sid;
		ctrl_o.lru_i.wid <= v.wid;
		ctrl_o.lru_i.hit <= v.hit;
		ctrl_o.lru_i.miss <= v.miss;

		if r.state = INVALIDATE then
			if v.sid = 2**cache_set_depth-1 then
				v.state := HIT;
			else
				v.sid := v.sid+1;
			end if;
		end if;

		rin <= v;

		mem_i.mem_valid <= v.valid;
		mem_i.mem_instr <= '1';
		mem_i.mem_addr <= v.addr;
		mem_i.mem_wdata <= (others => '0');
		mem_i.mem_wstrb <= (others => '0');

		rin_next.state <= v.state;
		rin_next.cline <= v.cline;
		rin_next.lid <= v.lid;
		rin_next.wid <= v.wid;
		rin_next.en <= v.en;

	end process;

	process(ctrl_i,r_next)

	variable v : data_type;

	begin

		v := r_next;

		if v.state = HIT then
			if v.wid = 0 then
					v.cline := ctrl_i.data0_o.rdata;
			elsif v.wid = 1 then
					v.cline := ctrl_i.data1_o.rdata;
			elsif v.wid = 2 then
					v.cline := ctrl_i.data2_o.rdata;
			elsif v.wid = 3 then
					v.cline := ctrl_i.data3_o.rdata;
			elsif v.wid = 4 then
					v.cline := ctrl_i.data4_o.rdata;
			elsif v.wid = 5 then
					v.cline := ctrl_i.data5_o.rdata;
			elsif v.wid = 6 then
					v.cline := ctrl_i.data6_o.rdata;
			elsif v.wid = 7 then
					v.cline := ctrl_i.data7_o.rdata;
			end if;
		end if;

		if v.lid = 0 then
			v.rdata := v.cline(63 downto 0);
		elsif v.lid = 1 then
			v.rdata := v.cline(127 downto 64);
		elsif v.lid = 2 then
			v.rdata := v.cline(191 downto 128);
		elsif v.lid = 3 then
			v.rdata := v.cline(255 downto 192);
		end if;

		if v.state = HIT then
			v.ready := v.en;
		elsif v.state = UPDATE then
			v.ready := '1';
		else
			v.ready := '0';
		end if;

		cache_o.mem_rdata <= v.rdata;
		cache_o.mem_ready <= v.ready;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then

				r <= init_ctrl_type;
				r_next <= init_data_type;

			else

				r <= rin;
				r_next <= rin_next;

			end if;

		end if;

	end process;

end architecture;
