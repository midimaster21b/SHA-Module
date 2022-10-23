// The base hash transaction item

import uvm_pkg::*;
`include "uvm_macros.svh"

class hash_seq_item extends uvm_sequence_item;
   // Register the class with the UVM factory
   `uvm_object_utils(hash_seq_item)

   // Class properties
   rand bit [255:0] hash;
   // rand bit [7:0] hash;

   virtual function string convert2str();
      return $sformatf("%x", hash);
   endfunction // toString

   function new(string name = "hash_seq_item");
      super.new(name);
   endfunction // new
endclass // hash_seq_item
