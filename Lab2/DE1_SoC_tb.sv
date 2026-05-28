//Kavin Sundar Shomik Sen
//4/17/2026
//Lab 2 Memory
//This is the testbench for the top level module 
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module DE1_SoC_tb();
	logic         CLOCK_50; // 50MHz clock.	
	logic[6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 		
	logic  [9:0]  LEDR; 		
	logic  [3:0]  KEY; // True when not pressed, False when pressed	
	logic  [9:0]  SW; 

	DE1_SoC #(.COUNT_MAX(2))dut(.*);
	
	
	parameter CLOCK_PERIOD=10;	
	initial begin	
		CLOCK_50 <= 0;	
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;	// Forever toggle the clock
	end	
	
	
	
	initial begin 
		
		//start with reading/writing to the task2 ram
		//toggle reset
		KEY[3] = 1; @(posedge CLOCK_50);
		KEY[3] = 0; @(posedge CLOCK_50);
		
		//change address to 16 and the data to 7 and write it to the address
		SW[9] = 0; SW[8:4] = 5'b10000; SW[3:1] = 3'b100;  SW[0] = 1;  repeat(5)@(posedge CLOCK_50);
																							
		
		//change address to 15 and the data to 4 and write it to the address
		SW[9] = 0; SW[8:4] = 5'd15; SW[3:1] = 3'd4;  SW[0] = 1;  repeat(5)@(posedge CLOCK_50);

																				
		//change address to 7 and the data to 2 and write it to the address
		SW[9] = 0; SW[8:4] = 5'd7; SW[3:1] = 3'd2;  SW[0] = 1;  repeat(5)@(posedge CLOCK_50);

																					
		
		//change address to 3 and the data to 5 and write it to the address
		SW[9] = 0; SW[8:4] = 5'd3; SW[3:1] = 3'd5;  SW[0] = 1;  repeat(5)@(posedge CLOCK_50);

																			
																				  
		//read the data from each address
		
		//change address to 16 and the data to 7 and write it to the address
		SW[9] = 0; SW[8:4] = 5'b10000;   SW[0] = 0; repeat(5)@(posedge CLOCK_50);
																						
		
		//change address to 15 and the data to 4 and write it to the address
		SW[9] = 0; SW[8:4] = 5'd15;   SW[0] = 0;  repeat(5)@(posedge CLOCK_50);

		
		//change address to 7 and the data to 2 and write it to the address
		SW[9] = 0; SW[8:4] = 5'd7;  SW[0] = 0;  repeat(5)@(posedge CLOCK_50);
																					
		
		//change address to 3 and the data to 5 and write it to the address
		SW[9] = 0; SW[8:4] = 5'd3;  SW[0] = 0; ;repeat(5)@(posedge CLOCK_50);

		//change the ram to task3s ram and do the same thing
		
				//change address to 16 and the data to 7 and write it to the address
		SW[9] = 1; SW[8:4] = 5'b10000; SW[3:1] = 3'b100;  SW[0] = 1;  repeat(5)@(posedge CLOCK_50);

																							
		
		//change address to 15 and the data to 4 and write it to the address
		SW[9] = 1; SW[8:4] = 5'd15; SW[3:1] = 3'd4;  SW[0] = 1;  repeat(5)@(posedge CLOCK_50);
																					
		
		//change address to 7 and the data to 2 and write it to the address
		SW[9] = 1; SW[8:4] = 5'd7; SW[3:1] = 3'd2;  SW[0] = 1;  repeat(5)@(posedge CLOCK_50);
																					
		//change address to 3 and the data to 5 and write it to the address
		SW[9] = 1; SW[8:4] = 5'd3; SW[3:1] = 3'd5;  SW[0] = 1;  repeat(5)@(posedge CLOCK_50);
		                                                       
		//read the data from each address
		
		//change address to 16 and the data to 7 and write it to the address
		SW[9] = 1; SW[8:4] = 5'b10000;   SW[0] = 0;  repeat(5)@(posedge CLOCK_50);
																							
		//change address to 15 and the data to 4 and write it to the address
		SW[9] = 1; SW[8:4] = 5'd15;   SW[0] = 0;  repeat(5)@(posedge CLOCK_50);
																					
		
		//change address to 7 and the data to 2 and write it to the address
		SW[9] = 1; SW[8:4] = 5'd7;  SW[0] = 0;  repeat(5)@(posedge CLOCK_50);
																					
		
		//change address to 3 and the data to 5 and write it to the address
		SW[9] = 1; SW[8:4] = 5'd3;  SW[0] = 0;  repeat(5)@(posedge CLOCK_50);
		                                                        
		//hold reset for a few pulses
		
		KEY[3] = 1;  repeat(5);repeat(5);@(posedge CLOCK_50);

		
		$stop;
	end
endmodule
		
		
		
	