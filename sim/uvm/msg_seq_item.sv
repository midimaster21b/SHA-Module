// The base message transaction item

import uvm_pkg::*;
`include "uvm_macros.svh"

class msg_seq_item extends uvm_sequence_item;
   // Register the class with the UVM factory
   `uvm_object_utils(msg_seq_item)

   // Class properties
   rand bit [511:0] message;

   virtual function string convert2str();
      return $sformatf("%x", message);
   endfunction // toString

   function new(string name = "msg_seq_item");
      super.new(name);
   endfunction // new
endclass // msg_seq_item
