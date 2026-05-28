//Shomik Sen. Kavin Sundar
//This is the top level testbench for the whole system which simulates the cars entering and exiting
module DE1_SoC_tb();	
	 logic         CLOCK_50; 	
	 logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 		
	 logic  [9:0]  LEDR; 		
	 logic  [3:0]  KEY;
	 logic  [9:0]  SW; 
	 wire [35:0] V_GPIO;
    

    logic enter, exit;
    assign V_GPIO[24] = enter;
    assign V_GPIO[25] = exit;

   
    DE1_SoC dut (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, V_GPIO);	
        
    // Clock setup
    parameter CLOCK_PERIOD=100;	
    initial begin	
        CLOCK_50 <= 0;	
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end	
        
    // 3. The 20-car sequence
    initial begin
        // Initialize inputs
        enter = 0; exit = 0;
        

        // toggle reset
        SW[9] = 1; @(posedge CLOCK_50);
        SW[9] = 0; @(posedge CLOCK_50);
        repeat(5) @(posedge CLOCK_50);

        //simulate 20 cars entering 
        repeat(20) begin
            enter = 1; exit = 0; @(posedge CLOCK_50); // Hit outer
            enter = 1; exit = 1; @(posedge CLOCK_50); // Hit both
            enter = 0; exit = 1; @(posedge CLOCK_50); // Leave outer
            enter = 0; exit = 0; @(posedge CLOCK_50); // Car is gone
            repeat(2) @(posedge CLOCK_50); // gap between cars
        end

        repeat(5) @(posedge CLOCK_50); //wait a bit before leaving

        //simulate 20 cars exiting
        repeat(20) begin
            exit = 1; enter = 0; @(posedge CLOCK_50); // Hit inner
            exit = 1; enter = 1; @(posedge CLOCK_50); // Hit both
            exit = 0; enter = 1; @(posedge CLOCK_50); // Leave inner
            exit = 0; enter = 0; @(posedge CLOCK_50); // car is gone
            repeat(2) @(posedge CLOCK_50);
        end

        $stop;
    end
endmodule