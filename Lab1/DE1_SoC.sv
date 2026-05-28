//Shomik Sen, Kavin Sundar
//This is the top level module that connects all of the ports together. It brings all the modules to life and makes it so that
//the carSensor module communicates to the counter and seven segment displays to show how many cars are entering and exiting

module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, V_GPIO); 	
	input  logic         CLOCK_50; // 50MHz clock.	
	output logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 		
	output logic  [9:0]  LEDR; 		
	input  logic  [3:0]  KEY; // True when not pressed, False when pressed	
	input  logic  [9:0]  SW; 			
	inout wire [35:0] V_GPIO;
	
	GPIO_parking offboard(.V_GPIO(V_GPIO)); //inialize the offboard switches and LEDs
	
	
	logic increment_pressed; //wire to see if a car enters
	logic decrement_pressed; //wire to see if a car exits
	

	
	logic [4:0] total; //Number wire
	logic clear; //Wire to determine weather there are zero cars
	logic full; //Wire to determine 18 cars
	
	//initialize the counter module
	counter count(.incr(increment_pressed), .decr(decrement_pressed), .total(total), .clk(CLOCK_50), .reset(V_GPIO[10]), .clear(clear), .full(full));
	
	//initialize the carsensor module
	carSensor car(.enter(increment_pressed), .exit(decrement_pressed), .outer(V_GPIO[24]), .inner(V_GPIO[25]), .clk(CLOCK_50), .reset(V_GPIO[10]));
	
//initialize the sevenSegment display module	
	sevenSeg seg(.*);

	
		
endmodule
	



	





