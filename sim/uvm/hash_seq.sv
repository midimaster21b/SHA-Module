import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::hash_seq_item;

class hash_seq extends uvm_sequence;
   // Register the hash sequence with the uvm factory
   `uvm_object_utils(hash_seq)

   function new(string name="hash_seq");
      super.new(name);
   endfunction // new

   int num = 1;

   // The function called by the sequencer to get the next sequence item
   virtual task body();
      hash_seq_item hash = hash_seq_item::type_id::create("hash");
      start_item(hash);
      // TODO: randomize the hash once random constraints have been placed on hash_seq_item
      // hash.randomize();
      // Notify testbench of the newly created hash item
      `uvm_info("HASH_SEQ", $sformatf("Generated hash item: %s", hash.convert2str()), UVM_HIGH)

      finish_item(hash);
   endtask // body
endclass // hash_seq
