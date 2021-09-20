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

module Basys3 (clk,sw0,sw1,sw2,sw3,sw4,sw5,sw6,sw7,sw16,JC0,JC1,JC2,JC7,JC8,JC9,currentSenseA,currentSenseB,
              a,b,c,d,e,f,g,dp,an0,an1,an2,an3);
//----------------------------------------------------------------------------
//Inputs                                                                     |
//----------------------------------------------------------------------------
input clk; //100Mhz Oscillator BASYS_3 Pin:W5

//Switches
input sw0;  //Forward 100% duty cycle
input sw1;  //Forward 75%  duty cycle
input sw2;  //Forward 50%  duty cycle
input sw3;  //Forward 25%  duty cycle
input sw4;  //Reverse 100% duty cycle
input sw5;  //Reverse 75%  duty cycle
input sw6;  //Reverse 50%  duty cycle
input sw7;  //Reverse 25%  duty cycle
input sw16; //Current Shut off Reset

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

//Wires
wire [1:0] LED_activating_counter;

//Seven Segment Display
output reg a;
output reg b;
output reg c;
output reg d;
output reg e;
output reg f;
output reg g;
output reg dp;
output reg an0;
output reg an1;
output reg an2;
output reg an3;

//Software overcurrent protection
output currentSenseA;    //Current Protect for Motor A Pin: JC3
output currentSenseB;    //Current Protect for Motor B Pin: JC9

//----------------------------------------------------------------------------
//Registers                                                                  |
//----------------------------------------------------------------------------

//Pulse Width Modulation variable initialization
reg [11:0] counter_1 = 0;
reg [11:0] pulse_width = 0;

//Direction enable
reg enable_dir = 1;

//Overcurrent Protection 
reg turnOff;
reg [20:0] counterCurrentA,counterCurrentB,counterCurrent_limit;

//Seven segment variables
reg [19:0] refresh_counter;

//---------------------------------------------------------------------------
//Pulse_width modulation                                                    |
//---------------------------------------------------------------------------
always @(posedge clk) begin
    
    if(counter_1 >= 2499) begin // 400hz carrier signal
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

        pulse_width <= 2500;
        enable_dir <= 1;

    end 

    if (sw1 == 1) begin

        pulse_width <= 1875;
        enable_dir <= 1;

    end

    if (sw2 == 1) begin

        pulse_width <= 1250;
        enable_dir <= 1;

    end 

    if (sw3 == 1) begin

        pulse_width <= 625;
        enable_dir <= 1;

    end
    
    if (sw4 == 1) begin

        pulse_width <= 2500;
        enable_dir <= 0;
    
    end 

    if (sw5 == 1) begin

        pulse_width <= 1875;
        enable_dir <= 0;

    end 

    if (sw6 == 1) begin

        pulse_width <= 1250;
        enable_dir <= 0;

    end 

    if (sw7 == 1) begin

        pulse_width <= 625;
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

    //Over Current Reset
    if (sw16 == 1) begin
       turnOff <= 1;  
    end

    end

    if (turnOff == 0) begin
        pulse_width <= 0;  
    end
end

//-------------------------------------|
//Seven Segment Display Implementation |
//-------------------------------------|
always @(posedge clk) begin
     if (refresh_counter >= 1_666_666) begin //60hz clock for seven-seg
         refresh_counter <= 0;  
     end else begin
         refresh_counter <= refresh_counter +1;  
     end
end     
assign LED_activating_counter = refresh_counter[19:18];

always @(*) begin
    case(LED_activating_counter)
    2'b00: begin
        an0 = 1'b0;
        an1 = 1'b1;
        an2 = 1'b1;
        an3 = 1'b1;

        if (turnOff == 1) begin
        a <= 1'b0;
        b <= 1'b0;
        c <= 1'b0;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;
        end

    end
        
    2'b01: begin
        an0 = 1'b1;
        an1 = 1'b0;
        an2 = 1'b1;
        an3 = 1'b1;

        if (turnOff == 1) begin
        a <= 1'b1;
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;
        end

    end
    2'b10: begin
        an0 = 1'b1;
        an1 = 1'b1;
        an2 = 1'b0;
        an3 = 1'b1;

        a <= 1'b1;
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b1;
        f <= 1'b1;
        g <= 1'b0; 
        
    end
    2'b11: begin
        an0 = 1'b1;
        an1 = 1'b1;
        an2 = 1'b1;
        an3 = 1'b0;
 
        if (enable_dir == 1) begin 
        a <= 1'b0;
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b0;
        end

        if (enable_dir == 0) begin
        a <= 1'b0;
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;
        end 
    end

    default: begin
        an0 = 1'b0;
        an1 = 1'b1;
        an2 = 1'b1;
        an2 = 1'b1;
    end
    endcase 

end
//----------------------------|
//Over Current Implimentation |
//------------------ ----------|
//----------------------------------------------|
//When the current to either motor exceeds 1A   |
//ENA and ENB are disabled to protect the motor |
//from over current surge                       |
//----------------------------------------------|
initial begin

    counterCurrentA = 12'd0;
    counterCurrentB = 12'd0;
    counterCurrent_limit = 12'd2499;
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