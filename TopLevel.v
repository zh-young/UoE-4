`timescale 1ns / 1ps

module TOP(
    //Standard signals
    input CLK,
    input RESET,
    //Switch and Buttons
    input Switch,
    input Switch_mode,
    input [3:0] Push_button,
    //PS2 Mouse signals
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    //Seg7 signals
    output [3:0] SEG_SELECT,
    output [7:0] HEX_OUT,
    //LED signal
    output [15:0] LED_OUT,
    //IR signal
    output IR_LED,
    //VGA signals
    output VGA_HS,
    output VGA_VS,
    output [0:7] VGA_COLOUR
);
    
    //BUS signals
    wire [7:0] BUS_DATA, BUS_ADDR;
    wire BUS_WE;
    //ROM signals
    wire [7:0] ROM_ADDRESS, ROM_DATA;
    //INTERRUPT signals
    wire [1:0] BUS_INTERRUPTS_RAISE, BUS_INTERRUPTS_ACK;
    assign BUS_INTERRUPTS_RAISE = {TIMER_INTERRUPT_RAISE, MOUSE_INTERRUPT_RAISE};
    //Instantiate Processor
    Processor P (
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS Signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        //ROM signals
        .ROM_ADDRESS(ROM_ADDRESS),
        .ROM_DATA(ROM_DATA),
        //INTERRUPT signals
        .BUS_INTERRUPTS_RAISE(BUS_INTERRUPTS_RAISE),
        .BUS_INTERRUPTS_ACK(BUS_INTERRUPTS_ACK)
    );
    
    //Instantiate ROM
    ROM rom(
        //standard signals
        .CLK(CLK),
        //BUS signals
        .DATA(ROM_DATA),
        .ADDR(ROM_ADDRESS)
    );
    
    //Instantiate RAM
    RAM ram(
        //standard signals
        .CLK(CLK),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE)
    );
    
    wire TIMER_INTERRUPT_ACK;
    assign TIMER_INTERRUPT_ACK = BUS_INTERRUPTS_ACK[1];
    //Instantiate Timer
    Timer T(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .BUS_INTERRUPT_RAISE(TIMER_INTERRUPT_RAISE),
        .BUS_INTERRUPT_ACK(TIMER_INTERRUPT_ACK)
    );
    
    wire MOUSE_INTERRUPT_ACK;
    assign MOUSE_INTERRUPT_ACK = BUS_INTERRUPTS_ACK[0];
    //Instantiate Mouse Driver
    MouseBusWrapper M(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_INTERRUPT_RAISE(MOUSE_INTERRUPT_RAISE),
        .BUS_INTERRUPT_ACK(MOUSE_INTERRUPT_ACK),
        //PS2 signals
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE)
    );
    
    //Instantiate Seg7
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
    
    //Instantiate IR Transmitter
    IR_TOP IR(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        .Switch(Switch),
        .Switch_mode(Switch_mode),
        .Push_button(Push_button),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        //IR signals
        .IR_LED(IR_LED)
    );
    
    VGA_Controller VGA(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        //VGA signals
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_COLOUR(VGA_COLOUR)
    );
//     wire tmp_a[4:0];
//     wire b[4:0];
//       assign tmp_a={(tmp_a[3:0]&b[3:0]),1'b1};
    
endmodule
