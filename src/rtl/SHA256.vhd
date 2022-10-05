----------------------------------------------------------------------------------
-- Company:
-- Engineer: Joshua Edgcombe
--
-- Create Date: 10/21/2021 03:33:52 PM
-- Design Name:
-- Module Name: SHA256 - Behavioral
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
-- 1. Assumes the supplied 512 bit block is properly formatted
-- 2. No back pressure is currently implemented
-- 3. Active low reset
--
-- States:
-- - Idle: Wait for message to be supplied
-- - Make_Weights: Produce message schedule array
-- - Compression: 64 iterations of the compression algorithm
-- - Hash_Finished: Output finished hash
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SHA256 is
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
end SHA256;


architecture Behavioral of SHA256 is

  ----------------------------
  -- State machine signals
  ----------------------------
  type sha256_state_t is (IDLE_STATE, MAKE_WEIGHTS_STATE, COMPRESSION_STATE, HASH_FINISHED_STATE);

  signal curr_state_r : sha256_state_t := IDLE_STATE;
  signal next_state_s : sha256_state_t := IDLE_STATE;


  signal compression_iter_r : unsigned(7 downto 0) := (others => '0');

  ----------------------------
  -- Calculation signals
  ----------------------------
  signal msg_r        : std_logic_vector(511 downto 0);
  signal hash_r       : unsigned(255 downto 0);
  signal hash_valid_r : std_logic;

  type compression_regs_t is array(7 downto 0) of unsigned(31 downto 0);
  signal compression_regs_r : compression_regs_t := (others => (others => '0'));


  -- type midstate_regs_t is array(63 downto 0) of std_logic_vector(31 downto 0);
  type midstate_regs_t is array(63 downto 0) of unsigned(31 downto 0);

  signal midstate_regs_r  : midstate_regs_t := (others => (others => '0'));
  signal calc_constants_r : midstate_regs_t := (
    0  => x"428a2f98",
    1  => x"71374491",
    2  => x"b5c0fbcf",
    3  => x"e9b5dba5",
    4  => x"3956c25b",
    5  => x"59f111f1",
    6  => x"923f82a4",
    7  => x"ab1c5ed5",
    8  => x"d807aa98",
    9  => x"12835b01",
    10 => x"243185be",
    11 => x"550c7dc3",
    12 => x"72be5d74",
    13 => x"80deb1fe",
    14 => x"9bdc06a7",
    15 => x"c19bf174",
    16 => x"e49b69c1",
    17 => x"efbe4786",
    18 => x"0fc19dc6",
    19 => x"240ca1cc",
    20 => x"2de92c6f",
    21 => x"4a7484aa",
    22 => x"5cb0a9dc",
    23 => x"76f988da",
    24 => x"983e5152",
    25 => x"a831c66d",
    26 => x"b00327c8",
    27 => x"bf597fc7",
    28 => x"c6e00bf3",
    29 => x"d5a79147",
    30 => x"06ca6351",
    31 => x"14292967",
    32 => x"27b70a85",
    33 => x"2e1b2138",
    34 => x"4d2c6dfc",
    35 => x"53380d13",
    36 => x"650a7354",
    37 => x"766a0abb",
    38 => x"81c2c92e",
    39 => x"92722c85",
    40 => x"a2bfe8a1",
    41 => x"a81a664b",
    42 => x"c24b8b70",
    43 => x"c76c51a3",
    44 => x"d192e819",
    45 => x"d6990624",
    46 => x"f40e3585",
    47 => x"106aa070",
    48 => x"19a4c116",
    49 => x"1e376c08",
    50 => x"2748774c",
    51 => x"34b0bcb5",
    52 => x"391c0cb3",
    53 => x"4ed8aa4a",
    54 => x"5b9cca4f",
    55 => x"682e6ff3",
    56 => x"748f82ee",
    57 => x"78a5636f",
    58 => x"84c87814",
    59 => x"8cc70208",
    60 => x"90befffa",
    61 => x"a4506ceb",
    62 => x"bef9a3f7",
    63 => x"c67178f2"
    );


begin


  msg_ready_out  <= '1'; -- TODO: Implement backpressure
  hash_out       <= std_logic_vector(hash_r);
  hash_valid_out <= hash_valid_r;




  -- Determine next state
  calc_state_proc: process(curr_state_r, msg_valid_in, compression_iter_r)
  begin
    case curr_state_r is
      when IDLE_STATE =>
        if(msg_valid_in = '1') then
          next_state_s <= MAKE_WEIGHTS_STATE;

        else
          next_state_s <= IDLE_STATE;

        end if;


      when MAKE_WEIGHTS_STATE =>
        next_state_s <= COMPRESSION_STATE;


      when COMPRESSION_STATE =>
        if(compression_iter_r >= to_unsigned(NUM_ITERATIONS_G-1, compression_iter_r'length)) then
          next_state_s <= HASH_FINISHED_STATE;

        else
          next_state_s <= COMPRESSION_STATE;

        end if;


      when HASH_FINISHED_STATE =>
        next_state_s <= IDLE_STATE;


      when others =>
        next_state_s <= IDLE_STATE;

    end case;
  end process;


  -- Advance state
  adv_state_proc: process(clk_in)
  begin
    if(rising_edge(clk_in)) then
      if(rst_in = '0') then
        curr_state_r <= IDLE_STATE;

      else
        curr_state_r <= next_state_s;

      end if;
    end if;
  end process;



  -- Capture input message
  msg_input_capture: process(clk_in)
  begin
    if(rising_edge(clk_in)) then
      if(rst_in = '0') then
        msg_r <= (others => '0');

      else
        msg_r <= msg_in;

      end if;
    end if;
  end process;


  -- Algorithm calculation
  -- weight_fill_proc: process(clk_in)
  weight_fill_proc: process(curr_state_r, midstate_regs_r)
  begin
    -- if rising_edge(clk_in) then
    if(curr_state_r = IDLE_STATE) then
      -- Copy 32 bit words into first 16 slots of the message schedule array
      for word_i in 0 to 15 loop
        midstate_regs_r(word_i) <= unsigned(msg_in(((word_i+1)*32)-1 downto word_i*32));
      end loop;


    elsif(curr_state_r = MAKE_WEIGHTS_STATE) then
      for word_i in 16 to 63 loop
        -- TODO: Double check this calculation
        midstate_regs_r(word_i) <= ((midstate_regs_r(word_i-15)(6 downto 0) & midstate_regs_r(word_i-15)(31 downto 7)) xor
                                    (midstate_regs_r(word_i-15)(17 downto 0) & midstate_regs_r(word_i-15)(31 downto 18)) xor
                                    ("000" & midstate_regs_r(word_i-15)(31 downto 3))) +
                                   -- ((midstate_regs_r(word_i-2)(6 downto 0) & midstate_regs_r(word_i-2)(31 downto 7)) xor
                                   ((midstate_regs_r(word_i-2)(16 downto 0) & midstate_regs_r(word_i-2)(31 downto 17)) xor
                                    (midstate_regs_r(word_i-2)(18 downto 0) & midstate_regs_r(word_i-2)(31 downto 19)) xor
                                    ("0000000000" & midstate_regs_r(word_i-2)(31 downto 10))) +
                                   midstate_regs_r(word_i-16) + midstate_regs_r(word_i-7);

      end loop;
    end if;
    -- end if;
  end process;


  -- Assign hash value
  output_hash_proc: process(clk_in)
  begin
    if rising_edge(clk_in) then
      if(curr_state_r = HASH_FINISHED_STATE) then
        hash_r <= (x"6a09e667" + compression_regs_r(0)) &
                  (x"bb67ae85" + compression_regs_r(1)) &
                  (x"3c6ef372" + compression_regs_r(2)) &
                  (x"a54ff53a" + compression_regs_r(3)) &
                  (x"510e527f" + compression_regs_r(4)) &
                  (x"9b05688c" + compression_regs_r(5)) &
                  (x"1f83d9ab" + compression_regs_r(6)) &
                  (x"5be0cd19" + compression_regs_r(7));

        hash_valid_r <= '1';

      else
        hash_r <= (others => '0');
        hash_valid_r <= '0';

      end if;
    end if;
  end process;


  compression_proc: process(clk_in)
  begin
    -- Compression registers
    -- h0 := 0x6a09e667
    -- h1 := 0xbb67ae85
    -- h2 := 0x3c6ef372
    -- h3 := 0xa54ff53a
    -- h4 := 0x510e527f
    -- h5 := 0x9b05688c
    -- h6 := 0x1f83d9ab
    -- h7 := 0x5be0cd19

    if rising_edge(clk_in) then
      if(curr_state_r = COMPRESSION_STATE) then
        -- compression_regs_s[7] <= compression_regs_s[6];
        -- compression_regs_s[6] <= compression_regs_s[5];
        -- compression_regs_s[5] <= compression_regs_s[4];
        -- compression_regs_s[4] <= compression_regs_s[3] + temp1;
        -- compression_regs_s[3] <= compression_regs_s[2];
        -- compression_regs_s[2] <= compression_regs_s[1];
        -- compression_regs_s[1] <= compression_regs_s[0];
        -- compression_regs_s[0] <= temp1 + temp2;
        compression_regs_r(7) <= compression_regs_r(6);
        compression_regs_r(6) <= compression_regs_r(5);
        compression_regs_r(5) <= compression_regs_r(4);
        compression_regs_r(4) <= compression_regs_r(3) +
                                 (
                                   compression_regs_r(7)                                                             -- h
                                   + (
                                     (compression_regs_r(4)(5 downto 0) & compression_regs_r(4)(31 downto 6))        -- e rotate 6
                                     xor (compression_regs_r(4)(10 downto 0) & compression_regs_r(4)(31 downto 11))  -- e rotate 11
                                     xor (compression_regs_r(4)(24 downto 0) & compression_regs_r(4)(31 downto 25))) -- e rotate 25
                                   + (((compression_regs_r(4) and compression_regs_r(5))                             -- e and f
                                       xor ((not compression_regs_r(4)) and compression_regs_r(6))))                 -- (not e) & g
                                   + calc_constants_r(to_integer(compression_iter_r))                                -- k(i)
                                   + midstate_regs_r(to_integer(compression_iter_r))                                 -- w(i)
                                   );

        compression_regs_r(3) <= compression_regs_r(2);
        compression_regs_r(2) <= compression_regs_r(1);
        compression_regs_r(1) <= compression_regs_r(0);


         compression_regs_r(0) <= ( --temp1
                                   compression_regs_r(7)                                                              -- h
                                   + ((compression_regs_r(4)(5 downto 0) & compression_regs_r(4)(31 downto 6))        -- e rotate 6
                                      xor (compression_regs_r(4)(10 downto 0) & compression_regs_r(4)(31 downto 11))  -- e rotate 11
                                      xor (compression_regs_r(4)(24 downto 0) & compression_regs_r(4)(31 downto 25))) -- e rotate 25
                                   + (((compression_regs_r(4) and compression_regs_r(5))                              -- e and f
                                       xor ((not compression_regs_r(4)) and compression_regs_r(6))))                  -- (not e) and g
                                   + calc_constants_r(to_integer(compression_iter_r))                                 -- k(i)
                                   + midstate_regs_r(to_integer(compression_iter_r))                                  -- w(i)
                                   )
                                   + (-- temp2
                                     (-- S0
                                       (compression_regs_r(0)(1 downto 0) & compression_regs_r(0)(31 downto 2))       -- a rotate 2
                                       xor (compression_regs_r(0)(12 downto 0) & compression_regs_r(0)(31 downto 13)) -- a rotate 13
                                       xor (compression_regs_r(0)(21 downto 0) & compression_regs_r(0)(31 downto 22)) -- a rotate 22
                                       )
                                     + (-- Maj
                                       (compression_regs_r(0) and compression_regs_r(1))              -- a and b
                                       xor (compression_regs_r(0) and compression_regs_r(2))            -- a and c
                                       xor (compression_regs_r(1) and compression_regs_r(2))            -- b and c
                                       )
                                     );




      elsif(curr_state_r = HASH_FINISHED_STATE) then
         compression_regs_r(0) <= x"6a09e667" + compression_regs_r(0);
         compression_regs_r(1) <= x"bb67ae85" + compression_regs_r(1);
         compression_regs_r(2) <= x"3c6ef372" + compression_regs_r(2);
         compression_regs_r(3) <= x"a54ff53a" + compression_regs_r(3);
         compression_regs_r(4) <= x"510e527f" + compression_regs_r(4);
         compression_regs_r(5) <= x"9b05688c" + compression_regs_r(5);
         compression_regs_r(6) <= x"1f83d9ab" + compression_regs_r(6);
         compression_regs_r(7) <= x"5be0cd19" + compression_regs_r(7);

      else
         compression_regs_r(0) <= x"6a09e667";
         compression_regs_r(1) <= x"bb67ae85";
         compression_regs_r(2) <= x"3c6ef372";
         compression_regs_r(3) <= x"a54ff53a";
         compression_regs_r(4) <= x"510e527f";
         compression_regs_r(5) <= x"9b05688c";
         compression_regs_r(6) <= x"1f83d9ab";
         compression_regs_r(7) <= x"5be0cd19";

      end if;
    end if;
  end process;

  comp_count_proc: process(clk_in)
  begin
    if rising_edge(clk_in) then
      if rst_in = '0' then
        compression_iter_r <= (others => '0');

      else
        if(curr_state_r = COMPRESSION_STATE) then
          compression_iter_r <= compression_iter_r + 1;

        else
          compression_iter_r <= (others => '0');

        end if;
      end if;
    end if;
  end process;


end Behavioral;
