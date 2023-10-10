`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Salman Saiful Redzuan
// 
// Create Date: 24.01.2021 15:34:07
// Design Name: 
// Module Name: VGA_Sig_Gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: VGA signal generator and counter modules for VGA timing.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_Sig_Gen(
    input       CLK,
    input       RESET,
    input       [15:0] CONFIG_COLOURS,
    output      DPR_CLK,
    output      [14:0] VGA_ADDR,
    input       VGA_DATA,
    output  reg VGA_HS,
    output  reg VGA_VS,
    output  reg [0:7] VGA_COLOUR
    );
    
    //25MHz clock for VGA
    wire VGA_CLK;
    generic_counter # (.width(2),
                       .max(3))
                       down25 (
                            .CLK(CLK),
                            .RESET(RESET),
                            .ENABLE(1'b1),
                            .TRIG_OUT(VGA_CLK));
    
    //VGA signal parameters
    parameter HTs       = 800;
    parameter HTpw      = 96;
    parameter HTDisp    = 640;
    parameter Hbp       = 48;
    parameter Hfp       = 16;
    
    parameter VTs       = 525;
    parameter VTpw      = 2;
    parameter VTDisp    = 480;
    parameter Vbp       = 33;
    parameter Vfp       = 10;
    
    //Counter for V and H signal
    reg [9:0] HCounter;
    reg [8:0] VCounter;
    wire [9:0] xCounter;
    wire [9:0] yCounter;
    
    wire trigHorz;
    
    //HCounter
    generic_counter #  (.width(10),
                        .max(HTs - 1))
                        horz    (
                                .CLK(VGA_CLK),
                                .RESET(RESET),
                                .ENABLE(1'b1),
                                .TRIG_OUT(trigHorz),
                                .COUNT(xCounter));
                                
    //VCounter
    generic_counter #  (.width(10),
                        .max(VTs - 1))
                        vert    (
                                .CLK(trigHorz),
                                .RESET(RESET),
                                .ENABLE(1'b1),
                                .COUNT(yCounter));
                                
    always@(posedge CLK) begin
        if ((xCounter <= (HTs - Hfp)) &&
            (xCounter >= (HTpw + Hbp)) &&
            (yCounter <= (VTs - Vfp)) &&
            (yCounter >= (VTpw + Vbp))) begin
            HCounter <= xCounter - (HTpw + Hbp);
            VCounter <= yCounter - (VTpw + Vbp);
        end
        else begin
            HCounter <= 0;
            VCounter <= 0;
        end
    end
    
    always@(posedge CLK) begin
        if (xCounter < HTpw)
            VGA_HS <= 0;
        else
            VGA_HS <= 1;
    end
    
    always@(posedge CLK) begin
        if (yCounter < VTpw)
            VGA_VS <= 0;
        else
            VGA_VS <= 1;
    end
    
    wire [0:7] colour0, colour1;
    assign {colour1, colour0} = CONFIG_COLOURS;
    
    always@(posedge CLK) begin
        if ((xCounter <= (HTs - Hfp)) &&
            (xCounter >= (HTpw + Hbp)) &&
            (yCounter <= (VTs - Vfp)) &&
            (yCounter >= (VTpw + Vbp))) begin
                if (VGA_DATA == 0)
                    VGA_COLOUR <= colour0;
                else if (VGA_DATA == 1)
                    VGA_COLOUR <= colour1;
        end
        else
            VGA_COLOUR <= 0;
    end
    
    assign DPR_CLK = VGA_CLK;
    assign VGA_ADDR = {VCounter[8:2], HCounter[9:2]};
            
endmodule

module generic_counter(
        CLK,
        RESET,
        ENABLE,
        TRIG_OUT,
        COUNT
    );
    
    parameter width = 4;
    parameter max   = 9;
    
    input   CLK;
    input   RESET;
    input   ENABLE;
    output  TRIG_OUT;
    output [width-1:0]  COUNT;
    
    reg [width-1:0] count_value = 0;
    reg trigger_out = 0;
    
    always@(posedge CLK) begin
        if (RESET)
            count_value <= 0;
        else begin
            if (ENABLE) begin
                if (count_value == max)
                    count_value <= 0;
                else
                    count_value <= count_value + 1;
            end
        end
    end
    
    always@(posedge CLK) begin
        if (RESET)
            trigger_out <= 0;
        else begin
            if (ENABLE && (count_value == max))
                trigger_out <= 1;
            else 
                trigger_out <= 0;
        end
    end
    
    assign TRIG_OUT = trigger_out;
    assign COUNT    = count_value;
    
endmodule