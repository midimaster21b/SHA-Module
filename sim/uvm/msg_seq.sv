import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::msg_seq_item;

class msg_seq extends uvm_sequence;
   // Register the message sequence with the uvm factory
   `uvm_object_utils(msg_seq)

   function new(string name="msg_seq");
      super.new(name);
   endfunction // new

   int num = 1;

   // The function called by the sequencer to get the next sequence item
   virtual task body();
      msg_seq_item msg = msg_seq_item::type_id::create("msg");
      start_item(msg);
      // TODO: randomize the message once random constraints have been placed on msg_seq_item
      // msg.randomize();
      // Notify testbench of the newly created message item
      `uvm_info("MSG_SEQ", $sformatf("Generated message item: %s", msg.convert2str()), UVM_HIGH)

      finish_item(msg);
   endtask // body
endclass // msg_seq
