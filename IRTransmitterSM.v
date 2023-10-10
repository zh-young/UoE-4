`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/05 20:32:28
// Design Name: 
// Module Name: IRTransmitterSM
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


module IRTransmitterSM(
    input RESET,
    input CLK,//50MHz
    input [3:0] COMMAND,
    input SEND_PACKET,
    output IR_LED
    );   
    
    parameter StartBurstSize=88;
    parameter CarSelectBurstSize=22;
    parameter GapSize=40;
    parameter AssertBurstSize=44;
    parameter DeAssertBurstSize=22;
    
    //40KHz counter(from CLK 50MHz)
    parameter COUNTER_WIDTH=12; //counter 0-9
    parameter COUNTER_MAX=2667-1; 

    reg [COUNTER_WIDTH-1:0] counter_value=0;
    reg CLK_pulse=0;

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

    always@(posedge CLK) begin
        if(RESET)
            CLK_pulse <=0;
        else begin
        if(counter_value<=COUNTER_MAX/2-1) 
            CLK_pulse <= 1;    
        else 
            CLK_pulse <= 0;
        end
    end     

    //state machine for packet
    
    reg [3:0] Command_direction=0;
 
    reg [3:0] next_Command_direction=0;
    
    always@(COMMAND) begin
        case(COMMAND)
            4'b0000: begin 
                next_Command_direction<=4'b0000;
            end
            
            4'b0001: begin
                next_Command_direction<=4'b0001;
            end
            
            4'b0010: begin 
                next_Command_direction<=4'b0010;
            end
                       
            4'b0100: begin
                next_Command_direction<=4'b0100;
            end
            
            4'b0101: begin
                next_Command_direction<=4'b0101;
            end
                
            4'b0110: begin
                next_Command_direction<=4'b0110;
            end
            
            4'b1000: begin
                next_Command_direction<=4'b1000;
            end
                
            4'b1001: begin
                next_Command_direction<=4'b1001;
            end
            
            4'b1010: begin
                next_Command_direction<=4'b1010;
            end
            
     default:begin
            next_Command_direction<=4'b0000;
     end
        endcase       
    end                   
    
    always@(posedge CLK)begin
    
        if(RESET) begin
            Command_direction <= 4'd4;
        end
                
        else begin
            Command_direction <= next_Command_direction;
        end    
    end     
    
//generate IR_LED
    reg [3:0]car_state=0;//0 start,2 select,4 right,6 left, 8 backward,10 forward, 1 3 5 7 9 11 gap
    reg [6:0]PulseCounter=0;
    reg [6:0]PulseCounterMax=0;    
    reg pulse_gen=0;
    
    reg [3:0]Curr_car_state=0;
    reg [3:0]Last_car_state=0;
    
    //Generate the process control variable
    always@(posedge CLK)begin
    // Utilize the top-down sequence to generate the Last_car_state
        Last_car_state<=Curr_car_state;
        Curr_car_state<=car_state;
       
        if((Curr_car_state==4'd0)&&(Last_car_state==4'd11))
            pulse_gen<=0;
        if(SEND_PACKET)
            pulse_gen<=1;               
    end
   
    //count pause in different packet region
    always@(posedge CLK) begin
        case (car_state)
         4'd0: PulseCounterMax <= StartBurstSize -1; 
         4'd1: PulseCounterMax <= GapSize -1;
         4'd2: PulseCounterMax <= CarSelectBurstSize -1;
         4'd3: PulseCounterMax <= GapSize -1;
         4'd4: begin
         if (Command_direction[0])
         PulseCounterMax <= AssertBurstSize -1;
         else
         PulseCounterMax<=DeAssertBurstSize-1;
         end
         4'd5: PulseCounterMax <= GapSize -1;
         
         4'd6:begin
          if (Command_direction[1])
          PulseCounterMax <= AssertBurstSize -1;
          else
          PulseCounterMax<=DeAssertBurstSize-1;
          end
          
         4'd7: PulseCounterMax <= GapSize -1;
         
         4'd8:begin
          if (Command_direction[2])
          PulseCounterMax <= AssertBurstSize -1;
          else
          PulseCounterMax<=DeAssertBurstSize-1;
          end
          
         4'd9: PulseCounterMax <= GapSize -1;
           
         4'd10:begin
          if (Command_direction[3])
          PulseCounterMax <= AssertBurstSize -1;
          else
          PulseCounterMax<=DeAssertBurstSize-1; 
          end
          
         4'd11:PulseCounterMax <= GapSize -1;
        endcase            
    end
    
    
    always@(posedge CLK_pulse) begin
        if(RESET)
            PulseCounter<=0;
        else begin
            if(pulse_gen)begin//update pulse counter           
                if(PulseCounter==PulseCounterMax) begin//upload region state(start,gap,selection....)                
                    PulseCounter<=0;                
                    if(car_state==4'd11)
                        car_state<=0;
                    else
                        car_state<=car_state+1;
                end                
                else
                    PulseCounter<=PulseCounter+1;
            end           
        end           
    end
    
    reg out=0;
    
    always@(posedge CLK_pulse) begin
        if((~car_state[0])&pulse_gen)
            out<=1;
        else
            out<=0;
    end
                
    assign IR_LED=out&CLK_pulse;

endmodule
