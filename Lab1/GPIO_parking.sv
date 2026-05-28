//Kavin Sundar & SHomik Sen
//4/9/2026
//Lab1 Parking Lot Occupancy
//This module acts as the offboard components, these components are: two LEDs
// and two switches. Theswitches are mapped to JDL pin 24 and 25. The LEDs to
// JDL pins 34 and 35.
module GPIO_parking (
    inout logic [35:0] V_GPIO
);

    // Assign GPIO pins to meaningful names
    logic outer, inner, reset;

    // Read switches (inputs)
    assign outer = V_GPIO[24];  // switch 1
    assign inner = V_GPIO[25];  // switch 2
	 assign reset = V_GPIO[10]; //reset switch

    // Drive LEDs (outputs)
    assign V_GPIO[35] = outer;  // LED 1
    assign V_GPIO[34] = inner;  // LED 2
	 

endmodule