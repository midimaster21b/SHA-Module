// Container for the driver, monitor, and sequencer

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::msg_seq_item;
import test_pkg::msg_driver;
import test_pkg::msg_monitor;

class msg_agent extends uvm_agent;
   // Registers the msg_agent class with the UVM factory
   `uvm_component_utils(msg_agent)

   function new(string name="agent", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new

   msg_driver                    d0;
   msg_monitor                   m0;
   uvm_sequencer #(msg_seq_item) s0;
   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      s0 = uvm_sequencer#(msg_seq_item)::type_id::create("s0", this);
      d0 = msg_driver::type_id::create("d0", this);
      m0 = msg_monitor::type_id::create("m0", this);
   endfunction // build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // Connect the sequencer export port to the driver sequence port
      d0.seq_item_port.connect(s0.seq_item_export);
   endfunction // connect_phase
endclass // msg_agent
