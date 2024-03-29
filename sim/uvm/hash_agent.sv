// Container for the driver, monitor, and sequencer

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::hash_seq_item;
import test_pkg::hash_driver;
import test_pkg::hash_monitor;

class hash_agent extends uvm_agent;
   // Registers the hash_agent class with the UVM factory
   `uvm_component_utils(hash_agent)

   function new(string name="agent", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new

   hash_driver                    d1;
   hash_monitor                   m1;
   uvm_sequencer #(hash_seq_item) s1;
   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      s1 = uvm_sequencer#(hash_seq_item)::type_id::create("s1", this);
      d1 = hash_driver::type_id::create("d1", this);
      m1 = hash_monitor::type_id::create("m1", this);
   endfunction // build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // Connect the sequencer export port to the driver sequence port
      d1.seq_item_port.connect(s1.seq_item_export);
   endfunction // connect_phase
endclass // hash_agent
