`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/15 01:24:19
// Design Name: 
// Module Name: TenHz_cnt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TenHz_cnt(
        input CLK,
        input RESET,
        input Switch,
        output SEND_PACKET
      
    );
    
    
parameter COUNTER_WIDTH = 25;                  // counter bit
parameter COUNTER_MAX = 9999999;                //count max value

reg [COUNTER_WIDTH-1:0] count_value=0;
reg Trigger_out;

always@(posedge CLK) begin
  if(RESET)                                //if reset is 0 and enable is 1 counter will count
    count_value <= 0;
  else begin
  
      if(count_value == COUNTER_MAX)       //if the counting value doesn't reach max value, it will count without stopping
       count_value <= 0;
      else
        count_value <= count_value + 1;
      end 
     end  
     
       
              
//synchronous logic for Trigger_out
    
    always@(posedge CLK) begin
    if (Switch)begin
      if(RESET)
        Trigger_out <= 0;                  // It controls carry and its value only has 0,1 much like a clock
      else begin
        if (count_value<=COUNTER_MAX/2)
          Trigger_out <= 1;
        else
          Trigger_out <= 0;
       
       end
     end   
   end       
       
        assign SEND_PACKET = Trigger_out;  
          
endmodule
