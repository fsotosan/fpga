// PWM generator 

module pwm(out,clk,duty,enable);

   parameter CLK_FREQ_HZ = 12000000;	// iCEZUM clk is 12MHz
   parameter PWM_PERIOD_US = 20000; 	// Servo PWM period is 20ms	
   parameter DUTY_RES_BITS = 8;

   output out;
   input clk, enable;
   input [DUTY_RES_BITS-1:0] duty;

   reg out;
   
   // 1 tick = 1/CLK_FREQ_MHZ (us)

   integer pwm_period_ticks = PWM_PERIOD_US * CLK_FREQ_HZ / 1000000;
   integer edge_tick;
   integer ticks;

   initial begin
      ticks = 0; 
   end

   always @(posedge clk) begin

      if (ticks >= pwm_period_ticks) begin
         ticks = 0;
      end

      if (!enable) begin
         out = 1'b0;
      end
      else if (ticks >= edge_tick) begin
         out = 1'b0;
      end
      else begin 
         out = 1'b1;  
      end
      ticks = ticks + 1;
   end

   always @(duty)
      edge_tick = duty * pwm_period_ticks / ((1 << DUTY_RES_BITS)-1); 

endmodule
