//Shomik, Kavin 
//Sound selector tesbench
`timescale 1 ps / 1 ps
module soundSelector_tb();

    logic        clk, reset, write_ready, switcher;
    logic        kickPlay, clapPlay, hhPlay, ohPlay;
    logic        write;
    logic [23:0] writedata_left, writedata_right;

    soundSelector dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    initial begin
        //initiliaze
        reset       <= 1;
        write_ready <= 0;
        switcher    <= 0;
        kickPlay    <= 0; clapPlay <= 0;
        hhPlay      <= 0; ohPlay   <= 0;
        @(posedge clk);
        reset <= 0; @(posedge clk);

        //No sounds/ write should stay 0
		  // Expected:write=0 throughout, writedata_left=0
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
      
        //Kick triggered — write goes high
		// Expected:write=1, kick_playing advancing
        kickPlay <= 1; @(posedge clk);
        kickPlay <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
       
        //Switcher cuts kick mid-sample
		  // Expected:write=0, kick stopped by switcher
        switcher <= 1; @(posedge clk);
        switcher <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
  
        // Re-trigger kick after switcher — restarts from 0
		  // Expected:write=1 again, addr restarted from 0
        kickPlay <= 1; @(posedge clk);
        kickPlay <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);


        // Cut it again cleanly(CLEAR)
        switcher <= 1; @(posedge clk);
        switcher <= 0; @(posedge clk);

        //Clap only
		  // Expected: write=1, clap_playing
        clapPlay <= 1; @(posedge clk);
        clapPlay <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);

			
        // Cut it again cleanly(CLEAR)
        switcher <= 1; @(posedge clk);
        switcher <= 0; @(posedge clk);

		   //HH only
		  // Expected: write=1, clap_playing
        hhPlay <= 1; @(posedge clk);
        hhPlay <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);


        switcher <= 1; @(posedge clk);
        switcher <= 0; @(posedge clk);

		   //OH only
		  // Expected: write=1, clap_playing
        ohPlay <= 1; @(posedge clk);
        ohPlay <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);

        switcher <= 1; @(posedge clk);
        switcher <= 0; @(posedge clk);

        // All four simultaneously
        // Expected:write=1, writedata is mixed/clipped sum
		// Expected: write=1, left==right
        kickPlay <= 1; clapPlay <= 1; hhPlay <= 1; ohPlay <= 1;
        @(posedge clk);
        kickPlay <= 0; clapPlay <= 0; hhPlay <= 0; ohPlay <= 0;
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
  

        switcher <= 1; @(posedge clk);
        switcher <= 0; @(posedge clk);


        //write_ready never asserted — addr must not advance
        // Expected:kick_playing=1 but write=0 since write_ready never high
        kickPlay <= 1; @(posedge clk);
        kickPlay <= 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);


        switcher <= 1; @(posedge clk);
        switcher <= 0; @(posedge clk);


        //Re-trigger mid-playback — addr resets to 0
        // Expected:addr back to 0, playing fresh from start
        kickPlay <= 1; @(posedge clk);
        kickPlay <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk); // advance a few
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        kickPlay <= 1; @(posedge clk);    // re-trigger mid-sample
        kickPlay <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);


        switcher <= 1; @(posedge clk);
        switcher <= 0; @(posedge clk);

        //Reset mid-playback — all cleared
		  // Expected: write=0, all cleared
        kickPlay <= 1; ohPlay <= 1;
        @(posedge clk);
        kickPlay <= 0; ohPlay <= 0;
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);



        //Switcher with all sounds playing
		  // Expected:write=0, all four stopped
        kickPlay <= 1; clapPlay <= 1; hhPlay <= 1; ohPlay <= 1;
        @(posedge clk);
        kickPlay <= 0; clapPlay <= 0; hhPlay <= 0; ohPlay <= 0;
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        switcher <= 1; @(posedge clk);   // cut all mid-play
        switcher <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);
        write_ready <= 1; @(posedge clk);
        write_ready <= 0; @(posedge clk);


        $stop;
    end

endmodule