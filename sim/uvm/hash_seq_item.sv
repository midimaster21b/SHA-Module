// The base hash transaction item

import uvm_pkg::*;
`include "uvm_macros.svh"

class HashSeqItem extends uvm_sequence_item;
   // Register the class with the UVM factory
   `uvm_object_utils(HashSeqItem)

   // Class properties
   rand bit [255:0] hash;

   function new(string name = "HashSeqItem");
      super.new(name);
   endfunction // new
endclass // HashSeqItem
