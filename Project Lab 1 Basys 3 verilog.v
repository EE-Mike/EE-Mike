//Project Lab 1 Verilog Code
//Michael Salas, Ethan Nguyen, Bryanna Perales, Cristian Rivera
//Texas Tech University
//ECE-3331-301
//Dr. Clark

//-------------------------------------------------------------------------------
//The verilog code will control the average voltage out of the JC2 pin on       |
//PMOD JC in order to control the speed of an attached motor. Switches 0-7      |
//will be the controls for the variable duty cycles. Switches 0-3 will be speed |
//control and forward direction. Switches 4-7 will be speed control and rearward| 
//direction. The choice of a switch enables active high and will result in the  |
//appropriate duty cycle as well as the appropriate output values to the L298   |
//bridge to indicate motor selection as well. Version 1.7                       |
//-------------------------------------------------------------------------------

module Basys3 (clk,sw0,sw1,sw2,sw3,sw4,sw5,sw6,sw7,JC0,JC1,JC2);
//-------------------------------------------
//Inputs                                    |
//-------------------------------------------
input clk; //100Mhz Oscillator BASYS_3 Pin:W5

//Switches
input sw0;
input sw1;
input sw2;
input sw3;
input sw4;
input sw5;
input sw6;
input sw7;

//-------------------------------------------
//Outputs                                   |
//-------------------------------------------

//Outputs to Motor-A
output reg JC0; // Direction Control Pin:K17
output reg JC1; // Direction Control Pin:M18
output reg JC2; // PWM_OUT(Speed Control) Pin:N17

//Outputs to Motor-B
//output reg JC7; // Direction Control Pin:L17
//output reg JC8; // Direction Control Pin:M19
//output reg JC9; // PWM_OUT(Speed Control) Pin:P17

//--------------------------------------------
//Registers                                  |
//--------------------------------------------

//Pulse Width Modulation variable initialization
reg [3:0] counter_1 = 0;
reg [3:0] pulse_width = 0;

//Direction enable
reg enable_dir = 1;

//--------------------------------------------
//Pulse_width modulation                     |
//--------------------------------------------
always @(posedge clk) begin
    counter_1 <= counter_1+1;
    if(counter_1 >=9) begin
        counter_1 <= 0;
    end

    if (counter_1 < pulse_width) begin
        JC2 = 1'b1;
    end else begin
        JC2 = 1'b0;
    end

end


//-------------------------------------
//Pulse_Width and Direction Selection |
//---------------------------------------------------------------
//Changes the pulse width depending on the value of pulse_width.|
//which is obtained by polling switches 0-7.                    |
//Switches 0-3 are forward direction @variable pulse_width.     |
//switches 4-7 are reverse direction @ variable pulse_width.    |
//---------------------------------------------------------------
always @(posedge clk) begin
        
    pulse_width <= 0; //Reset Logic low for a consecutive switch press after a logic high assignment    
    
    if (sw0 == 1) begin
        pulse_width <= 10;
        enable_dir <= 1; 
    end 

    if (sw1 == 1) begin
        pulse_width <= 7;
        enable_dir <= 1;
    end

    if (sw2 == 1) begin
        pulse_width <= 5;
        enable_dir <= 1;
    end

    if (sw3 == 1) begin
        pulse_width <= 3;
        enable_dir <= 1;
    end
    
    if (sw4 == 1) begin
        pulse_width <= 10;
        enable_dir <= 0;
    end

    if (sw5 == 1) begin
        pulse_width <= 7;
        enable_dir <= 0;
    end

    if (sw6 == 1) begin
        pulse_width <= 5;
        enable_dir <= 0;
    end

    if (sw7 == 1) begin
        pulse_width <= 3;
        enable_dir <= 1;
    end

    if(enable_dir ==1) begin
        JC0 = 1'b1; //Forward Direction
        JC0 = 1'b0; //Ditto
    end else begin
        JC0 = 1'b0; //Reverse Direction
        JC1 = 1'b1; //Ditto
    end

end

endmodule