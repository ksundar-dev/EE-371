//Kavin Sundar & Shomik Sen
//4/8/2026
//Lab 1: Parking Lot Occupancy Counter
//sevenseg is a module that assigns values for the HEXs in this lab. It
//takes in the 5bit input total, which is how many cars are inside the parking lot, as well as
//two 1-bit values (clear and total) which check for the specific states of whether the parking
//lot is empty or full. The outputs are all of the HEX displays (HEXs 0 and HEXs1 are numbers)
//of cars while HEXs 5 - 2 are for the specific cases).
module sevenSeg (
    input logic [4:0] total,
	input logic clear,
	input logic full,

    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5

	);


    always_comb begin
    // default all hexs to blank
			HEX5 = 7'b1111111;
			HEX4 = 7'b1111111;	
			HEX3 = 7'b1111111;
			HEX2 = 7'b1111111;
			HEX1 = 7'b1111111;
			HEX0 = 7'b1111111;

	//checks to see if the lot is empty
	if(clear)begin
			HEX5 = 7'b1000110; //C
			HEX4 = 7'b1000111; //L
			HEX3 = 7'b0000110; //E
			HEX2 = 7'b0001000; //A
			HEX1 = 7'b0101111; //R
			HEX0 = 7'b1000000; //0
	end

	//checks to see if lot is full
	else if(full)begin
			HEX5 = 7'b0001110; //F
			HEX4 = 7'b1000001; //U
			HEX3 = 7'b1000111; //L
			HEX2 = 7'b1000111; //L
			HEX1 = 7'b1111001; //1
			HEX0 = 7'b0000000; //8
	end

	//assigns the number of cars to last to HEXs if not full or empty
	else begin
            case (total) 
                5'd0:  begin HEX1 = 7'b1000000; HEX0 = 7'b1000000; end // 00
                5'd1:  begin HEX1 = 7'b1000000; HEX0 = 7'b1111001; end // 01
                5'd2:  begin HEX1 = 7'b1000000; HEX0 = 7'b0100100; end // 02
                5'd3:  begin HEX1 = 7'b1000000; HEX0 = 7'b0110000; end // 03
                5'd4:  begin HEX1 = 7'b1000000; HEX0 = 7'b0011001; end // 04
                5'd5:  begin HEX1 = 7'b1000000; HEX0 = 7'b0010010; end // 05
                5'd6:  begin HEX1 = 7'b1000000; HEX0 = 7'b0000010; end // 06
                5'd7:  begin HEX1 = 7'b1000000; HEX0 = 7'b1111000; end // 07
                5'd8:  begin HEX1 = 7'b1000000; HEX0 = 7'b0000000; end // 08
                5'd9:  begin HEX1 = 7'b1000000; HEX0 = 7'b0010000; end // 09
                5'd10: begin HEX1 = 7'b1111001; HEX0 = 7'b1000000; end // 10 
                5'd11: begin HEX1 = 7'b1111001; HEX0 = 7'b1111001; end // 11
                5'd12: begin HEX1 = 7'b1111001; HEX0 = 7'b0100100; end // 12
                5'd13: begin HEX1 = 7'b1111001; HEX0 = 7'b0110000; end // 13
                5'd14: begin HEX1 = 7'b1111001; HEX0 = 7'b0011001; end // 14
                5'd15: begin HEX1 = 7'b1111001; HEX0 = 7'b0010010; end // 15
                5'd16: begin HEX1 = 7'b1111001; HEX0 = 7'b0000010; end // 16
                5'd17: begin HEX1 = 7'b1111001; HEX0 = 7'b1111000; end // 17
                5'd18: begin HEX1 = 7'b1111001; HEX0 = 7'b0000000; end // 18
                default: begin HEX1 = 7'b1111111; HEX0 = 7'b1111111; end
            endcase
        end
       
 end

endmodule

