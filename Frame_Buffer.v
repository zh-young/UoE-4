`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Salman Saiful Redzuan
// 
// Create Date: 24.01.2021 14:32:23
// Design Name: 
// Module Name: Frame_Buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: A module to hold data for each pixel.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Frame_Buffer(
    input       A_CLK,
    input       [14:0] A_ADDR,
    input       A_DATA_IN,
    output  reg A_DATA_OUT,
    input       A_WE,
    input       B_CLK,
    input       [14:0] B_ADDR,
    output  reg B_DATA
    );
    
    //256x128 1-bit memory to hold frame data
    //LSB is x axis, MSB is y axis
    reg [0:0] Mem [2**15-1:0];
    //initial
      //  $readmemb("C:/Users/jrste/OneDrive - University of Edinburgh/DSL4/microprocessor/microprocessor.srcs/screen_3x3.txt", Mem);
    
    //Port A - read/write 
    always@(posedge A_CLK) begin
        if(A_WE)
            Mem[A_ADDR] <= A_DATA_IN;
            
        A_DATA_OUT <= Mem[A_ADDR];
    end
    
    //Port B - read only
    always@(posedge B_CLK)
        B_DATA <= Mem[B_ADDR];
    
endmodule