`timescale 1ns / 1ps

module LEDBusWrapper(
    //standard signals
    input CLK,
    input RESET,
    //BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    //LED signals
    output [15:0] LED_OUT
);
    
    parameter [7:0] LEDBaseAddr = 8'hC0;
    
    reg [7:0] LED_out;
    always@(posedge CLK) begin
        if((BUS_ADDR == LEDBaseAddr) & BUS_WE) begin
            LED_out = {BUS_DATA[0], BUS_DATA[1], BUS_DATA[2], BUS_DATA[3]}; //MouseStatus
        end
    end
    
    assign LED_OUT = LED_out;
    
    //No output necessary for seg7 interface
    assign BUS_DATA = 8'hZZ;

endmodule
