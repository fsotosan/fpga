`ifndef _icezum_adc_v
`define _icezum_adc_v



`include "../ads7924/ads7924.v"

module icezum_adc(ch0,ch1,ch2,ch3,clk);

  input clk;
  output ch0, ch1, ch2, ch3;

  wire data_ready, _int, sda, scl;

  ads7924 ADC(_int, sda, scl, clk, data_ready, ch0, ch1, ch2, ch3);


endmodule

`endif
