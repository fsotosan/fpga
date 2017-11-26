module pwm_tb;

   reg clk, enable;
   reg [7:0] duty;
   wire out;

   pwm P0(out,clk,duty,enable);
   defparam P0.CLK_FREQ_HZ = 100000; 	// 0.1MHz (clk period = 10us)
   defparam P0.PWM_PERIOD_US = 100;	// 100us (pwm period = 100us)

   initial begin
      clk = 0;
      duty = 128;
      enable = 1;
   end

   // clk period 10 time units
   always
      #5  clk = !clk;

   initial begin
      $dumpfile("pwm_tb.vcd");
      $dumpvars;
   end

   initial begin
      $display("\t\ttime,\tclk,\tenable,\tout");
      $monitor("%d,\t%b,\t%b,\t%b",$time,clk,enable,out);
   end 

   initial begin 
      #200 enable = 0; // disable component. output zero expected
      #200 enable = 1; // enable component. 50% duty expected
      #200 duty = 64;  // change of duty to 25% of the period
      #200 duty = 255;  // change of duty to 100% of the period
      #200 duty = 0;  // change of duty to 0% of the period
      #200 $finish;
   end

endmodule
