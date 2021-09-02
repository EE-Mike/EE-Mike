//Project Lab 1 Verilog Code
//Michael Salas, Ethan Nguyen, Bryanna Perales, Cristian Rivera
//Texas Tech University
//ECE-3331-301
//V1.0
//The verilog code will control the average voltage out of the PWR pin on
//PMOD JC in order to control the speed of an attached motor. Switches 0-7
//will be the controls for the variable duty cycle. Switches 0-3 will be speed
//and forward direction. Switches 4-7 will be speed and rearward direction.
//The choice of a switch with active high will result in the appropriate duty
//cycle as well as the appropriate output values to the L298 Bridge to indicate 
//motor selection as well as motor speed and direction. Version 1.0

module Basys3 (v17,PWR);

//Inputs/switches 0-7 respectively
input v17;
input v16;
input w16;
input w17;
input w15;
input v15;
input w14;
input w13;

//pulse-width modulation variables
input [7:0] pulse_width;
input w5; //100Mhz Oscillator BASYS_3

//Outputs to Motor-A
output k17;
output m18;
output n17;
output p18;

output PWR;
output GND;

//Wires
wire k17;
wire m18;
wire n17;
wire p18;
wire PWR;
wire GND;

//registers
reg v17;
reg v16;
reg w16;
reg w17;
reg w15;
reg v15;
reg w14;
reg w13;
reg [7:0] counter = 0;

//pulse_width initialization *stop*
pulse_width = 0;

always (@posedge w5) begin
    if (counter < pulse_width) begin
        assign PWR = 1;
    end else begin
        assign PWR = 0;
    end
    counter <= counter+1;
    //changes pulse width depending on the value of pulse_width
    //which is obtained by polling switches 0-7 for 25%/50%/75%/100%
    //duty cycle.

    //Switches 0-3 are forward direction; switches 4-7 are reverse direction
    //NEEDS PIN ASSIGNMENTS FOR MOTOR DIRECTION AND MOTOR SELECTION//
    begin
        case(v17 or v16 or w16 or w17 or w15 or v15 or w14 or w13 or pulse_width)

            v17 = 1: pulse_width <= 100; //100% duty @ 3.3V
            v16 = 1; pulse_width <= 75;  //75% duty @ 2.475V 
            w16 = 1; pulse_width <= 50;  //50% duty @ 1.65V  
            w17 = 1; pulse_width <= 25;  //25% duty @ 0.825V 

            w15 = 1; pulse_width <= 100; //100% duty @ 3.3V
            v15 = 1; pulse_width <= 75;  //75% duty @ 2.475V
            w14 = 1; pulse_width <= 50;  //50% duty @ 1.65V
            w13 = 1; pulse_width <= 25;  //25% duty @ 0.825V

        default pulse_width <= 0;    //0% duty @ 0.0V
    end
    
end

end module