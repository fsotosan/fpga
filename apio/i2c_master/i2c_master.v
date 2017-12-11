`ifndef _i2c_master_v
`define _i2c_master_v

`define STATE_IDLE     4'b0000
`define STATE_START    4'b0001
`define STATE_ADDR     4'b0010
`define STATE_ADDR_ACK 4'b0011
`define STATE_DATA     4'b0100
`define STATE_DATA_ACK 4'b0101
`define STATE_STOP     4'b0110
`define STATE_ERR      4'b1111

module i2c_master(sda,scl,done,err,clk,addr,data,num_bytes,start);

   output scl, err, done;
   inout sda;
   inout [7:0] data;
   input clk;
   input [7:0] addr;
   input start;
   input [5:0] num_bytes;

   reg [3:0] state = 4'b0000;
   reg [7:0] tx_buf, rx_buf, addr_buf, data_out;
   reg [3:0] num_bit;
   reg [5:0] bytes_left;
   reg err, sda_out, scl_out, done;

   initial begin
      state <= `STATE_IDLE;
   end

   always @(posedge start) begin
      sda_out <= 1'b1;
      scl_out <= 1'b1;
      state <= `STATE_START;
      addr_buf <= addr;
      if (addr[0] == 1'b0) begin
         tx_buf <= data;
      end
      else begin
         data_out <= 8'b0000_0000;
      end
      bytes_left <= num_bytes;
      done <= 1'b0;
      err <= 1'b0;
   end


   // https://www.nxp.com/docs/en/user-guide/UM10204.pdf
   // The data on SDA must be stable during HIGH period of the clock
   // The HIGH or LOW state of the data line can only change when the
   // clock signal on the SCL is LOW
   // -> write to SDA on negedge
   // -> read SDA on posedge

   always @(posedge clk) begin
      case(state)
         `STATE_START:
            // STATE_START comes always from STATE_IDLE
            // so it is assumed that both SDA and SCL are HIGH at this point
            begin
               sda_out <= 1'b0;
               state <= `STATE_ADDR;
               num_bit = 3'b000;
               done <= 0;
            end
         `STATE_STOP:
            // Initiate the STOP condition by setting SCL HIGH and SDA LOW
            begin
               scl_out <= 1'b1;
               sda_out <= 1'b0;
            end
         `STATE_ADDR_ACK:
            // Ckeck ACK on SCL's positive edge
            begin
               if (sda == 1'b0) begin
                  state <= `STATE_DATA;
                  num_bit = 3'b000;
               end
               else begin
                  state <= `STATE_ERR;
               end
            end
         `STATE_DATA:
            // In read operations, read SDA on positive edge
            begin
               if (addr_buf[0] == 1'b1) begin
                  rx_buf[3'b111 - num_bit] <= sda;
                  if (num_bit == 3'b111) begin
                     state <= `STATE_DATA_ACK;
                     done <= 0;
                  end
                  else begin
                     num_bit <= num_bit + 1;
                  end
               end
            end
         `STATE_DATA_ACK:
            // Ckeck ACK on SCL's positive edge
            begin
               if (sda == 1'b0) begin
                  if (addr_buf[0] == 1'b1) begin
                     data_out <= rx_buf;
                  end
                  if (bytes_left == 1) begin
                     state <= `STATE_STOP;
                  end
                  else begin
                     state <= `STATE_DATA;
                  end
                  bytes_left <= bytes_left - 1;
                  done <= 1;
               end
               else begin
                  state <= `STATE_ERR;
               end
            end
         `STATE_IDLE:
            // Ckeck ACK on SCL's positive edge
            begin
                err <= 0;
                done <= 0;
                sda_out <= 1'b1;
                scl_out <= 1'b1;
            end
      endcase
   end

   always @(negedge clk) begin
      case(state)
         // in STATE_ADDR scl_out is connected to clk
         // so there is no need to act on scl_out for completing START condition
         `STATE_STOP:
            // Complete the STOP condition by setting SDA HIGH
            begin
               if ((scl_out == 1'b1)&&(sda_out == 1'b0)) begin
                  sda_out <= 1'b1;
                  state <= `STATE_IDLE;
               end
            end
         `STATE_ADDR:
            begin
               sda_out <= addr[3'b111 - num_bit];
               if (num_bit == 3'b111) begin
                  state <= `STATE_ADDR_ACK;
               end
               else begin
                  num_bit <= num_bit + 1;
               end
            end
         `STATE_DATA:
            // In write operations, modify SDA on negative edge
            begin
               if (addr_buf[0] == 1'b0) begin
                  sda_out <= tx_buf[3'b111 - num_bit];
                  if (num_bit == 3'b111) begin
                     state <= `STATE_DATA_ACK;
                  end
                  else begin
                     num_bit <= num_bit + 1;
                  end
               end
            end
         `STATE_ERR:
            begin
               state <= `STATE_STOP;
               done <= 1'b0;
               err <= 1'b1;
            end
      endcase
   end


   assign scl = ((state == `STATE_ADDR) || (state == `STATE_ADDR_ACK) || (state == `STATE_DATA) || (state == `STATE_DATA_ACK)) ? clk : scl_out;
   assign sda = ((state == `STATE_ADDR_ACK) || (state == `STATE_DATA_ACK) || ((state == `STATE_DATA) && (addr_buf[0] == 1'b1))) ? 1'bz : sda_out;
   assign data = ((addr_buf[0] == 1'b1)&&(done == 1'b1)) ? data_out : 8'bz;


endmodule

`endif
