`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/15 01:18:56
// Design Name: 
// Module Name: IR_TOP
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


module IR_TOP(
    input CLK,
    input RESET,
    
    input Switch,
    input Switch_mode,
    input [3:0] Push_button,
    
    input [7:0] BUS_ADDR,
    input [7:0] BUS_DATA, 
    input BUS_WE,
    
    output IR_LED

    );
    
    wire CLK_10Hz;
    
    reg [3:0] Curr_data;
    reg [3:0] Next_data;
    
    wire [3:0] COMMAND;
    always@(posedge CLK)begin
      if (RESET)
        Curr_data<=4'b0000;
      else
        Curr_data <= Next_data;
    end
    
    always@(posedge CLK)begin
       if(RESET)
         Next_data<=4'b0;
       else if((BUS_ADDR==8'h90)&&(BUS_WE)&&(Switch_mode==0))
         Next_data <= BUS_DATA[3:0];    
       else if (Switch_mode)
         Next_data <= Push_button;
    end
    
    assign COMMAND = Curr_data;
    
   TenHz_cnt   Counter_10Hz (
               .CLK(CLK),
               .RESET(RESET),
               .Switch(Switch),
               .SEND_PACKET(CLK_10Hz)              
               );
    
    
    
    IRTransmitterSM  IR_SM_Wrapper(
    .CLK(CLK),
    .RESET(RESET),
    .COMMAND(COMMAND),
    .SEND_PACKET(CLK_10Hz),
    .IR_LED(IR_LED)
    
     );
endmodule
