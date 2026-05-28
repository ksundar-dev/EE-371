//Shomik Sen, Kavin Sundar
//This is our top level tesetbench that tests task1 and task2
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module DE1_SoC_tb();

    parameter N = 8;

    logic         CLOCK_50;
    logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic  [9:0]  LEDR;
    logic  [3:0]  KEY;
    logic  [9:0]  SW;

    DE1_SoC #(.N(N)) dut (
        .CLOCK_50(CLOCK_50),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .LEDR(LEDR),
        .KEY(KEY),
        .SW(SW)
    );

    parameter CLOCK_PERIOD = 100;

    initial begin
        CLOCK_50 = 0;

        forever #(CLOCK_PERIOD/2)
            CLOCK_50 = ~CLOCK_50;
    end

    initial begin
	 
		 // initialize everything and test Task1
		 KEY = 4'b1111;
		 SW  = 10'b0;
		 
		 //toggle reset
		 KEY[0] = 0;         @(posedge CLOCK_50);
		 KEY[0] = 1;         @(posedge CLOCK_50);
		 
		 //Set all switches high and the result should be 8
		 SW[7:0] = 8'b11111111;
		 repeat(3) @(posedge CLOCK_50);  // wait for load A
		 KEY[3] = 0;         @(posedge CLOCK_50);  // press start
		 KEY[3] = 1;         repeat(15) @(posedge CLOCK_50); //wait a bit for it to finish
		 
		 // toggle reset
		 KEY[0] = 0;         @(posedge CLOCK_50);
		 KEY[0] = 1;         @(posedge CLOCK_50);
		 
		 // set switches to alternating the result should be 4
		 SW[7:0] = 8'b10101010;
		 repeat(3) @(posedge CLOCK_50);
		 KEY[3] = 0;         @(posedge CLOCK_50);
		 KEY[3] = 1;         repeat(15) @(posedge CLOCK_50);
		 
		 
		 //set switch 9 to high to start testing task2 
		 SW[9] = 1; @(posedge CLOCK_50);
		 
		 
		 // toggle reset
		 KEY[0] = 0;         @(posedge CLOCK_50);
		 KEY[0] = 1;         @(posedge CLOCK_50);

			
		//check zero first
		 SW[7:0] = 8'd0;
		 repeat(5) @(posedge CLOCK_50);
		 KEY[3] = 0; @(posedge CLOCK_50); //start it
		 KEY[3] = 1; 
		 wait(LEDR[9]); //wait for the done signal
		 repeat(10) @(posedge CLOCK_50);
		
		
		//now check 15 to see if it works
		 SW[7:0] = 8'd15;
		 repeat(5) @(posedge CLOCK_50);
		 KEY[3] = 0; @(posedge CLOCK_50); //start it
		 KEY[3] = 1; 
		 wait(LEDR[9]); //wait for done
		 repeat(10) @(posedge CLOCK_50);

		 //check for 31 
		 SW[7:0] = 8'd31;
		 repeat(5) @(posedge CLOCK_50);
		 KEY[3] = 0; @(posedge CLOCK_50);  //start it
		 KEY[3] = 1; 
		 wait(LEDR[9]);                   //wait for done
		 repeat(10) @(posedge CLOCK_50);

		//check a value that is not in the ram and see what happens
		 SW[7:0] = 8'd255;
		 repeat(5) @(posedge CLOCK_50);
		 KEY[3] = 0; @(posedge CLOCK_50);  //start it
		 KEY[3] = 1; 
		 wait(LEDR[9]);  //wait for done
		 
		 repeat(20) @(posedge CLOCK_50);
		 $stop;
		end

endmodule