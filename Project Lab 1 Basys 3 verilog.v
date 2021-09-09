//Project Lab 1 Verilog Code
//Michael Salas, Ethan Nguyen, Bryanna Perales, Cristian Rivera
//Texas Tech University
//ECE-3331-301
//V1.5
//-----------------------------------------------------------------------------
//The verilog code will control the average voltage out of the PWR pin on
//PMOD JC in order to control the speed of an attached motor. Switches 0-7
//will be the controls for the variable duty cycle. Switches 0-3 will be speed
//and forward direction. Switches 4-7 will be speed and rearward direction.
//The choice of a switch with active high will result in the appropriate duty
//cycle as well as the appropriate output values to the L298 Bridge to indicate 
//motor selection as well as motor speed and direction. Version 1.0
//-----------------------------------------------------------------------------

module Basys3 (clk,sw0,sw1,sw2,sw3,/*sw4,sw5,sw6,sw7,*/JC0,JC1,JC2/*,JC7,JC8,C9*/);

//Inputs
input clk; //100Mhz Oscillator BASYS_3 Pin:W5
input sw1;
input sw2;
input sw3;
//input sw4;
//input sw5;
//input sw6;
//input sw7;

//Outputs to Motor-A
output reg JC0; // Direction Control Pin:K17
output reg JC1; // Direction Control Pin:M18
output reg JC2; // PWM_OUT(Speed Control) Pin:N17

//Outputs to Motor-B
//output reg JC7; // Direction Control Pin:L17
//output reg JC8; // Direction Control Pin:M19
//output reg JC9; // PWM_OUT(Speed Control) Pin:P17

//Pulse Width Modulation variable initialization
reg [29:0] counter = 0;
reg [29:0] pulse_width = 0;

always @(posedge clk) begin
    if (counter < pulse_width) begin
        JC2 <= 1'b1;
    end else begin
        JC2 <= 1'b0;
    end
    counter <= counter+1;
end

//Changes the pulse width depending on the value of pulse_width
//which is obtained by polling switches 0-7.
//Switches 0-3 are forward direction @variable pulse_width; switches 4-7 are reverse direction
//@ variable pulse_width.

always @(sw0,sw1,sw2,sw3) begin
        
    pulse_width <= 0; //Speed Change Cutoff if SW's value is logic low;    
    JC0 <= 1'b1; //Forward Direction Input 1
    JC1 <= 1'b0; //Forward Direction Input 2

    if (sw0 == 1) begin
        pulse_width <= 100; 
    end 

    if (sw1 == 1) begin
        pulse_width <= 75;
    end

    if (sw2 == 1) begin
        pulse_width <= 50;
    end

    if (sw3 == 1) begin
        pulse_width <= 25;
    end

end

/*always @(sw4,sw5,sw6,sw7) begin
  
    pulse_width <= 0; //Speed Change Cutoff if SW's value is logic low;
    JC0 = 1'b0; //Reverse Direction Input 1
    JC1 = 1'b1; //Reverse Direction Input 2

    if (sw4 == 1) begin
        pulse_width <= 100; 
    end

    if (sw5 == 1) begin
        pulse_width <= 75;
    end

    if (sw6 == 1) begin
        pulse_width <= 50;
    end

end
*/

endmodule