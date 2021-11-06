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

//bridge to indicate motor selection as well. Version 3.0                       |

//------------------------------------------------------------------------------|

 

module Basys3 (clk,sw0,sw1,sw2,sw3,sw4,sw5,sw6,sw7,sw16,JC0,JC1,JC2,JC3,JC7,JC8,JC9,currentSenseB,

              a,b,c,d,e,f,g,dp,an0,an1,an2,an3,trig,echo,JA3,JA4,JA7,JA8,JA9);

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

 

//Seven Segment Display Outputs

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

 

//Ultra Sonic Sensor Output

output reg trig;

 

//Software overcurrent protection

input JC3;    //Current Protect for Motor A Pin: P18

input currentSenseB;    //Current Protect for Motor B Pin: JC9

 

//Distance Finder Variables

input echo;

 

//IPS Sensors

//input JA3;

//input JA4;

//input JA7;

 

//----------------------------------------------------------------------------

//Registers                                                                  |

//----------------------------------------------------------------------------

 

//Pulse Width Modulation variable initialization

reg [18:0] counter_1 = 0;

reg [18:0] pulse_width = 0;

 

//Direction enable

reg enable_dir = 1;

 

//Overcurrent Protection

reg turnOff = 0;

reg [20:0] counterCurrentA,counterCurrentB,counterCurrent_limit;

 

//Seven segment variables

reg [19:0] refresh_counter;

 

//Over Current Protection variables

reg counter2;

reg read_current;

//---------------------------------------------------------------------------
//Pulse_width modulation                                                    |
//---------------------------------------------------------------------------
reg enable_motora = 1;
reg enable_motorb = 1;

always @(posedge clk) begin

    if(counter_1 >= 249999) begin // 400hz carrier signal

        counter_1 <= 0;

    end else begin

        counter_1 <= counter_1+1;

    end

    if (counter_1 < pulse_width) begin

        if(enable_motora == 1) begin

        JC2 = 1'b1;

        end

        if(enable_motorb == 1) begin

        JC9 = 1'b1;

        end

    end else begin

        JC2 = 1'b0;

        JC9 = 1'b0;

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
/*
always @(*) begin

    case(LED_activating_counter)

    2'b00: begin

        an0 = 1'b0; //Activates Anode_1
        an1 = 1'b1;
        an2 = 1'b1;
        an3 = 1'b1;

        if (OCP == 0) begin

        a <= 1'b0; // Displays a "O"
        b <= 1'b0;
        c <= 1'b0;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;

        end

        if (OCP == 1) begin

        a <= 1'b1; // Display an "I"
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;  

        end

    end

    2'b01: begin

        an0 = 1'b1; // Activates Anode_2
        an1 = 1'b0;
        an2 = 1'b1;
        an3 = 1'b1;

        if (OCP == 0) begin

        a <= 1'b1; // Displays an 'L'
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;

        end

        if (OCP == 1) begin

        a <= 1'b1; // Displays an 'H'
        b <= 1'b0;
        c <= 1'b0;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b0;

        end

    end

    2'b10: begin

        an0 = 1'b1; // Activates Anode_3
        an1 = 1'b1;
        an2 = 1'b0;
        an3 = 1'b1;

        a <= 1'b1; // Displays a '-'
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b1;
        f <= 1'b1;
        g <= 1'b0;

    end

    2'b11: begin

        an0 = 1'b1; //Activates Anode_4
        an1 = 1'b1;
        an2 = 1'b1;
        an3 = 1'b0;

        if (enable_dir == 1) begin

        a <= 1'b0; //Displays an 'F'
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b0;

        end

        if (enable_dir == 0) begin

        a <= 1'b0; //Displays and 'R'
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;

        end

    end

    default: begin

        an0 = 1'b0; //Activates Anode_1
        an1 = 1'b1;
        an2 = 1'b1;
        an2 = 1'b1;

    end

    endcase
*/

//Temporary Registers for Ethans Color Sensor Input
reg Is_Blue  = 1'b1;
reg Is_Red   = 1'b1;
reg Is_Green = 1'b1;

always @(*) begin

    case(LED_activating_counter)

    2'b00: begin

        an0 = 1'b0; //Activates Anode_1
        an1 = 1'b1;
        an2 = 1'b1;
        an3 = 1'b1;

        if (OCP != 1 && Is_Blue) begin

        a <= 1'b0; // Displays a "E"
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b0;

        end

        if(OCP != 1 && Is_Red) begin

        a <= 1'b1; // Displays a 'd'
        b <= 1'b0;
        c <= 1'b0;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b1;
        g <= 1'b0; 

        end

        if(OCP != 1 && Is_Green) begin
          
        a <= 1'b1; // Displays a 'n'
        b <= 1'b1;
        c <= 1'b0;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b1;
        g <= 1'b0;

        end

        if (OCP == 1) begin

        a <= 1'b1; // Display an "I"
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;  

        end

    end

    2'b01: begin

        an0 = 1'b1; // Activates Anode_2
        an1 = 1'b0;
        an2 = 1'b1;
        an3 = 1'b1;

        if (OCP != 1 && Is_Blue) begin

        a <= 1'b1; // Displays an 'U'
        b <= 1'b0;
        c <= 1'b0;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;

        end

        if (OCP != 1 && Is_Red) begin
          
        a <= 1'b0; //Displays a 'E'
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b0;
    
        end

        if (OCP != 1 && Is_Green) begin
          
        a <= 1'b0;  // Displays a 'r'
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;

        end

        if (OCP == 1) begin

        a <= 1'b1; // Displays an 'H'
        b <= 1'b0;
        c <= 1'b0;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b0;

        end

    end

    2'b10: begin

        an0 = 1'b1; // Activates Anode_3
        an1 = 1'b1;
        an2 = 1'b0;
        an3 = 1'b1;

        if(OCP != 1 && Is_Blue) begin

        a <= 1'b1; // Displays a 'L'
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;

        end

        if(OCP != 1 && Is_Red) begin
            
        a <= 1'b0;  // Displays a 'r'
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b1;

        end

        if(OCP != 1 && Is_Green) begin
          
        a <= 1'b0; // Displays a 'g'
        b <= 1'b1;
        c <= 1'b0;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b0; 

        end

        if(OCP == 1) begin

        a <= 1'b1; // Displays a '-'
        b <= 1'b1;
        C <= 1'b1;
        d <= 1'b1;
        e <= 1'b1;
        f <= 1'b1;
        g <= 1'b0;  

        end

    end

    2'b11: begin

        an0 = 1'b1; //Activates Anode_4
        an1 = 1'b1;
        an2 = 1'b1;
        an3 = 1'b0;

        if (OCP != 1 && Is_Blue) begin

        a <= 1'b1; //Displays an 'b'
        b <= 1'b1;
        c <= 1'b0;
        d <= 1'b0;
        e <= 1'b0;
        f <= 1'b0;
        g <= 1'b0;

        end

        if(OCP != 1 && Is_Red) begin
            
        a <= 1'b1; // Display is off
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b1;
        f <= 1'b1;
        g <= 1'b1;

        end

        if(OCP != 1 && Is_Green) begin
          
        a <= 1'b1; // Display is off
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b1;
        f <= 1'b1;
        g <= 1'b1; 

        end

        if (OCP == 1) begin

        a <= 1'b1; //Displays and '-'
        b <= 1'b1;
        c <= 1'b1;
        d <= 1'b1;
        e <= 1'b1;
        f <= 1'b1;
        g <= 1'b0;

        end

    end

    default: begin

        an0 = 1'b0; //Activates Anode_1
        an1 = 1'b1;
        an2 = 1'b1;
        an2 = 1'b1;

    end

    endcase

end

//----------------------------|
//Over Current Implimentation |
//------------------ ---------|

//----------------------------------------------|
//When the current to either motor exceeds 1A   |
//ENA and ENB are disabled to protect the motor |
//from over current surge                       |
//----------------------------------------------|

//Wires
wire OCP;

always @(posedge clk) begin

     if (counter2 >= 1_666_666) begin

         counter2 <= 0;

         read_current <= 1'b1; 

     end else begin

         counter2 <= counter2 +1;

         read_current <= 1'b0; 

     end

end

assign OCP = JC3; 

//-----------------------------------|

//Ultra Sonic Sensor Implementation--|

//-----------------------------------|

reg [27:0] listen_delay;
reg [27:0] trig_delay = 0;
reg [22:0] up_timer = 0;
reg [27:0] wait_timer = 0;
reg [23:0] listen_limit = 3802000; //3802000
reg [1:0] state = 2'b00;
reg [1:0] state_neg = 2'b00;

if(sw16 != 0) begin

always @(posedge clk)

begin

        case(state)

        2'b00: begin

               trig <= 1'b1;
               if(trig_delay < 1000) begin
                    trig_delay = trig_delay +1; 
               end else begin

                    state = 2'b01;

               end

               end //End Case 1

        2'b01: begin

               trig <= 1'b0;
               trig_delay <= 0;
               state <= 2'b00;
               end //End Case 2

        endcase

end

always @(negedge clk) begin

        case(state_neg)

        2'b00:  begin

                if(echo == 1'b1) begin
                    up_timer <= up_timer +1;       
                end else if (up_timer < 3802000) begin

                if(up_timer < 292462 || Is_Red) begin
                   pulse_width <= 0;
                end 

                if(Is_Blue) begin
                    pulse_width <= 125000;  
                end

                if(Is_Green) begin
                    pulse_width <= 250000;
                end else begin // To be deleted after testing color sensor and IPS Final (Else)
                   pulse_width <= 250000;
                end

                up_timer  <= 0;
                state_neg <= 2'b01;

                end

                end 

        2'b01:  begin

                if (listen_delay <= 100_000_000) begin
                    listen_delay <= listen_delay +1; 
                end else begin
                    state_neg <= 2'b00;
                end

                end

        endcase
end
end // End sw16 master clause

/*Inductive Proximity Sensor*/


input JA3;                  //Middle Sensor
input JA4;                  //Right Sensor
input JA7;                  //Left Sensor
input JA8;                  //Further Right Sensor
input JA9;                  //Further Left Sensor

reg rst_in = 1'b1;
reg forward;
reg nav_straight;
reg ninety_right;
reg ninety_left;
reg curr_state;
reg [8:0] prepare = 0;

always @(posedge clk) begin

    if (rst_in == 1'b1) begin

                if (JA3 && JA4 && JA7)begin

                    enable_motora <= 1'b0;
                    enable_motorb <= 1'b0;
                end else if (~JA3)begin

                            enable_motora <= 1;
                            enable_motorb <= 1;

                            JC0 <= 1'b0; //Forward Direction Motor A (left)
                            JC1 <= 1'b1;
                            JC7 <= 1'b1; //Forward Direction Motor B (right)
                            JC8 <= 1'b0; 

                        end

                if (~JA7)begin  //Left Sensor

                    JC0 <= 1'b1; //Reverse Direction Motor A
                    JC1 <= 1'b1;
                    JC7 <= 1'b0; //Forward Direction Motor B
                    JC8 <= 1'b0; 

                end

                if (~JA4) begin  //Right Sensor

                        JC0 <= 1'b0;     //Forward Direction Motor A
                        JC1 <= 1'b0;
                        JC7 <= 1'b1;     //Reverse Direction Motor B
                        JC8 <= 1'b1; 

                end

                /*if (~JA9)begin                         //Further Left Sensor
                    prepare = prepare + 1;
                if (prepare == 2)begin
                    enable_motora <= 1'b0;
                    JC7 <= 1'b1;                  //Forward Direction Motor B (right)
                    JC8 <= 1'b0; 
                    prepare <= 1'b0;
                end

                end

                if (~JA8)begin 
                    prepare = prepare + 1;
                    if (prepare == 2)begin

                        enable_motora <= 1'b1; 
                        JC0 <= 1'b1;                 //Forward Direction Motor A (left)
                        JC1 <= 1'b0;
                        JC7 <= 1'b1;                //Forward Direction Motor B (right)
                        JC8 <= 1'b0; 
            
                    end
                end
        
                if (~JA8)begin                     //Further Right Sensor

                    prepare = prepare + 1;

                if (prepare == 2)begin

                    enable_motorb <= 1'b0;
                    JC0 <= 1'b0;               //Forward Direction Motor A
                    JC1 <= 1'b0;   
                    prepare <= 1'b0;
                end

                end

                if (~JA9)begin                    //Further Left Sensor      
                    prepare = prepare + 1;
                if (prepare == 2)begin

                    enable_motorb <= 1'b1; 
                    JC0 <= 1'b1;             //Forward Direction Motor A (left)
                    JC1 <= 1'b0;
                    JC7 <= 1'b1;            //Forward Direction Motor B (right)
                    JC8 <= 1'b0;
                end

                end
            */
    end 
end

endmodule