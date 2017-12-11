`ifndef _ads7924_v
`define _ads7924_v

`include "../i2c_master/i2c_master.v"

`define MODE_IDLE 6'b000000
`define MODE_AWAKE 6'b100000
`define MODE_MANUAL_SINGLE 6'b110000
`define MODE_MANUAL_SCAN 6'b110010
`define MODE_AUTO_SINGLE 6'b110001
`define MODE_AUTO_SCAN 6'b110011
`define MODE_AUTO_SINGLE_W_SLEEP 6'b111001
`define MODE_AUTO_SCAN_W_SLEEP 6'b111011
`define MODE_AUTO_BURST_SCAN_W_SLEEP 6'b111111

`define ADDR_MODECNTRL 5'h00
`define ADDR_INTCNTRL  5'h01

`define ADDR_DATA0_U 5'h02
`define ADDR_DATA0_L 5'h03
`define ADDR_DATA1_U 5'h04
`define ADDR_DATA1_L 5'h05
`define ADDR_DATA2_U 5'h06
`define ADDR_DATA2_L 5'h07
`define ADDR_DATA3_U 5'h08
`define ADDR_DATA3_L 5'h09

`define ADDR_ULR0 5'h0A
`define ADDR_LLR0 5'h0B
`define ADDR_ULR1 5'h0C
`define ADDR_LLR1 5'h0D
`define ADDR_ULR2 5'h0E
`define ADDR_LLR2 5'h0F
`define ADDR_ULR3 5'h10
`define ADDR_LLR3 5'h11

`define ADDR_INTCONFIG 5'h12
`define ADDR_SLPCONFIG 5'h13
`define ADDR_ACQCONFIG 5'h14
`define ADDR_PWRCONFIG 5'h15

`define ADDR_RESET 5'h16

// interruption on Data Ready (one conversion completed), active low and pulse signal
`define INTCNFG_DR_ONE_AL_PULSE 8'b00001001

module ads7924(_int, sda, scl, clk, data_ready, ch0, ch1, ch2, ch3);

   parameter MODE = `MODE_AUTO_SINGLE;
   parameter ADDRESS = 7'b1000100;	// A0 to GND
   parameter CHSEL = 2'b00;		// Channel 0

   input _int, clk;
   inout sda;
   output scl;
   output reg data_ready;
   output reg [11:0] ch0, ch1, ch2, ch3;

   wire err;
   reg start;
   wire [7:0] data;
   reg [7:0] address;
   reg [5:0] num_bytes;


   i2c_master I2C(sda,scl,done,err,clk,address,data,num_bytes,start);

endmodule

`endif
