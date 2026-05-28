//Shomik Sen, Kavin, Sundar
//This module is the datapath for our binary search, it takes in the control signals from the controller and outputs status signals back to the controller
//it also handles all of the registers and increments and derements as needed

module task2DataPath(reset, incr_addr, decr_addr, assert_found, Load_Reg, equals, count_big, Rom_small, done, assert_done, clock, datain, found, loc,A, addr, incr_count);

	//These are the inputs, mostly control signals
	input logic reset, incr_addr, decr_addr, Load_Reg, assert_done, assert_found, clock, incr_count;
	
	//these are the status signals
	output logic equals, count_big, Rom_small, done;
	
	//this is the data
	input logic [7:0] A, datain;
	
	//this is the address of the given data
	output logic [4:0] addr;
	
	logic [3:0] count;
	
	output logic found;
	output logic [4:0] loc;
	
	//logic to instantiate and change the registers based on the status and control signals
	always_ff @(posedge clock) begin
		 if(reset) begin
			  done <= 0;
			  found <= 0;
			  addr <= 0;
			  loc <= 0;
			  count <= 0;
		 end
		 else begin

			if(Load_Reg) begin
				addr <= 5'd15;
            count <= 0;
            found <= 0;
            loc <= 0;
            done <= 0;
			end

			if(assert_found) begin
            found <= 1;
            loc <= addr;
			end

			//hard coded the address 31 because our logic checks over 31
			if (addr == 30 && A > datain)
				addr <= 31;
			else if (incr_addr)
				addr <= addr + (16 >> count);
			else if (decr_addr)
				addr <= addr - (16 >> count);
					
			if (incr_count && !assert_found)
				count <= count + 1'b1;

			if(assert_done)
            done <= 1;
		end
	end

	//status signals that are being asserted
	assign equals = (datain == A);
	assign Rom_small = (datain < A);
	assign count_big = (count > 5);
endmodule



		