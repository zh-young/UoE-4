`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Zihao Yang
// 
// Create Date: 2021/03/15 01:23:13
// Design Name: Microprocessor + IR transmitter
// Module Name: Wrapper
// Project Name: Digital system lab 4
// Target Devices: 
// Tool Versions: Verilog 2015.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Wrapper(
    input CLK,
    input RESET,
    
     inout CLK_MOUSE,
     inout DATA_MOUSE,
       //Seg7 signals
     output [3:0] SEG_SELECT,
     output [7:0] HEX_OUT,
    
    output [15:0] LED_OUT,
    
    input Switch,
    output IR_LED

    );
    
    wire [7:0] BUS_ADDR;
    wire [7:0] BUS_DATA;
    wire BUS_WE;
    wire [7:0] ROM_ADDR;
    wire [7:0] ROM_DATA;
    wire [1:0] BUS_INTERRUPT_RAISE;
    wire [1:0] BUS_INTERRUPT_ACK;
    wire BUS_INTERRUPT_RAISE_Timer;
    wire BUS_INTERRUPT_RAISE_Mouse;
//    assign BUS_INTERRUPT_RAISE={BUS_INTERRUPT_RAISE_Timer,1'b0};   // we just need to use the 1 bit value
    
     MouseBusWrapper MouseBus_Wrapper(
       //standard signals
       .CLK(CLK),
       .RESET(RESET),
       //BUS signals
       .BUS_DATA(BUS_DATA),
       .BUS_ADDR(BUS_ADDR),
       .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE[0]),
       .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK[0]),
       //PS2 signals
       .CLK_MOUSE(CLK_MOUSE),
       .DATA_MOUSE(DATA_MOUSE)
       );
       
     Seg7BusWrapper seg(
             //standard signals
              .CLK(CLK),
              .RESET(RESET),
              //BUS signals
              .BUS_DATA(BUS_DATA),
              .BUS_ADDR(BUS_ADDR),
              .BUS_WE(BUS_WE),
              //Seg7 signals
              .SEG_SELECT(SEG_SELECT),
              .HEX_OUT(HEX_OUT)
          );
          
          //Instantiate LEDs
          LEDBusWrapper led(
              //standard signals
              .CLK(CLK),
              .RESET(RESET),
              //BUS signals
              .BUS_DATA(BUS_DATA),
              .BUS_ADDR(BUS_ADDR),
              .BUS_WE(BUS_WE),
              //LED signals
              .LED_OUT(LED_OUT)
          );
          
    IR_TOP IR_TOP_Wrapper (
    .CLK(CLK),
    .RESET(RESET),
    .Switch(Switch),
    .BUS_ADDR(BUS_ADDR),
    .BUS_DATA(BUS_DATA),
    .BUS_WE(BUS_WE),
    .IR_LED(IR_LED)
    );
    
    RAM RAM_Wrapper(
    .CLK(CLK),
    .BUS_ADDR(BUS_ADDR),
    .BUS_DATA(BUS_DATA),
    .BUS_WE(BUS_WE)
    );
    
    ROM ROM_Wrapper (
    .CLK(CLK),
    .DATA(ROM_DATA),
    .ADDR(ROM_ADDR)
    );
    
    Timer Timer_Wrapper(
    .CLK(CLK),
    .RESET(RESET),
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE),
    .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE[1]),
    .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK[1])
    );
    
    Processor Processor_Wrapper (
    .CLK(CLK),
    .RESET(RESET),
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE),
    .ROM_ADDRESS(ROM_ADDR),
    .ROM_DATA(ROM_DATA),
    .BUS_INTERRUPTS_RAISE(BUS_INTERRUPT_RAISE),
    .BUS_INTERRUPTS_ACK(BUS_INTERRUPT_ACK)
    );
    
    
    
    
endmodule
