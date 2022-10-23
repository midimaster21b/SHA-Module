// The base message transaction item

import uvm_pkg::*;
`include "uvm_macros.svh"

class msg_seq_item extends uvm_sequence_item;
   // Register the class with the UVM factory
   `uvm_object_utils(msg_seq_item)

   // Class properties
   bit [511:0] message = 512'h00000020_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_80000000_61626364;
   // rand bit [511:0] message;
   // rand bit [7:0] message;

   virtual function string convert2str();
      return $sformatf("%x", message);
   endfunction // toString

   function new(string name = "msg_seq_item");
      super.new(name);
   endfunction // new
endclass // msg_seq_item
