-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;

package constants is

	constant nop                        : std_logic_vector(31 downto 0) := x"00000013";

	constant u_mode                     : std_logic_vector(1 downto 0) := "00";
	constant m_mode                     : std_logic_vector(1 downto 0) := "11";

	constant overflow                   : std_logic_vector(63 downto 0) := x"FFFFFFFFFFFFFFFF";
	constant overflow_sign              : std_logic_vector(63 downto 0) := x"1000000000000000";
	constant zero                       : std_logic_vector(63 downto 0) := x"0000000000000000";
	constant one                        : std_logic_vector(63 downto 0) := x"0000000000000001";

	constant opcode_lui                 : std_logic_vector(6 downto 0) := "0110111";
	constant opcode_auipc               : std_logic_vector(6 downto 0) := "0010111";
	constant opcode_jal                 : std_logic_vector(6 downto 0) := "1101111";
	constant opcode_jalr                : std_logic_vector(6 downto 0) := "1100111";
	constant opcode_branch              : std_logic_vector(6 downto 0) := "1100011";
	constant opcode_load                : std_logic_vector(6 downto 0) := "0000011";
	constant opcode_store               : std_logic_vector(6 downto 0) := "0100011";
	constant opcode_immediate           : std_logic_vector(6 downto 0) := "0010011";
	constant opcode_register            : std_logic_vector(6 downto 0) := "0110011";
	constant opcode_immediate_32        : std_logic_vector(6 downto 0) := "0011011";
	constant opcode_register_32         : std_logic_vector(6 downto 0) := "0111011";
	constant opcode_fence               : std_logic_vector(6 downto 0) := "0001111";
	constant opcode_system              : std_logic_vector(6 downto 0) := "1110011";
	constant opcode_fp                  : std_logic_vector(6 downto 0) := "1010011";
	constant opcode_fload               : std_logic_vector(6 downto 0) := "0000111";
	constant opcode_fstore              : std_logic_vector(6 downto 0) := "0100111";
	constant opcode_fmadd               : std_logic_vector(6 downto 0) := "1000011";
	constant opcode_fmsub               : std_logic_vector(6 downto 0) := "1000111";
	constant opcode_fnmsub              : std_logic_vector(6 downto 0) := "1001011";
	constant opcode_fnmadd              : std_logic_vector(6 downto 0) := "1001111";

	constant funct_add                  : std_logic_vector(2 downto 0) := "000";
	constant funct_sll                  : std_logic_vector(2 downto 0) := "001";
	constant funct_slt                  : std_logic_vector(2 downto 0) := "010";
	constant funct_sltu                 : std_logic_vector(2 downto 0) := "011";
	constant funct_xor                  : std_logic_vector(2 downto 0) := "100";
	constant funct_srl                  : std_logic_vector(2 downto 0) := "101";
	constant funct_or                   : std_logic_vector(2 downto 0) := "110";
	constant funct_and                  : std_logic_vector(2 downto 0) := "111";

	constant funct_beq                  : std_logic_vector(2 downto 0) := "000";
	constant funct_bne                  : std_logic_vector(2 downto 0) := "001";
	constant funct_blt                  : std_logic_vector(2 downto 0) := "100";
	constant funct_bge                  : std_logic_vector(2 downto 0) := "101";
	constant funct_bltu                 : std_logic_vector(2 downto 0) := "110";
	constant funct_bgeu                 : std_logic_vector(2 downto 0) := "111";

	constant funct_lb                   : std_logic_vector(2 downto 0) := "000";
	constant funct_lh                   : std_logic_vector(2 downto 0) := "001";
	constant funct_lw                   : std_logic_vector(2 downto 0) := "010";
	constant funct_ld                   : std_logic_vector(2 downto 0) := "011";
	constant funct_lbu                  : std_logic_vector(2 downto 0) := "100";
	constant funct_lhu                  : std_logic_vector(2 downto 0) := "101";
	constant funct_lwu                  : std_logic_vector(2 downto 0) := "110";

	constant funct_sb                   : std_logic_vector(2 downto 0) := "000";
	constant funct_sh                   : std_logic_vector(2 downto 0) := "001";
	constant funct_sw                   : std_logic_vector(2 downto 0) := "010";
	constant funct_sd                   : std_logic_vector(2 downto 0) := "011";

	constant funct_csrrw                : std_logic_vector(2 downto 0) := "001";
	constant funct_csrrs                : std_logic_vector(2 downto 0) := "010";
	constant funct_csrrc                : std_logic_vector(2 downto 0) := "011";
	constant funct_csrrwi               : std_logic_vector(2 downto 0) := "101";
	constant funct_csrrsi               : std_logic_vector(2 downto 0) := "110";
	constant funct_csrrci               : std_logic_vector(2 downto 0) := "111";

	constant funct_fadd                 : std_logic_vector(4 downto 0) := "00000";
	constant funct_fsub                 : std_logic_vector(4 downto 0) := "00001";
	constant funct_fmul                 : std_logic_vector(4 downto 0) := "00010";
	constant funct_fdiv                 : std_logic_vector(4 downto 0) := "00011";
	constant funct_fsqrt                : std_logic_vector(4 downto 0) := "01011";
	constant funct_fsgnj                : std_logic_vector(4 downto 0) := "00100";
	constant funct_fminmax              : std_logic_vector(4 downto 0) := "00101";
	constant funct_fcomp                : std_logic_vector(4 downto 0) := "10100";
	constant funct_fclass               : std_logic_vector(4 downto 0) := "11100";
	constant funct_fmv_f2i              : std_logic_vector(4 downto 0) := "11100";
	constant funct_fmv_i2f              : std_logic_vector(4 downto 0) := "11110";
	constant funct_fconv                : std_logic_vector(4 downto 0) := "01000";
	constant funct_fconv_f2i            : std_logic_vector(4 downto 0) := "11000";
	constant funct_fconv_i2f            : std_logic_vector(4 downto 0) := "11010";
	constant funct_fconv_f2f            : std_logic_vector(4 downto 0) := "01000";

	constant csr_ecall                  : std_logic_vector(11 downto 0) := x"000";
	constant csr_ebreak                 : std_logic_vector(11 downto 0) := x"001";

	constant csr_uret                   : std_logic_vector(11 downto 0) := x"002";
	constant csr_sret                   : std_logic_vector(11 downto 0) := x"102";
	constant csr_mret                   : std_logic_vector(11 downto 0) := x"302";

	constant csr_wfi                    : std_logic_vector(11 downto 0) := x"105";

	constant csr_ustatus                : std_logic_vector(11 downto 0) := x"000";
	constant csr_uie                    : std_logic_vector(11 downto 0) := x"004";
	constant csr_utvec                  : std_logic_vector(11 downto 0) := x"005";

	constant csr_uscratch               : std_logic_vector(11 downto 0) := x"040";
	constant csr_uepc                   : std_logic_vector(11 downto 0) := x"041";
	constant csr_ucause                 : std_logic_vector(11 downto 0) := x"042";
	constant csr_utval                  : std_logic_vector(11 downto 0) := x"043";
	constant csr_uip                    : std_logic_vector(11 downto 0) := x"044";

	constant csr_fflags                 : std_logic_vector(11 downto 0) := x"001";
	constant csr_frm                    : std_logic_vector(11 downto 0) := x"002";
	constant csr_fcsr                   : std_logic_vector(11 downto 0) := x"003";

	constant csr_ucycle                 : std_logic_vector(11 downto 0) := x"C00";
	constant csr_utime                  : std_logic_vector(11 downto 0) := x"C01";
	constant csr_uinstret               : std_logic_vector(11 downto 0) := x"C02";
	constant csr_ucycleh                : std_logic_vector(11 downto 0) := x"C80";
	constant csr_utimeh                 : std_logic_vector(11 downto 0) := x"C81";
	constant csr_uinstreth              : std_logic_vector(11 downto 0) := x"C82";

	constant csr_sstatus                : std_logic_vector(11 downto 0) := x"100";
	constant csr_sisa                   : std_logic_vector(11 downto 0) := x"101";
	constant csr_sedeleg                : std_logic_vector(11 downto 0) := x"102";
	constant csr_sideleg                : std_logic_vector(11 downto 0) := x"103";
	constant csr_sie                    : std_logic_vector(11 downto 0) := x"104";
	constant csr_stvec                  : std_logic_vector(11 downto 0) := x"105";
	constant csr_scounteren             : std_logic_vector(11 downto 0) := x"106";

	constant csr_sscratch               : std_logic_vector(11 downto 0) := x"140";
	constant csr_sepc                   : std_logic_vector(11 downto 0) := x"141";
	constant csr_scause                 : std_logic_vector(11 downto 0) := x"142";
	constant csr_stval                  : std_logic_vector(11 downto 0) := x"143";
	constant csr_sip                    : std_logic_vector(11 downto 0) := x"144";

	constant csr_satp                   : std_logic_vector(11 downto 0) := x"180";

	constant csr_mvendorid              : std_logic_vector(11 downto 0) := x"F11";
	constant csr_marchid                : std_logic_vector(11 downto 0) := x"F12";
	constant csr_mimpid                 : std_logic_vector(11 downto 0) := x"F13";
	constant csr_mhartid                : std_logic_vector(11 downto 0) := x"F14";

	constant csr_mstatus                : std_logic_vector(11 downto 0) := x"300";
	constant csr_misa                   : std_logic_vector(11 downto 0) := x"301";
	constant csr_medeleg                : std_logic_vector(11 downto 0) := x"302";
	constant csr_mideleg                : std_logic_vector(11 downto 0) := x"303";
	constant csr_mie                    : std_logic_vector(11 downto 0) := x"304";
	constant csr_mtvec                  : std_logic_vector(11 downto 0) := x"305";
	constant csr_mcounteren             : std_logic_vector(11 downto 0) := x"306";

	constant csr_mscratch               : std_logic_vector(11 downto 0) := x"340";
	constant csr_mepc                   : std_logic_vector(11 downto 0) := x"341";
	constant csr_mcause                 : std_logic_vector(11 downto 0) := x"342";
	constant csr_mtval                  : std_logic_vector(11 downto 0) := x"343";
	constant csr_mip                    : std_logic_vector(11 downto 0) := x"344";

	constant csr_pmpcfg0                : std_logic_vector(11 downto 0) := x"3A0";
	constant csr_pmpcfg1                : std_logic_vector(11 downto 0) := x"3A1";
	constant csr_pmpcfg2                : std_logic_vector(11 downto 0) := x"3A2";
	constant csr_pmpcfg3                : std_logic_vector(11 downto 0) := x"3A3";
	constant csr_pmpaddr0               : std_logic_vector(11 downto 0) := x"3B0";
	constant csr_pmpaddr1               : std_logic_vector(11 downto 0) := x"3B1";
	constant csr_pmpaddr2               : std_logic_vector(11 downto 0) := x"3B2";
	constant csr_pmpaddr3               : std_logic_vector(11 downto 0) := x"3B3";
	constant csr_pmpaddr4               : std_logic_vector(11 downto 0) := x"3B4";
	constant csr_pmpaddr5               : std_logic_vector(11 downto 0) := x"3B5";
	constant csr_pmpaddr6               : std_logic_vector(11 downto 0) := x"3B6";
	constant csr_pmpaddr7               : std_logic_vector(11 downto 0) := x"3B7";
	constant csr_pmpaddr8               : std_logic_vector(11 downto 0) := x"3B8";
	constant csr_pmpaddr9               : std_logic_vector(11 downto 0) := x"3B9";
	constant csr_pmpaddr10              : std_logic_vector(11 downto 0) := x"3BA";
	constant csr_pmpaddr11              : std_logic_vector(11 downto 0) := x"3BB";
	constant csr_pmpaddr12              : std_logic_vector(11 downto 0) := x"3BC";
	constant csr_pmpaddr13              : std_logic_vector(11 downto 0) := x"3BD";
	constant csr_pmpaddr14              : std_logic_vector(11 downto 0) := x"3BE";
	constant csr_pmpaddr15              : std_logic_vector(11 downto 0) := x"3BF";

	constant csr_mcycle                 : std_logic_vector(11 downto 0) := x"B00";
	constant csr_minstret               : std_logic_vector(11 downto 0) := x"B02";
	constant csr_mcycleh                : std_logic_vector(11 downto 0) := x"B80";
	constant csr_minstreth              : std_logic_vector(11 downto 0) := x"B82";

	constant csr_tselect                : std_logic_vector(11 downto 0) := x"7A0";
	constant csr_tdata1                 : std_logic_vector(11 downto 0) := x"7A1";
	constant csr_tdata2                 : std_logic_vector(11 downto 0) := x"7A2";
	constant csr_tdata3                 : std_logic_vector(11 downto 0) := x"7A3";

	constant csr_dcsr                   : std_logic_vector(11 downto 0) := x"7B0";
	constant csr_dpc                    : std_logic_vector(11 downto 0) := x"7B1";
	constant csr_dscratch               : std_logic_vector(11 downto 0) := x"7B2";

	constant csr_display                : std_logic_vector(11 downto 0) := x"788";

	constant interrupt                  : std_logic := '1';
	constant exception                  : std_logic := '0';

	constant interrupt_user_soft        : std_logic_vector(3 downto 0) := x"0";
	constant interrupt_super_soft       : std_logic_vector(3 downto 0) := x"1";
	constant interrupt_mach_soft        : std_logic_vector(3 downto 0) := x"3";
	constant interrupt_user_timer       : std_logic_vector(3 downto 0) := x"4";
	constant interrupt_super_timer      : std_logic_vector(3 downto 0) := x"5";
	constant interrupt_mach_timer       : std_logic_vector(3 downto 0) := x"7";
	constant interrupt_user_extern      : std_logic_vector(3 downto 0) := x"8";
	constant interrupt_super_extern     : std_logic_vector(3 downto 0) := x"9";
	constant interrupt_mach_extern      : std_logic_vector(3 downto 0) := x"B";

	constant except_instr_addr_misalign : std_logic_vector(3 downto 0) := x"0";
	constant except_instr_access_fault  : std_logic_vector(3 downto 0) := x"1";
	constant except_illegal_instruction : std_logic_vector(3 downto 0) := x"2";
	constant except_breakpoint          : std_logic_vector(3 downto 0) := x"3";
	constant except_load_addr_misalign  : std_logic_vector(3 downto 0) := x"4";
	constant except_load_access_fault   : std_logic_vector(3 downto 0) := x"5";
	constant except_store_addr_misalign : std_logic_vector(3 downto 0) := x"6";
	constant except_store_access_fault  : std_logic_vector(3 downto 0) := x"7";
	constant except_env_call_user       : std_logic_vector(3 downto 0) := x"8";
	constant except_env_call_super      : std_logic_vector(3 downto 0) := x"9";
	constant except_env_call_mach       : std_logic_vector(3 downto 0) := x"B";
	constant except_instr_page_fault    : std_logic_vector(3 downto 0) := x"C";
	constant except_load_page_fault     : std_logic_vector(3 downto 0) := x"D";
	constant except_store_page_fault    : std_logic_vector(3 downto 0) := x"F";

end constants;
