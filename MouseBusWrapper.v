`timescale 1ns / 1ps

module MouseBusWrapper(
    //standard signals
    input CLK,
    input RESET,
    //BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    output BUS_INTERRUPT_RAISE,
    input BUS_INTERRUPT_ACK,
    //PS2 signals
    inout CLK_MOUSE,
    inout DATA_MOUSE
);

    parameter [7:0] MouseBaseAddr = 8'hA0;  // Mouse Base Address in the Memory Map
    
    wire [3:0] MouseStatus;
    wire [7:0] MouseX, MouseY;
    //Instantiate MouseTransciever module
    MouseTransceiver MT(
        //Standard Inputs
        .RESET(RESET),
        .CLK(CLK),
        //IO - Mouse side
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        // Mouse data information
        .MouseStatus(MouseStatus),
        .MouseX(MouseX),
        .MouseY(MouseY),
        .SendInterrupt(SendInterrupt)
    );
    
    /////////////////////
    //BaseAddr + 0 -> presents MouseStatus byte to BUS_DATA
    //BaseAddr + 1 -> presents MouseX bytes to BUS_DATA
    //BaseAddr + 2 -> presents MouseY bytes to BUS_DATA
    
    //BUS_DATA output decision
    reg TransmitMouseValue;
    reg [7:0] DataOut;
    always@(posedge CLK) begin
        if(BUS_ADDR == MouseBaseAddr) begin
            DataOut <= MouseStatus;
            TransmitMouseValue <= 1'b1;
        end else if(BUS_ADDR == MouseBaseAddr + 8'h01) begin
            DataOut <= MouseX;
            TransmitMouseValue <= 1'b1;
        end else if(BUS_ADDR == MouseBaseAddr + 8'h02) begin
            DataOut <= MouseY;
            TransmitMouseValue <= 1'b1;
        end else
            TransmitMouseValue <= 1'b0;
    end
    
       
    assign BUS_DATA = TransmitMouseValue ? DataOut : 8'hZZ;
    assign BUS_INTERRUPT_RAISE = SendInterrupt;

endmodule