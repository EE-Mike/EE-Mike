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
//bridge to indicate motor selection as well. Version 1.9                       |
//-------------------------------------------------------------------------------

module Basys3 (clk,sw0,sw1,sw2,sw3,sw4,sw5,sw6,sw7,JC0,JC1,JC2,JC7,JC8,JC9,currentSenseA,currentSenseB);
//----------------------------------------------------------------------------
//Inputs                                                                     |
//----------------------------------------------------------------------------
input clk; //100Mhz Oscillator BASYS_3 Pin:W5

//Switches
input sw0; //Forward 100% duty cycle
input sw1; //Forward 75%  duty cycle
input sw2; //Forward 50%  duty cycle
input sw3; //Forward 25%  duty cycle
input sw4; //Reverse 100% duty cycle
input sw5; //Reverse 75%  duty cycle
input sw6; //Reverse 50%  duty cycle
input sw7; //Reverse 25%  duty cycle

//----------------------------------------------------------------------------
//Outputs                                                                    |
//----------------------------------------------------------------------------

//Outputs to Motor-A
output reg JC0; // Direction     Control  Pin:K17
output reg JC1; // Direction     Control  Pin:M18
output reg JC2; // PWM_OUT(Speed Control) Pin:N17

//Outputs to Motor-B
output reg JC7; // Direction     Control  Pin:L17
output reg JC8; // Direction     Control  Pin:M19
output reg JC9; // PWM_OUT(Speed Control) Pin:N18

output reg currentSenseA;    //Current Protect for Motor A
output reg currentSenseB;   //Current Protect for Motor B
//----------------------------------------------------------------------------
//Registers                                                                  |
//----------------------------------------------------------------------------

//Pulse Width Modulation variable initialization
reg [3:0] counter_1 = 0;
reg [3:0] pulse_width = 0;

//Direction enable
reg enable_dir = 1;

//Overcurrent Protection 
reg turnOff;
reg [20:0] counterCurrentA,counterCurrentB,counterCurrent_limit;

//---------------------------------------------------------------------------
//Pulse_width modulation                                                    |
//---------------------------------------------------------------------------
always @(posedge clk) begin
    
    if(counter_1 >= 100) begin // 10Mhz carrier signal
        counter_1 <= 0;
    end else begin
        counter_1 <= counter_1+1; 
    end
    if (counter_1 < pulse_width) begin
        JC2 = 1'b1;
        JC9 = 1'b1;
    end else begin
        JC2 = 1'b0;
        JC9 = 1'b0;
    end

end

//-------------------------------------------------------------------------
//Pulse_Width and Direction Selection (I and II)                          |
//-------------------------------------------------------------------------
//Changes the pulse width depending on the value of pulse_width.          |
//which is obtained by polling switches 0-7.                              |
//Switches 0-3 are forward direction @variable pulse_width.               |
//switches 4-7 are reverse direction @ variable pulse_width.              |
//-------------------------------------------------------------------------
always @(posedge clk) begin
    
    if (turnOff == 1) begin 

    pulse_width <= 0;
    if (sw0 == 1) begin

        pulse_width <= 100;
        enable_dir <= 1;

    end 

    if (sw1 == 1) begin

        pulse_width <= 75;
        enable_dir <= 1;

    end

    if (sw2 == 1) begin

        pulse_width <= 50;
        enable_dir <= 1;

    end 

    if (sw3 == 1) begin

        pulse_width <= 25;
        enable_dir <= 1;

    end
    
    if (sw4 == 1) begin

        pulse_width <= 100;
        enable_dir <= 0;
    
    end 

    if (sw5 == 1) begin

        pulse_width <= 75;
        enable_dir <= 0;

    end 

    if (sw6 == 1) begin

        pulse_width <= 50;
        enable_dir <= 0;

    end 

    if (sw7 == 1) begin

        pulse_width <= 25;
        enable_dir <= 0;
    
    end

    //---------------------------|
    //Direction Assignment Block |
    //---------------------------|
    if(enable_dir == 1) begin
        JC0 = 1'b1; //Forward Direction
        JC1 = 1'b0; //Ditto
        JC7 = 1'b0; //Ditto
        JC8 = 1'b1; //Ditto
    end 
    else begin
        JC0 = 1'b0; //Reverse Direction
        JC1 = 1'b1; //Ditto
        JC7 = 1'b1; //Ditto
        JC8 = 1'b0; //Ditto

    end
    end
end

//----------------------------|
//Over Current Implimentation |
//----------------------------|
//----------------------------------------------|
//When the current to either motor exceeds 1A   |
//ENA and ENB are disabled to protect the motor |
//from over surge                               |
//----------------------------------------------|
initial begin

    counterCurrentA = 1'd0;
    counterCurrentB = 1'd0;
    counterCurrent_limit = 4'd9;
    turnOff = 1;

end

always @ (posedge clk) begin

   if (currentSenseA == 1)
        counterCurrentA <= counterCurrentA + 1;
   else if (currentSenseA == 0) begin
        counterCurrentA <= 0;
   end

   if (counterCurrentA == counterCurrent_limit)
        turnOff <= 0;

   if (currentSenseB == 1)
        counterCurrentB <= counterCurrentB + 1;
   else if (currentSenseB == 0) begin
        counterCurrentB <= 0;
   end

   if (counterCurrentB == counterCurrent_limit)
        turnOff <= 0;

   end 

endmodule