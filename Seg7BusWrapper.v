`timescale 1ns / 1ps

module Seg7BusWrapper (
   //standard signals
    input CLK,
    input RESET,
    //BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    //Seg7 signals
    output [3:0] SEG_SELECT,
    output [7:0] HEX_OUT
);

    parameter [7:0] Seg7BaseAddr = 8'hD0; // Seg7 Base Address in the Memory Map
    
    // Strobe counters for seg7 display
    wire Bit17TriggOut;
    wire [1:0] StrobeCount;
    
    // Instantiate counters
    // 17-bit counter
    Generic_counter # (.COUNTER_WIDTH(17),
                       .COUNTER_MAX(99999)
                       )
                       Bit17Counter (
                       .CLK(CLK), 
                       .RESET(1'b0), 
                       .ENABLE(1'b1), 
                       .TRIG_OUT(Bit17TriggOut)
                       );
                    
    // 2-bit counter                
    Generic_counter # (.COUNTER_WIDTH(2), 
                       .COUNTER_MAX(4)
                       )
                       Bit2Counter (
                       .CLK(CLK), 
                       .RESET(1'b0), 
                       .ENABLE(Bit17TriggOut), 
                       .COUNT(StrobeCount)
                       );
    
    //Seg7 input: data arrives in two sets of two bytes. 
    //Split into single bytes for mux inputs depending on bus address. 
    reg [3:0] MuxInA, MuxInB, MuxInC, MuxInD;
    always@(posedge CLK) begin
        if(BUS_WE) begin
            if(BUS_ADDR == Seg7BaseAddr) begin //MouseY bytes
                MuxInA <= BUS_DATA[3:0];
                MuxInB <= BUS_DATA[7:4];
            end
            else if(BUS_ADDR == Seg7BaseAddr + 8'h01) begin //MouseX bytes
                MuxInC <= BUS_DATA[3:0];
                MuxInD <= BUS_DATA[7:4];
            end     
        end 
    end
                      
    wire [4:0] MuxOut;                    
    // Instantiate the Multiplexer
    Multiplexer_4way Mux4 (
        .CONTROL(StrobeCount),
        .IN0({1'b0, MuxInA}),
        .IN1({1'b0, MuxInB}),
        .IN2({1'b0, MuxInC}),
        .IN3({1'b0, MuxInD}),
        .OUT(MuxOut)
    );                  
                                                      
    // Instantiate the 7 segment Decoder      
    seg7decoder Seg7 (
        .SEG_SELECT_IN(StrobeCount),
        .BIN_IN(MuxOut [3:0]),
        .DOT_IN(MuxOut [4]),
        .SEG_SELECT_OUT(SEG_SELECT),
        .HEX_OUT(HEX_OUT)                       
    ); 
    
    //No output necessary for seg7 interface
    assign BUS_DATA = 8'hZZ;

endmodule