`include "i2c_master.v"

module i2c_master_tb;

   reg clk, sda_out;
   wire out, scl, done, err;
   wire [7:0] data;
   reg [7:0] addr;
   reg [7:0] received_data;
   reg [5:0] num_bytes;
   reg start;
   reg send_ack;

   i2c_master I0(sda,scl,done,err,clk,addr,data,num_bytes,start);

   initial begin
      clk = 0;
      start = 0;
      send_ack = 0;
   end

   // clk period 10 time units
   always
      #5  clk = !clk;

   initial begin
      $dumpfile("i2c_master_tb.vcd");
      $dumpvars;
   end

   initial begin
      $display("\t\ttime,\tclk,\tscl,\tsda,\tdone,\tdata,\terr");
      $monitor("%d,\t%b,\t%b,\t%b,\t%b,\t%b",$time,clk,scl,sda,done,err);
   end


   initial begin
      addr = 8'b1011_1101;  // READ operation of one byte
      num_bytes = 1;
      #20 start = 1;
      #20 start = 0;
      #60 send_ack = 1'b1;
      #10 send_ack = 1'b0;
      #80 send_ack = 1'b1;
      #10 send_ack = 1'b0;
   end

   initial begin
      sda_out = 1'bz; // Receive 6D on SDA in the READ operation
      #110 sda_out = 0;
      #10 sda_out = 1;
      #10 sda_out = 1;
      #10 sda_out = 0;
      #10 sda_out = 1;
      #10 sda_out = 1;
      #10 sda_out = 0;
      #10 sda_out = 1;
      #10 sda_out = 0;
      #10 sda_out = 1'bz;
   end

   always @(posedge done) begin
      if (addr[0] == 1'b1) begin
         received_data <= data;
      end
   end

   initial begin
      #250 addr = 8'b1011_1100;  // WRITE operation of one byte
      #30 start = 1;
      #10 start = 0;
      #70 send_ack = 1'b1;
      #10 send_ack = 1'b0;
      #70 send_ack = 1'b1;
      #10 send_ack = 1'b0;
      #100 $finish;
   end

   assign sda = (send_ack == 1'b1)? 1'b0: sda_out;
   assign data = (addr[0] == 1'b0)? 8'b0110_1010: 1'bz;


endmodule
