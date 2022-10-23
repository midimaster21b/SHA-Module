// Drives DUT interface for hash side of SHA-256 module
// Uses transactions from mailbox when they're available

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::hash_seq_item;

class hash_driver extends uvm_driver #(hash_seq_item);
   // Register the hash driver with the UVM factory
   `uvm_component_utils(hash_driver)

   // Create virtual handle to hash interface
   virtual hash_if vif;

   function new(string name = "driver", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   

   /*
    * Function overriding the build phase of UVM
    */
   virtual function void build_phase(uvm_phase phase);
      // Call parents build phase before running this build phase
      super.build_phase(phase);

      // If the hash interface is not in the config db, raise a fatal error and hash
      if(!uvm_config_db#(virtual hash_if)::get(this, "", "hash_vif", vif))
	`uvm_fatal("HASH_DRV", "Could not get hash interface")
   endfunction // build_phase


   /*
    * Task overriding the run phase of UVM.
    * The run_phase is the only phase that is a task because it is the only 
    * phase which consumes time. The other phases are all functions because they
    * do not consume time.
    */
   virtual task run_phase(uvm_phase phase);
      // Run the parent's UVM run_phase function before executing this class's functionality
      super.run_phase(phase);

      // Always loop during the run phase
      // This is okay because this is not the component that is responsible for
      // asserting the run phase objection. Since it's not responsible handling
      // the run phase objection, it can be allowed to loop indefinitely and the
      // function will exit when the objection is dropped.
      forever begin
	 // The driver should always be ready for now
	 vif.hash_rdy <= 1;

	 // // Create a handle for the hash to be sent
	 // hash_seq_item hash;

	 // // Get the next hash from the sequencer using the UVM TLM port
	 // `uvm_info("HASH_DRV", $sformatf("Waiting for hash from sequencer"), UVM_HIGH)
	 // seq_item_port.get_next_item(hash);
	 
	 // // Drive the interface
	 // drive_item(hash);

	 // // Signal that the transaction has been completed
	 // seq_item_port.item_done();
      end // forever begin
   endtask // run_phase

   // TODO: This should handle backpressure (i.e. check the hash ready value 
   // prior to writing).
   virtual task drive_item(hash_seq_item hash);
      // // Drive the hash value and valid signal for one clock cycle
      // @(vif.cb);
      // vif.cb.hash_data  <= hash.message;
      // vif.cb.hash_valid <= 1;
      
      // // Clear the hash value and valid signal after one clock cycle
      // @(vif.cb);
      // vif.cb.hash_data  <= 0;
      // vif.cb.hash_valid <= 0;
      // vif.hash_ready <= 0;
   endtask // drive_item
endclass // hash_driver
