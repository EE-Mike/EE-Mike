//Project Lab 1 Verilog Code
//Michael Salas, Ethan Nguyen, Bryanna Perales, Cristian Rivera
//Texas Tech University
//ECE-3331-301
//V1.3
//The verilog code will control the average voltage out of the PWR pin on
//PMOD JC in order to control the speed of an attached motor. Switches 0-7
//will be the controls for the variable duty cycle. Switches 0-3 will be speed
//and forward direction. Switches 4-7 will be speed and rearward direction.
//The choice of a switch with active high will result in the appropriate duty
//cycle as well as the appropriate output values to the L298 Bridge to indicate 
//motor selection as well as motor speed and direction. Version 1.0

module Basys3 (W5,K17,M18,N17,P18,PWR,GND);

//Inputs
input W5; //100Mhz Oscillator BASYS_3

//Outputs to Motor-A
output reg K17;
output reg M18;
output reg N17;
output reg P18;
output reg PWR;
output reg GND = 0;

//registers
reg sw0;
reg sw1;
reg sw2;
reg sw3;
reg sw4;
reg sw5;
reg sw6;
reg sw7;
reg [7:0] counter = 0;

//Pulse_Width initialization to 0
reg [7:0] pulse_width = 0;

always @(posedge W5) begin
    if (counter < pulse_width) begin
        PWR <= 1'b1;
    end else begin
        PWR <= 1'b0;
    end
    counter <= counter+1;
    //changes pulse width depending on the value of pulse_width
    //which is obtained by polling switches 0-7 for 25%/50%/75%/100%
    //duty cycle.

    //Switches 0-3 are forward direction; switches 4-7 are reverse direction
    //NEEDS PIN ASSIGNMENTS FOR MOTOR DIRECTION AND MOTOR SELECTION//
    
    case(sw0)

        1'b1: begin 
              pulse_width <= 100; //100% duty @ 3.3V Forward
              K17 <= 1'b1;
              M18 <= 1'b0;
              counter <= 0; 
              end
        default : pulse_width <= 0;    //0% duty @ 0.0V
    endcase

    case(sw1)

        1'b1: begin 
              pulse_width <= 75; //100% duty @ 2.475V Forward
              K17 <= 1'b1;
              M18 <= 1'b0;
              counter <= 0; 
              end
        default : pulse_width <= 0;    //0% duty @ 0.0V
    endcase

    case(sw2)

        1'b1: begin 
              pulse_width <= 50; //100% duty @ 1.65V Forward
              K17 <= 1'b1;
              M18 <= 1'b0;
              counter <= 0; 
              end
        default : pulse_width <= 0;    //0% duty @ 0.0V
    endcase

    case(sw3)

        1'b1: begin 
              pulse_width <= 25; //100% duty @0.825V Forward
              K17 <= 1'b1;
              M18 <= 1'b0;
              counter <= 0;
              end
        default : pulse_width <= 0;    //0% duty @ 0.0V 
    endcase

    case(sw4)

        1'b1: begin 
              pulse_width <= 100; //100% duty @ 3.3V Reverse
              K17 <= 1'b0;
              M18 <= 1'b1;
              counter <= 0; 
              end
        default : pulse_width <= 0;    //0% duty @ 0.0V
    endcase

    case(sw5)

        1'b1: begin 
              pulse_width <= 75; //75% duty @ 2.475V Reverse
              K17 <= 1'b0;
              M18 <= 1'b1;
              counter <= 0; 
              end
        default : pulse_width <= 0;    //0% duty @ 0.0V
    endcase

    case(sw6)

        1'b1: begin 
              pulse_width <= 50; //50% duty @ 1.65V Reverse
              K17 <= 1'b0;
              M18 <= 1'b1;
              counter <= 0; 
              end
        default : pulse_width <= 0;    //0% duty @ 0.0V
    endcase

    case(sw7)

        1'b1: begin 
              pulse_width <= 25; //25% duty @ 0.825V Reverse
              K17 <= 1'b0;
              M18 <= 1'b1;
              counter <= 0; 
              end
        default : pulse_width <= 0;    //0% duty @ 0.0V
    endcase

end

endmodule