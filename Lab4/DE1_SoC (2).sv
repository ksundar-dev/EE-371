//Shomik Sen, Kavin Sundar
//This is our top level module that instantiates both task1 and task2 and switches between them using switch 9
module DE1_SoC #(parameter N=8)(CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input  logic         CLOCK_50; // 50MHz clock.
	output logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic  [9:0]  LEDR;
	input  logic  [3:0]  KEY; // True when not pressed, False when pressed
	input  logic  [9:0]  SW;

	
	
	//reset and start wires
	logic reset;
	logic start;
	assign reset = ~KEY[0];
	
	//wires for task1
	logic set_done, init_result, Load_A, incr_result, right_shiftA;
	logic Done;
	logic [$clog2(N) : 0 ] result;

	logic A0;

	logic [N-1:0] A;
	
	logic A_empty;
	
	
	 //wires to switche between tasks using switch 9
    logic mode;

    assign mode = SW[9];
	 
	 logic start_task1, start_task2;

    assign start_task1 = start & ~mode;
    assign start_task2 = start &  mode;
	 
	 

	
	
	//button press module to handle metatability for the start logic
	buttonPress bP(.clock(CLOCK_50), .reset(reset), .button(KEY[3]), .isPressed(start));
	

	//task1 controller
	task1Controller controlla(.A0(A0),.A_empty(A_empty), .right_shiftA(right_shiftA), .incr_result(incr_result), .init_result(init_result), .Load_A(Load_A), .set_done(set_done), .s(start_task1), .clock(CLOCK_50), .reset(reset));
	
	//task1 dataPath
	task1DataPath dataPath(.reset(reset),.A0(A0),.A_empty(A_empty), .Done(Done), .set_done(set_done), .Load_A(Load_A), .right_shiftA(right_shiftA), .result(result), .init_result(init_result), .incr_result(incr_result), .A(A), .Switches(SW[7:0]), .clock(CLOCK_50));
	
	
	

	
	//wires for task2
	logic equals;
	logic incr_addr, decr_addr, assert_found, Load_Reg, count_big, ROM_small, done, assert_done, incr_count, found;
	
	logic[4:0] addr, loc;
	logic [7:0] dataOut;
	
	//ram for task2 
	ram32x8 RAM(
	.clock(CLOCK_50),
	.data(8'b0),
	.rdaddress(addr),
	.wraddress(addr),
	.wren(1'b0),
	.q(dataOut));

	//task2 dataPath
	task2DataPath dataPath2(.reset(reset),.incr_addr(incr_addr), .decr_addr(decr_addr), .assert_found(assert_found), .Load_Reg(Load_Reg), .equals(equals), .count_big(count_big), .Rom_small(ROM_small), .done(done), .assert_done(assert_done), .clock(CLOCK_50), .datain(dataOut), .found(found), .loc(loc),.A(SW[7:0]), .addr(addr), .incr_count(incr_count));
	
	//task2Controller
	task2Controller controlla2(.incr_addr(incr_addr), .decr_addr(decr_addr), .Assert_found(assert_found), .Load_Reg(Load_Reg), .equals(equals), .count_big(count_big), .Rom_small(ROM_small), .assert_done(assert_done), .reset(reset), .start(start_task2), .clock(CLOCK_50), .incr_count(incr_count));
	
	//logic to assign the correct values to HEX0 and HEX1
	
    logic [3:0] tens, ones;
	 assign LEDR[0] = found;
	 assign LEDR[9] = done || Done;
	 
	 logic [4:0] display_val;
	 
	 assign display_val = mode ? loc : result;

    always_comb begin
        if (loc >= 30) begin
            tens = 4'd3;
            ones = display_val - 5'd30;
        end else if (loc >= 20) begin
            tens = 4'd2;
            ones = display_val - 5'd20;
        end else if (loc >= 10) begin
            tens = 4'd1;
            ones = display_val - 5'd10;
        end else begin
            tens = 4'd0;
            ones = display_val;
        end
    end

    seg7 h0 (.hex(ones), .leds(HEX0));
    seg7 h1 (.hex(tens), .leds(HEX1));
	 
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
	



endmodule




	





