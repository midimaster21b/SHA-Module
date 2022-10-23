import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::msg_seq_item;

class msg_monitor extends uvm_monitor;
   // Register the msg_monitor with the UVM factory
   `uvm_component_utils(msg_monitor)

   // Get a handle to the UVM Analysis Port
   uvm_analysis_port #(msg_seq_item) mon_analysis_port;
   // Get a handle to the message interface
   virtual msg_if vif;

   function new(string name="msg_monitor", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual msg_if)::get(this, "", "msg_if", vif))
	`uvm_fatal("MSG_MON", "Could not get message interface")
      mon_analysis_port = new("mon_analysis_port", this);
   endfunction // build_phase

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);

      // This task monitors the message interface for any valid messages being
      // supplied to the DUT. If a valid message is found, a new message
      // transaction is written to the uvm_analysis_port for the scoreboard to
      // use.
      forever begin
	 @(vif.cb);
	 if(vif.msg_valid) begin
	    msg_seq_item msg = msg_seq_item::type_id::create("msg_seq_item");
	    // msg.message = vif.cb.msg_data;
	    msg.message = vif.msg_data;
	    // mon_analysis_port.write(msg_seq_item);
	    mon_analysis_port.write(msg);
	    `uvm_info("MSG_MON", $sformatf("Supplied message '%s'", msg.convert2str()), UVM_HIGH)
	 end
      end
   endtask // run_phase
endclass // msg_monitor

