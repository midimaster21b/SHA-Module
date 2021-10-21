----------------------------------------------------------------------------------
-- Company:
-- Engineer: Joshua Edgcombe
--
-- Create Date: 10/21/2021 05:22:05 PM
-- Design Name:
-- Module Name: sha256_tb - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity sha256_tb is
end sha256_tb;

architecture Behavioral of sha256_tb is

  -----------------------
  -- Signals
  -----------------------
  signal clk_s        : std_logic := '0';
  signal rst_s        : std_logic := '1';

  signal msg_s        : std_logic_vector(511 downto 0) := x"00000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000061626364";
  signal msg_valid_s  : std_logic := '0';
  signal msg_ready_s  : std_logic;

  signal hash_s       : std_logic_vector(255 downto 0);
  signal hash_valid_s : std_logic;
  signal hash_ready_s : std_logic := '1';


  -----------------------
  -- Components
  -----------------------
  component SHA256 is
    generic (
      NUM_ITERATIONS_G : integer := 64
      );
    port(
      -- System Interface
      clk_in : in  std_logic;
      rst_in : in  std_logic;

      -- Message interface
      msg_in        : in  std_logic_vector(511 downto 0);
      msg_valid_in  : in  std_logic;
      msg_ready_out : out std_logic;

      -- Hash outputs
      hash_out       : out std_logic_vector(255 downto 0);
      hash_valid_out : out std_logic;
      hash_ready_in  : in  std_logic

      );
  end component;

begin

  clk_s <= not clk_s after 5 ns;
  rst_s <= '1' after 100 ns;

  stim_proc: process
  begin

    wait for 1000 ns;
    msg_valid_s <= '1';
    wait for 10 ns;
    msg_valid_s <= '0';
    wait;

  end process;


  u_dut: SHA256
    generic map (
      NUM_ITERATIONS_G => 64
      )
    port map (
      -- System Interface
      clk_in => clk_s,
      rst_in => rst_s,

      -- Message interface
      msg_in         => msg_s,
      msg_valid_in   => msg_valid_s,
      msg_ready_out  => msg_ready_s,

      -- Hash outputs
      hash_out       => hash_s,
      hash_valid_out => hash_valid_s,
      hash_ready_in  => hash_ready_s
      );


end Behavioral;
