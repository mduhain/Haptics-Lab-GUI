// Pump_Control
//
// @mduhain, June 25 2021
//
// - For controling the fluid pumps with Pulse-Width Modulation (PWM) in microseconds
// - PWM range is between, 910 (fully retracted) and 2090 (fully extended).
//
//
// PUMP CONTROL v3.0
//
// <@mduhain July 26th, 2021>
// - creating a new version of pump control for the Rig GUI
// - the goal of this new version is the ability to present and withdraw a droplet  < 1 sec
// + added section for debugging <manual override>
//
//Instructions for Manual Override
// Input these as single characters into the serial input (top right corner)
//  "1" = moves motor 1 forward one step
//  "2" = moves motor 1 reverse one step.
//  "3" = moves motor 1 home.
//  "q" = moves motor 2 forward one step.
//  "w" = moves motor 2 reverse one step.
//  "e" = moves motor 2 home.
//  "h" = moves both motors home.
//
// <@mduhain July 28th, 2021>
//  + fixed a bug where multiple rewards were being delivered from one signal.
//  + fixed a bug where reward values were not being updated properly.
//
//-------------------------------------------------------------------------------------------------

// STEP (REWARD) SIZE
int step_size = 6;

//IMPORT LIBRARIES
#include <Servo.h>
#include <math.h>

// DECLARE SERVO MOTORS
Servo motor1;
Servo motor2;

// GPIO PIN ASSIGNMENTS
int PIN_input = 6; //pin input for forward motion motor 1 (M1) (5ms pulse = 1 reward)
int PIN_input_rev = 7; //pin input for reverse motion M1 (pulse = reverse 1 reward)
int PIN_code0 = 4; //first pin for encoding reward size in binary
int PIN_code1 = 5; //second pin for encoding reward size in binary
int PIN_M2_go = 26; //pin for moving the second motor (M2) forward (give juice), same logic as PIN_input
int PIN_M2_rev = 27; //Pin for reversing M2 (withdraw liquid), same logic as PIN_inout_rev

// VARIABLES
int current_step_1 = 910; //motor 1 current loactaion
int current_step_2 = 910; //motor 2 current location
int step_home = 910; //motor home location
int new_step_1 = 1500; //motor 1 new location
int new_step_2 = 1500; //motor 2 new location
int forwardValue1 = 0; //flag for M1 forward motion
int reverseValue1 = 0; //flag for M1 reverse motion
int forwardValue2 = 0; //flag for M2 forward motion
int reverseValue2 = 0; //flag for M2 reverse motion
int code0_val = 0; //flag for binary reward size code
int code1_val = 0; //flag for binary reward size code


//===================================================================================================
void setup() {  
  // Set GPIO pin for controling motors via PWM
  motor1.attach(2);
  motor2.attach(3);  
  
  // Start collecting serial keyboard input data
  Serial.begin(9600);  
  
  // Set both motors to home position (910) fully retracted
  motor1.writeMicroseconds(910); //move home
  motor2.writeMicroseconds(910); //move home
}

//=====================================================================================================
void loop() {
  //-----------------------------------------------------
  //CHECK GPIO PINS
  forwardValue1 = digitalRead(PIN_input);
  reverseValue1 = digitalRead(PIN_input_rev);
  forwardValue2 = digitalRead(PIN_M2_go);
  reverseValue2 = digitalRead(PIN_M2_rev);
  code0_val     = digitalRead(PIN_code0);
  code1_val     = digitalRead(PIN_code1);


  //----------------------------------------------------------
  // ENCODING NEW REWARD VALUE
    if (code0_val == 0 && code1_val == 1){
      //Increase step size by 1
      step_size = step_size + 1;
      Serial.println("Increasing Step Size...");
      Serial.println(step_size);
      delay(15);
    }
    else if (code0_val == 1 && code1_val == 0){
      //Decrease step size by 1
      step_size = step_size - 1;
      Serial.println("Decreasing step size...");
      Serial.println(step_size);
      delay(15);
    }


  
  //------------------------------------------------------
  //SERIAL INPUT FOR MANUAL OVERRIDE
  if(Serial.available() > 0){
    char ctrl = Serial.read();
    if (ctrl == '1'){
      //one
      Serial.println("Motor 1 forward...");
      new_step_1 = current_step_1 + (step_size/2);
      Serial.println(new_step_1);
      motor1.writeMicroseconds(new_step_1);
      current_step_1 = new_step_1;
      delay(100);
      //two
      Serial.println("Motor 1 forward...");
      new_step_1 = current_step_1 + (step_size/2);
      Serial.println(new_step_1);
      motor1.writeMicroseconds(new_step_1);
      current_step_1 = new_step_1;
      delay(500);
    } 
    else if (ctrl == '2'){
      //one
      Serial.println("Motor 1 Retracting...");
      new_step_1 = current_step_1 - (step_size/2);
      Serial.println(new_step_1);
      motor1.writeMicroseconds(new_step_1);
      current_step_1 = new_step_1;
      delay(100);
      //two
      Serial.println("Motor 1 Retracting...");
      new_step_1 = current_step_1 - (step_size/2);
      Serial.println(new_step_1);
      motor1.writeMicroseconds(new_step_1);
      current_step_1 = new_step_1;
      delay(500);
    }          
    else if (ctrl == '3'){
      Serial.println("Motor 1 Returning Home...");
      motor1.writeMicroseconds(step_home);
      current_step_1 = step_home;
    }
    else if (ctrl == 'q'){
      Serial.println("Motor 2 forward...");
      new_step_2 = current_step_2 + step_size;
      Serial.println(new_step_2);
      motor2.writeMicroseconds(new_step_2);
      current_step_2 = new_step_2;
    } 
    else if (ctrl == 'w'){
      Serial.println("Motor 2 Retracting...");
      new_step_2 = current_step_2 - step_size;
      Serial.println(new_step_2);
      motor2.writeMicroseconds(new_step_2);
      current_step_2 = new_step_2;
    }          
    else if (ctrl == 'e'){
      Serial.println("Motor 2 Returning Home...");
      motor2.writeMicroseconds(step_home);
      current_step_2 = step_home;
    }
    else if (ctrl == "h"){
      Serial.println("All Motors Home...");
      motor1.writeMicroseconds(step_home);
      motor2.writeMicroseconds(step_home);
      current_step_1 = step_home;
      current_step_2 = step_home;
    }
  }

  
  //------------------------------------------------------------
  // GPIO MOTOR 1 CONTROL
  if (forwardValue1 == 1 && reverseValue1 == 0) {
    //one
    Serial.println("Motor 1 forward...");
    new_step_1 = current_step_1 + (step_size/2);
    Serial.println(new_step_1);
    motor1.writeMicroseconds(new_step_1);
    current_step_1 = new_step_1;
    delay(100);
    //two
    Serial.println("Motor 1 forward...");
    new_step_1 = current_step_1 + (step_size/2);
    Serial.println(new_step_1);
    motor1.writeMicroseconds(new_step_1);
    current_step_1 = new_step_1;
    delay(500);
  }
  if (forwardValue1 == 0 && reverseValue1 == 1) {
    //one
    Serial.println("Motor 1 Retracting...");
    new_step_1 = current_step_1 - (step_size/2);
    Serial.println(new_step_1);
    motor1.writeMicroseconds(new_step_1);
    current_step_1 = new_step_1;
    delay(100);
    //two
    Serial.println("Motor 1 Retracting...");
    new_step_1 = current_step_1 - (step_size/2);
    Serial.println(new_step_1);
    motor1.writeMicroseconds(new_step_1);
    current_step_1 = new_step_1;
    delay(500);
  }

  //------------------------------------------------------------
  // GPIO MOTOR 2 CONTROL
  if (forwardValue2 == 1 && reverseValue2 == 0) {
    Serial.println("Motor 2 forward...");
    new_step_2 = current_step_2 + step_size;
    Serial.println(new_step_2);
    motor2.writeMicroseconds(new_step_2);
    current_step_2 = new_step_2;
    delay(500);
  }
  if (forwardValue2 == 0 && reverseValue2 == 1) {
    Serial.println("Motor 2 Retracting...");
    new_step_2 = current_step_2 - step_size;
    Serial.println(new_step_2);
    motor2.writeMicroseconds(new_step_2);
    current_step_2 = new_step_2;
    delay(500);
  }


} //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
