module test_microservos(out,clk);

   parameter CLK_FREQ_HZ = 12000000;    // iCEZUM clk is 12MHz

   output out;
   input clk;

   reg [7:0] duty;
   integer ticks;

   pwm P0(out,clk,duty,1'b1);
   defparam P0.CLK_FREQ_HZ = CLK_FREQ_HZ;

   initial begin
      ticks = 0;
      duty = 32;
   end

   always @(posedge clk) begin
      ticks = ticks + 1;
      if (ticks >= 10*P0.PWM_PERIOD_US*CLK_FREQ_HZ/1000000) begin
         ticks = 0;
         duty = duty + 1;
         if (duty >= 64) begin
            duty = 32;
         end 
      end
   end

   initial begin
      $display("\t\ttime,\tsec,\tduty");
      $monitor("%d,\t%d",$time,duty);
   end


endmodule
