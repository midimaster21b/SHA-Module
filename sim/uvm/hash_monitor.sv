import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::hash_seq_item;

class hash_monitor extends uvm_monitor;
   // Register the hash_monitor with the UVM factory
   `uvm_component_utils(hash_monitor)

   // Get a handle to the UVM Analysis Port
   uvm_analysis_port #(hash_seq_item) mon_analysis_port;
   // Get a handle to the hash interface
   virtual hash_if vif;

   function new(string name="hash_monitor", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual hash_if)::get(this, "", "hash_if", vif))
	`uvm_fatal("HASH_MON", "Could not get hash interface")
      mon_analysis_port = new("mon_analysis_port", this);
   endfunction // build_phase

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);

      // This task monitors the hash interface for any valid hashes being
      // supplied to the DUT. If a valid hash is found, a new hash
      // transaction is written to the uvm_analysis_port for the scoreboard to
      // use.
      forever begin
	 @(vif.cb);
	 if(vif.hash_valid) begin
	    hash_seq_item hash = hash_seq_item::type_id::create("hash_seq_item");
	    // hash.message = vif.cb.hash_data;
	    hash.hash = vif.hash_data;
	    // mon_analysis_port.write(hash_seq_item);
	    mon_analysis_port.write(hash);
	    `uvm_info("HASH_MON", $sformatf("Found hash '%s'", hash.convert2str()), UVM_LOW)
	 end
      end
   endtask // run_phase
endclass // hash_monitor

