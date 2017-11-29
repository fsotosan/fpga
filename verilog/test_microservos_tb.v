module test_microservos_tb;

   reg clk;
   reg [7:0] duty;
   wire out;

   test_microservos TM0(out,clk);
   defparam TM0.CLK_FREQ_HZ = 100000;    // 0.01MHz (clk period = 10us)
   defparam TM0.P0.PWM_PERIOD_US = 100;     // 100us (pwm period = 100us)

   initial begin
      clk = 0;
   end

   // clk period 10 time units
   always
      #5  clk = !clk;

   initial begin
      $dumpfile("test_microservos_tb.vcd");
      $dumpvars;
   end

   initial begin
      $display("\t\ttime,\tclk,\tout");
      $monitor("%d,\t%b,\t%b",$time,clk,out);
   end 

   initial begin 
      #50000 $finish;
   end

endmodule
