// Drives DUT interface for message side of SHA-256 module
// Uses transactions from mailbox when they're available

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::msg_seq_item;

class msg_driver extends uvm_driver #(msg_seq_item);
   // Register the message driver with the UVM factory
   `uvm_component_utils(msg_driver)

   // Create virtual handle to msg interface
   virtual msg_if vif;

   function new(string name = "driver", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   

   /*
    * Function overriding the build phase of UVM
    */
   virtual function void build_phase(uvm_phase phase);
      // Call parents build phase before running this build phase
      super.build_phase(phase);

      // If the message interface is not in the config db, raise a fatal error and message
      if(!uvm_config_db#(virtual msg_if)::get(this, "", "msg_vif", vif))
	`uvm_fatal("MSG_DRV", "Could not get message interface")
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
	 // Create a handle for the message to be sent
	 msg_seq_item msg;

	 // Get the next message from the sequencer using the UVM TLM port
	 `uvm_info("MSG_DRV", $sformatf("Waiting for message from sequencer"), UVM_HIGH)
	 seq_item_port.get_next_item(msg);
	 
	 // Drive the interface
	 drive_item(msg);

	 // Signal that the transaction has been completed
	 seq_item_port.item_done();
      end // forever begin
   endtask // run_phase

   // TODO: This should handle backpressure (i.e. check the msg ready value 
   // prior to writing).
   virtual task drive_item(msg_seq_item msg);
      // Drive the message value and valid signal for one clock cycle
      @(vif.cb);
      vif.cb.msg_data  <= msg.message;
      vif.cb.msg_valid <= 1;
      
      // Clear the message value and valid signal after one clock cycle
      @(vif.cb);
      vif.cb.msg_data  <= 0;
      vif.cb.msg_valid <= 0;
   endtask // drive_item
endclass // msg_driver
