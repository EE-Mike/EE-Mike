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
//motor selection as well as motor speed and direction.

module Basys3 (v17,PWR);

//Inputs
input v17;
input v16;
input w16;
input w17;
input [7:0] pulse_width;
input w5;

//Output
output PWR;

//Wires
wire PWR;

//registers
reg v17;
reg [7:0] counter = 0;
reg PWR;

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
    //which is obtained by polling switches 0-3 for 25%/50%/75%/100%

    begin
        case(v17,v16,w16,w17)
        v17 = 1: pulse_width <= 100; //100% duty @ 3.3V
        v16 = 1; pulse_width <= 75;  //75% duty @ 2.475V
        w16 = 1; pulse_width <= 50;  //50% duty @ 1.65V
        w17 = 1; pulse_width <= 25;  //25% duty @ 0.825V
        default pulse_width <= 0;    //0% duty @ 0.0V
    end
    
end

end module