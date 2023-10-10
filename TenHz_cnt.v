`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/21 23:48:33
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
//Standard Signals
 input CLK,//50MHz
 input RESET,
 input Switch,
 // Output
 output SEND_PACKET//10Hz
);

    parameter COUNTER_WIDTH =32; //counter 0-9
    parameter COUNTER_MAX=10000000-1;
    //5000000-1 

    reg [COUNTER_WIDTH-1:0] counter_value=0;
    reg trig_out=0;    
    
    // counter increment
    always@(posedge CLK) begin
        if(RESET==1)
            counter_value <=0;
        else begin
            if(counter_value==COUNTER_MAX) 
                counter_value<=0;    
            else 
                counter_value<=counter_value+1;
        end
    end    
    
    // Send Packet
    always@(posedge CLK) begin
        if(RESET)
            trig_out <=0;
        else if(Switch)begin
            if(counter_value==COUNTER_MAX) 
                trig_out<= 1;    
            else 
                trig_out<= 0;
        end
    end   
    
    assign SEND_PACKET=trig_out;
endmodule
