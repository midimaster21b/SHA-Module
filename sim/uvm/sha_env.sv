// Container object to hold all the verification components together

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::msg_agent;
import test_pkg::hash_agent;
import test_pkg::sha_scoreboard;

class sha_env extends uvm_env;
   // Register the sha environment with the UVM factory
   `uvm_component_utils(sha_env)

   // Agents and scoreboard
   msg_agent      msg_a0;  // Message agent handle
   hash_agent     hash_a0; // Message agent handle
   sha_scoreboard sha_sb0; // SHA scoreboard

   function new(string name="sha_env", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      msg_a0  = msg_agent::type_id::create("msg_a0", this);
      hash_a0 = hash_agent::type_id::create("hash_a0", this);
      sha_sb0 = sha_scoreboard::type_id::create("sha_sb0", this);
   endfunction // build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // Connect the message monitor analysis port to the scoreboard analysis
      // implementation port
      msg_a0.m0.mon_analysis_port.connect(sha_sb0.msg_analysis_imp);

      // Connect the hash monitor analysis port to the scoreboard analysis
      // implementation port
      hash_a0.m0.mon_analysis_port.connect(sha_sb0.hash_analysis_imp);
   endfunction // connect_phase
endclass // sha_env
