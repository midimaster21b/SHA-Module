#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define PADDED_BLOCK_SIZE 64

/* Note 1: All variables are 32 bit unsigned integers and addition is calculated modulo 232 */
/* Note 2: For each round, there is one round constant k[i] and one entry in the message schedule array w[i], 0 ≤ i ≤ 63 */
/* Note 3: The compression function uses 8 working variables, a through h */
/* Note 4: Big-endian convention is used when expressing the constants in this pseudocode, */
/*     and when parsing message block data from bytes to words, for example, */
/*     the first word of the input message "abc" after padding is 0x61626380 */

// NOTE: Currently assumes byte aligned message supplied

/* Initialize hash values: */
/* (first 32 bits of the fractional parts of the square roots of the first 8 primes 2..19): */
const uint32_t initial_hash[] = {
  0x6a09e667,
  0xbb67ae85,
  0x3c6ef372,
  0xa54ff53a,
  0x510e527f,
  0x9b05688c,
  0x1f83d9ab,
  0x5be0cd19
};

/* Initialize array of round constants: */
/* (first 32 bits of the fractional parts of the cube roots of the first 64 primes 2..311): */
/* k[0..63] := */
const uint32_t sha_constants[] = {
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

uint32_t right_rotate(uint32_t value, int rotate);

int main(int argc, char *argv[]) {
  uint32_t message_length; // L: message length in bits..? (in bytes in this implementation)
  uint32_t message_bits;
  unsigned int padded_message_buffer_size = 0;
  unsigned int num_padded_blocks = 1;

  uint32_t *padded_message;
  uint32_t *padded_message_block;

  uint32_t hash[8]         = {0};
  uint32_t working_hash[8] = {0};

  if(argc != 2) {
    // Print an error usage message
    printf("Usage: ./sha_test <message>\n");

    // Error out
    return(1);
  }

  // Print out message supplied
  printf("Message: %s\n", argv[1]);

  /* Pre-processing (Padding): */
  /* begin with the original message of length L bits */
  message_length = strlen(argv[1]);
  printf("Message length in bits: %d\n", message_length*8);

  num_padded_blocks = (padded_message_buffer_size/64) + 1;
  printf("Number of 512 bit blocks in padded message: %d\n", num_padded_blocks);

  // Allocate space for padded message (64 bytes per 512 bit chunk)
  padded_message = calloc(num_padded_blocks, 64*sizeof(char));

  if(padded_message == NULL) {
    printf("ERROR: unable to allocate space for the padded message.\n");
    return 1;
  }

  // Copy message into padded message
  memcpy(padded_message, argv[1], message_length * sizeof(char));

  // Append a single '1' bit
  // Append a variable number of '0' bits (out to a length of padded_message_length%512 == (512-64-1)
  int append_index = (message_length/4);
  /* printf("Appending 1 at %d shift %d: %08x\n", append_index, message_length%4, padded_message[append_index]); */
  padded_message[append_index] |= 0x80 << ((message_length%4) * 8);
  /* printf("Appending 1 at %d shift %d: %08x\n", append_index, message_length%4, padded_message[append_index]); */

  // Append initial message length(in bits) as a 64-bit big-endian integer
  /* *padded_message[(PADDED_BLOCK_SIZE * num_padded_blocks) - 4] = message_length; */
  message_bits = message_length*8;
  /* printf("Message length: %d\n", message_length*8); */
  /* memcpy(padded_message + ((num_padded_blocks) - 4), */

  /* int length_index = (((PADDED_BLOCK_SIZE * num_padded_blocks) / 8) - 4 - 1); */
  int length_index = sizeof(padded_message) - 1;
  printf("Index: %d\n", length_index);
  printf("Message length: %d\n", *(padded_message + length_index));
  /* memcpy(padded_message + ((PADDED_BLOCK_SIZE * num_padded_blocks) - 4), */
  memcpy(padded_message + length_index,
	 (char *)&message_bits,
	 sizeof(message_bits));
  /* printf("Message length: %d\n", *(padded_message + ((PADDED_BLOCK_SIZE * num_padded_blocks) - 4))); */
  printf("Message length: %d\n", *(padded_message + length_index));


  // Allocate space from temporary working block
  padded_message_block = calloc(num_padded_blocks, 1*sizeof(char));

  if(padded_message_block == NULL) {
    printf("ERROR: unable to allocate space for the padded message block.\n");
    return 1;
  }

  // Print padded message
  printf("Size of padded message: %ld\n", sizeof(padded_message));

  for(int y=0; y<sizeof(padded_message_block); y++) {
    printf("Message %d: %08x\n", y, padded_message[y]);
  }


  /* Process the message in successive 512-bit chunks: */
  /* for each chunk */
  for(int block_num=0; block_num < num_padded_blocks; block_num++) {
    printf("blox #%d\n", block_num);

    // break message into 512-bit chunks
    memcpy(padded_message_block, padded_message + (PADDED_BLOCK_SIZE * num_padded_blocks) - 4, PADDED_BLOCK_SIZE);

    /* create a 64-entry message schedule array w[0..63] of 32-bit words */
    uint32_t sched[64] = {0};

    /* (The initial values in w[0..63] don't matter, so many implementations zero them here) */
    /* copy chunk into first 16 words w[0..15] of the message schedule array */
    memcpy(sched, padded_message_block, PADDED_BLOCK_SIZE);

    /* Extend the first 16 words into the remaining 48 words w[16..63] of the message schedule array: */
    /* for i from 16 to 63 */
    for(int filler_num=16; filler_num < 64; filler_num++) {
      /* s0 := (w[i-15] rightrotate  7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift  3) */
      uint32_t temp_one_a = right_rotate(sched[filler_num-15], 7);
      uint32_t temp_one_b = right_rotate(sched[filler_num-15], 18);
      uint32_t temp_one_c = sched[filler_num-15] >> 3;

      uint32_t temp_one   = temp_one_a ^ temp_one_b ^ temp_one_c;

      /* s1 := (w[i- 2] rightrotate 17) xor (w[i- 2] rightrotate 19) xor (w[i- 2] rightshift 10) */
      uint32_t temp_two_a = right_rotate(sched[filler_num-2], 17);
      uint32_t temp_two_b = right_rotate(sched[filler_num-2], 19);
      uint32_t temp_two_c = sched[filler_num-2] >> 10;

      uint32_t temp_two   = temp_two_a ^ temp_two_b ^ temp_two_c;

      /* w[i] := w[i-16] + s0 + w[i-7] + s1 */
      sched[filler_num] = sched[filler_num-16] + temp_one + sched[filler_num-7] + temp_two;
    }

    /* Initialize working variables to current hash value: */
    memcpy(hash,         initial_hash, sizeof(hash));
    memcpy(working_hash, initial_hash, sizeof(working_hash));

    /* Compression function main loop: */
    /* for i from 0 to 63 */
    for(int compression_iter=0; compression_iter<64; compression_iter++) {
      /* S1 := (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25) */
      uint32_t temp_s1_a = right_rotate(working_hash[4], 6);
      uint32_t temp_s1_b = right_rotate(working_hash[4], 11);
      uint32_t temp_s1_c = right_rotate(working_hash[4], 25);

      uint32_t temp_s1   = temp_s1_a ^ temp_s1_b ^ temp_s1_c;

      /* ch := (e and f) xor ((not e) and g) */
      uint32_t temp_ch   = (working_hash[4] & working_hash[5]) ^ ((!working_hash[4]) & working_hash[6]);

      /* temp1 := h + S1 + ch + k[i] + w[i] */
      uint32_t temp_one  = working_hash[7] + temp_s1 + temp_ch + sha_constants[compression_iter] + sched[compression_iter];

      /* S0 := (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22) */
      uint32_t temp_s0_a = right_rotate(working_hash[0], 2);
      uint32_t temp_s0_b = right_rotate(working_hash[0], 13);
      uint32_t temp_s0_c = right_rotate(working_hash[0], 22);

      uint32_t temp_s0   = temp_s0_a ^ temp_s0_b ^ temp_s0_c;

      /* maj := (a and b) xor (a and c) xor (b and c) */
      uint32_t temp_maj  = (working_hash[0] & working_hash[1]) ^ (working_hash[0] & working_hash[2]) ^ (working_hash[1] & working_hash[2]);

      /* temp2 := S0 + maj */
      uint32_t temp_two  = temp_s0 + temp_maj;

      // Rotate and modify working words
      working_hash[7] = working_hash[6];     // h = g
      working_hash[6] = working_hash[5];     // g = f
      working_hash[5] = working_hash[4];     // f = e
      working_hash[4] = working_hash[3] + temp_one; // e = d + temp1
      working_hash[3] = working_hash[2];     // d = c
      working_hash[2] = working_hash[1];     // c = b
      working_hash[1] = working_hash[0];     // b = a
      working_hash[0] = temp_one + temp_two; // a = temp_one + temp_two
    }

    /* Add the compressed chunk to the current hash value: */
    /* h0 := h0 + a */
    /* h1 := h1 + b */
    /* h2 := h2 + c */
    /* h3 := h3 + d */
    /* h4 := h4 + e */
    /* h5 := h5 + f */
    /* h6 := h6 + g */
    /* h7 := h7 + h */
    hash[0] = hash[0] + working_hash[0];
    hash[1] = hash[1] + working_hash[1];
    hash[2] = hash[2] + working_hash[2];
    hash[3] = hash[3] + working_hash[3];
    hash[4] = hash[4] + working_hash[4];
    hash[5] = hash[5] + working_hash[5];
    hash[6] = hash[6] + working_hash[6];
    hash[7] = hash[7] + working_hash[7];
  }

  /* Produce the final hash value (big-endian): */
  /* digest := hash := h0 append h1 append h2 append h3 append h4 append h5 append h6 append h7 */
  printf("Hash: 0x");
  for(int y=0; y<8; y++) {
    printf("%08x", hash[y]);
  }

  printf("\n");

  return 0;
}


uint32_t right_rotate(uint32_t value, int rotate) {

  const int MAX_ROTATIONS = 32;
  uint32_t rot_values = 0;

  int actual_rotation = rotate % MAX_ROTATIONS;
  uint32_t rot_mask   = 0;

  uint32_t rot_value_mask = 0;

  // Create rotation mask
  for(int i=0; i<actual_rotation; i++) {
    rot_mask = (rot_mask << 1) + 1;
  }

  // Apply rotation mask
  rot_values = rot_mask & value;

  // Move to appropriate
  rot_value_mask = rot_values << (MAX_ROTATIONS - actual_rotation);

  // Rotate values
  value = (value >> actual_rotation) | rot_value_mask;

  return value;
}
