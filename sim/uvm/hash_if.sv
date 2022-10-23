// Verification interface for the hash output interface

interface hash_if (input bit clk);

   logic [255:0] hash_data;
   logic 	 hash_rdy;
   logic 	 hash_valid;

   clocking cb @(posedge clk);
      // Sample input 1 step before rising edge
      // Write output 1 step after rising edge
      default input #1step output #1step;
      input 	 hash_data;
      output 	 hash_rdy;
      input 	 hash_valid;
   endclocking // cb
endinterface // hash_if
