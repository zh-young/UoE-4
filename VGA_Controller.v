`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.03.2021 20:23:52
// Design Name: 
// Module Name: VGA_Controller
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


module VGA_Controller(
    input CLK,
    input RESET,
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    //VGA ports
    output VGA_HS,
    output VGA_VS,
    output [0:7] VGA_COLOUR
    );
    
    parameter [7:0] VGABaseAddr = 8'hB0;
    
    // X, Y Limits of Mouse Position e.g. VGA Screen with 160 x 120 resolution
    parameter [7:0] LimitX = 160;
    parameter [7:0] LimitY = 120;
    
    //colours
    parameter [7:0]
    black = 8'b00000000,
    white = 8'b11111111,
    red = 8'b11100000,
    green = 8'b00011100,
    blue = 8'b00000011;
    
    ////////////////////////////////////////////////////////////////////
    //BaseAddr + 0 -> command value
    //BaseAddr + 1 -> x-coordinate
    //BaseAddr + 2 -> y-coordinate
    
    
    wire [14:0] addr;
    wire data;
    wire [15:0] colours;
    
    reg colour;
    reg [7:0] X_coordinate;
    reg [6:0] Y_coordinate;
    
    
    always@(posedge CLK) begin
        if ((BUS_ADDR == (VGABaseAddr + 8'h00)))
            colour <= BUS_DATA[0];
        if ((BUS_ADDR == (VGABaseAddr + 8'h01)))
            X_coordinate <= BUS_DATA;
        else if ((BUS_ADDR == (VGABaseAddr + 8'h02)))
            Y_coordinate <= LimitY - 1 - BUS_DATA[6:0];
    end
    
    VGA_Sig_Gen vga (
        .CLK(CLK),
        .RESET(RESET),
        .DPR_CLK(),
        .VGA_ADDR(addr),
        .VGA_DATA(data),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .CONFIG_COLOURS(colours),
        .VGA_COLOUR(VGA_COLOUR)
        );

    Frame_Buffer fb (
        .A_CLK(CLK),
        .A_ADDR({Y_coordinate, X_coordinate}),
        .A_DATA_IN(colour),
        .A_DATA_OUT(),
        .A_WE(BUS_WE),
        .B_CLK(CLK),
        .B_ADDR(addr),
        .B_DATA(data)
        );
        
    control colour_set(
        .CLK(CLK),
        .colours(colours)
        );
        
endmodule

module control(
    input CLK,
    output [15:0] colours
    );
    
    reg [0:7] colour1, colour0;             //colour0 is background, colour1 is foreground          
                                            //colours; MSB is RED, LSB is BLUE
    wire [0:7] foreground, background;
    wire slowCLK;
    generic_counter # (.width(3),
                       .max(7))
                       slow (
                            .CLK(CLK),
                            .RESET(RESET),
                            .ENABLE(1'b1),
                            .TRIG_OUT(slowCLK));
                            
    random colour0Shift (
        .CLK(slowCLK),
        .OUT(background));
    
    random colour1Shift (
        .CLK(CLK),
        .OUT(foreground));
   
    generic_counter # (.width(27),
                       .max(100000000))
                        oneSec (
                            .CLK(CLK),
                            .ENABLE(1'b1),
                            .RESET(1'b0),
                            .TRIG_OUT(oneSec));
                            
    always@(posedge CLK) begin
        if (oneSec) begin
            colour1 = foreground;
            colour0 = background;
        end
    end
    
    assign colours = {colour1, colour0};
endmodule

module random(
    input CLK,
    output reg [7:0] OUT
    );
    
    assign taps = ((OUT[7]) ^~ (OUT[3])) ^~ ((OUT[2]) ^~ (OUT[1]));
    
    always@(posedge CLK)
        OUT = {OUT[6:0], taps};
 
    
endmodule