//Kavin Sundar Shomik Sen
//4/17/2026
//Lab 2 Memory
//This is our top level module for Lab2. It is where the addresses counter and calling each module are located.
//We have a built in parameter for teh clock used to override so our testbench was mor eledgible. Outputs 
//are the specfic HEXs.
module DE1_SoC #(parameter COUNT_MAX = 550000)(CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW); 	
	input  logic         CLOCK_50; // 50MHz clock.	
	output logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 		
	output logic  [9:0]  LEDR; 		
	input  logic  [3:0]  KEY; // True when not pressed, False when pressed	
	input  logic  [9:0]  SW; 		

	//generate 1 second pulse for the counter module
	
	
	
	logic [4:0] addr;
	logic [2:0] dataOUT;
	logic reset;
	assign reset = KEY[3];
	
	logic [2:0] dataOUTport2;
	
	logic [2:0] dataOUTtask2;
	
	
	assign addr = SW[8:4];
	
	logic [2:0] data;
	assign data = SW[3:1];
	
	logic write;
	
	assign write = SW[0];
	
	//logic clock;
	
	//assign clock = ~KEY[0];
	
	logic [4:0] tens;
	logic [4:0] ones;
	
	always_comb begin 
		if (addr >= 30)begin 
			tens = 3;
			ones = addr - 30;
		end
		else if (addr>= 20)begin
			tens = 2;
			ones = addr - 20;
		end
		else if (addr>= 10)begin
			tens = 1;
			ones = addr - 10;
		end
		else begin
			tens = 0;
			ones = addr;
		end
	end
	
	//create the counter module
	logic [5:0] count;
	logic [5:0] countOutput;
	
	logic oneSec;
	
	one_sec_timer #(.COUNT_MAX(COUNT_MAX))oneSecond(.clk(CLOCK_50),.reset(reset), .oneSec(oneSec));
	
	always_ff @(posedge CLOCK_50) begin
		if(reset) begin
			count <= 6'd1;
			
		end
		else if (oneSec) begin
			count <= count + 1;		
			if (count >= 6'd33) begin
				count<=6'd1;
			end
		end
	end
	
	always_comb begin
		if (SW[9]) countOutput = count -1;
		else countOutput = addr;
	end
	
	//logic to display the counter address on HEX3-HEX2
	logic [4:0] tensCounter;
	logic [4:0] onesCounter;
	always_comb begin 
		if (count >= 31 && count <33)begin 
			tensCounter = 3;
			onesCounter = count - 31;
		end
		else if (count>= 21)begin
			tensCounter = 2;
			onesCounter = count - 21;
		end
		else if (count>= 11)begin
			tensCounter = 1;
			onesCounter = count - 11;
		end
		else begin
			tensCounter = 0;
			onesCounter = count-1;
		end
	end
	
	//toggles between task2 and task3 memory
	logic selector;
	assign selector = SW[9];

	//initialize the ram from task2 and task3
	ram32x3port2 ramPort2(.clock(CLOCK_50),.data(data),.rdaddress(countOutput),.wraddress(addr),.wren(write & selector),.q(dataOUTport2));
	task2 multiDIM(.clock(CLOCK_50), .address(addr), .data(data), .wren(write & ~selector),.q(dataOUTtask2));
	
	
	always_comb begin
		if(selector)
			dataOUT = dataOUTport2;
		else dataOUT = dataOUTtask2;
	end
	
	
	
	//displays the address from the counter to HEX3-HEX2
	seg7 addressCounterTens(.hex(tensCounter), .leds(HEX3));
	seg7 addressCounterOnes(.hex(onesCounter), .leds(HEX2));
	
	
	//initialize task 2 memory
	//task2 t2(.clock(clock), .address(addr), .data(data), .wren(write), .q(dataOUT));
	
	//displays the address for task 2 memory on HEX5 and HEX4
	seg7 addressTens(.hex(tens), .leds(HEX5));
	seg7 addressOnes(.hex(ones), .leds(HEX4));
	
	//display the write data on HEX1 and the data for the address in HEX0
	seg7 dataInHex(.hex(data), .leds(HEX1));                                               
	seg7 dataOutHex(.hex(dataOUT), .leds(HEX0));
	

	


		
endmodule
	




	





