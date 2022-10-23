interface msg_if (input bit clk);

   logic [511:0] msg_data;
   logic	 msg_rdy;
   logic	 msg_valid;

   clocking cb @(posedge clk);
      // Sample input 1 step before rising edge
      // Write output 1 step after rising edge
      default input #1step output #1step;
      output	 msg_data;
      input	 msg_rdy;
      output	 msg_valid;
   endclocking // cb
endinterface // msg_if
