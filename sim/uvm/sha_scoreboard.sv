// The scoreboard is responsible for verifying the DUT's functionality. This
// includes tracking transactions and even internal signals to verify the DUT is
// functioning as expected.
// Useful forum: https://verificationacademy.com/forums/uvm/how-connect-scoreboard-more-one-monitor

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::msg_seq_item;
import test_pkg::hash_seq_item;

class sha_scoreboard extends uvm_scoreboard;
   // Register the sha_scorecard with the UVM factory
   `uvm_component_utils(sha_scoreboard)

   // Declare multiple uvm_analysis_imp ports coming into scoreboard
   // This is required and these behave as suffixes for each of the write()
   // functions declared below.
   `uvm_analysis_imp_decl(_msg_mon)
   `uvm_analysis_imp_decl(_hash_mon)

   // The suffixes are used here as well as the sequence item data type to
   // declare the handles.
   uvm_analysis_imp_msg_mon #(msg_seq_item, sha_scoreboard) msg_analysis_imp;
   uvm_analysis_imp_hash_mon #(hash_seq_item, sha_scoreboard) hash_analysis_imp;



   function new(string name="sha_scoreboard", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   
   /*
    * 
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      // Create the objects associated with the handles during the build phase
      msg_analysis_imp = new("msg_analysis_imp", this);
      hash_analysis_imp = new("hash_analysis_imp", this);

      // TODO: Generate or retrieve reference pattern from uvm_config_db
   endfunction // build_phase
   

   // This function is called every time a message transaction is seen
   virtual function write_msg_mon(msg_seq_item msg);
      `uvm_info("SCBD", $sformatf("Message found: %s", msg.convert2str()), UVM_LOW)
   endfunction // write

   // This function is called every time a hash transaction is seen
   virtual function write_hash_mon(hash_seq_item hash);
      `uvm_info("SCBD", $sformatf("Hash found: %s", hash.convert2str()), UVM_LOW)
   endfunction // write


endclass // sha_scoreboard
