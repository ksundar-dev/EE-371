module carSensor_tb();

    logic outer, inner, clk, reset;
    logic enter, exit;

    carSensor cstb(.*);

    // Set up a simulated clock
    parameter CLOCK_PERIOD = 100;    
    initial begin    
        clk <= 0;    
        forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
    end    

    initial begin
        // Initialize sensors and toggle reset
        outer = 0; inner = 0;
        reset = 1; @(posedge clk);
        reset = 0; @(posedge clk);
			
		//test three cars entering	
       
        repeat(3) begin
            
            @(posedge clk);
            outer = 1; inner = 0; @(posedge clk);
           
            
            outer = 1; inner = 1;  @(posedge clk);
            
            outer = 0; inner = 1;  @(posedge clk);
            
            outer = 0; inner = 0;  @(posedge clk);
            repeat(2) @(posedge clk); 
        end
		
		//test two cars leaving
        
        repeat(2) begin

            @(posedge clk);
            outer = 0; inner = 1;  @(posedge clk);
            
            outer = 1; inner = 1; @(posedge clk);
            
            outer = 1; inner = 0;  @(posedge clk);
            
            outer = 0; inner = 0;  @(posedge clk);
            repeat(2) @(posedge clk);
        end
		  
		  //test ifa car enters and stays at the first sensor 4 times
		  outer = 1; inner = 0; @(posedge clk);
		                        @(posedge clk);
										@(posedge clk);
										@(posedge clk);
										
		  //toggle reset at the same time as entering 
        @(posedge clk);
        outer = 1; 
        @(posedge clk);
        reset = 1; 
        @(posedge clk);
        reset = 0;
        outer = 0;

        #500;
        $stop;
    end
endmodule