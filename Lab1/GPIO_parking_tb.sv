//Test bench for the offboard components. Checks the pins and the switches
//off of board ot make sure it works as needed.
module GPIO_parking_tb ();
  // inout pins must be connected to a wire type
  wire [35:0] V_GPIO;
  // additional logic required to simulate inout pins
  logic [35:0] V_GPIO_in;
  logic [35:0] V_GPIO_dir;  // 1 = input, 0 = output

  // set up tristate buffers for inout pins
  genvar i;
  generate
    for (i = 0; i < 36; i++) begin : gpio
      assign V_GPIO[i] = V_GPIO_dir[i] ? V_GPIO_in[i] : 1'bZ;
    end
  endgenerate

  GPIO_parking dut (.V_GPIO);

  initial begin
    // Initialize everything
    V_GPIO_in  = 36'b0;
    V_GPIO_dir = 36'b0;

    // Set directions
    // switches (inputs to FPGA)
    V_GPIO_dir[24] = 1'b1;  // outer
    V_GPIO_dir[25] = 1'b1;  // inner
	 V_GPIO_dir[10] = 1'b1;  // inner

    // LEDs (outputs from FPGA)
    V_GPIO_dir[35] = 1'b0;  // outer LED
    V_GPIO_dir[34] = 1'b0;  // inner LED
	 
	 
	 //First test reset
	 V_GPIO_in[24] = 1;		 #50;
    V_GPIO_in[25] = 0;		//Turne reset off
   

    //First testing both being off
    V_GPIO_in[24] = 0;
    V_GPIO_in[25] = 0;
    #50;

    //NOW just outer
    V_GPIO_in[24] = 1;
    V_GPIO_in[25] = 0;
    #50;

    //TEsting just inner
    V_GPIO_in[24] = 0;
    V_GPIO_in[25] = 1;
    #50;

    // Testing both
    V_GPIO_in[24] = 1;
    V_GPIO_in[25] = 1;
    #50;

    $stop;
  end
endmodule