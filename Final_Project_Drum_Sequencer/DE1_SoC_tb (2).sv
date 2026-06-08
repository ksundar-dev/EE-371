//Shomik Sen, Kavin Sunder
//This is our master top-level testbench module for DE1_SoC
`timescale 1 ps / 1 ps
module DE1_SoC_tb();

	// Clock inputs
	logic CLOCK_50;
	logic CLOCK2_50;
	
	// Peripheral board I/O lines
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	// Video output wires
	logic [7:0] VGA_R, VGA_G, VGA_B;
	logic       VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	
	// Audio CODEC hardware interfaces
	logic       FPGA_I2C_SCLK;
	wire        FPGA_I2C_SDAT;
	logic       AUD_XCK;
	logic       AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	logic       AUD_ADCDAT;
	logic       AUD_DACDAT;
	
	// Instantiate the master design under test
	DE1_SoC dut (.*);
	
	// Clock generation
	parameter CLOCK_PERIOD = 100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle master clock
	end
	
	//Audio Clock
	initial begin
		CLOCK2_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK2_50 <= ~CLOCK2_50;
	end

	assign FPGA_I2C_SDAT = 1'bz;

	initial begin 
		
		// Initialize everything
		SW = 10'b0;
		KEY = 4'b1111; 
		AUD_BCLK = 0; AUD_ADCLRCK = 0; AUD_DACLRCK = 0; AUD_ADCDAT = 0;
		
		// Toggle reset
		SW[9] <= 1; @(posedge CLOCK_50);
		SW[9] <= 0; @(posedge CLOCK_50);
		
		//clear everything in the clear state
		force dut.clear_x = 10'd639;
		force dut.clear_y = 9'd479;
		@(posedge CLOCK_50);
		release dut.clear_x;
		release dut.clear_y;
		
		//Go to the S_Draw state and finish drawing
		force dut.grid_idx = 7'd63;
		force dut.sq_done = 1'b1;
		@(posedge CLOCK_50);
		release dut.grid_idx;
		release dut.sq_done;
		
		//Playhead drawing 
		repeat (10) @(posedge CLOCK_50);
		
		//press the key and see that it is changed
		KEY[3] <= 1'b0; @(posedge CLOCK_50);
		KEY[3] <= 1'b1; // Release key immediately 
		
		// wait for S_Setup_NOTE
		@(posedge CLOCK_50);
		
		// S_Mark_NOTE
		@(posedge CLOCK_50);
		
		// Finish it
		force dut.mark_done = 1'b1;
		@(posedge CLOCK_50);
		release dut.mark_done;
		
		// Go back to the playback and see it moving 
		repeat (10) @(posedge CLOCK_50);
		
		$stop;
	end
endmodule