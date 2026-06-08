//Shomik Sen, Kavin Sundar
//LAB 5 MAY 22 2026
/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *	 x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 * Outputs:
 *   x 		- x coordinate of the pixel to color
 *   y 		- y coordinate of the pixel to color
 *   done	- flag that line has finished drawing
 *
 */
module line_drawer(clk, reset, x0, y0, x1, y1, x, y, done);
    input logic clk, reset;
    input logic [10:0] x0, y0, x1, y1;
    output logic done;
    output logic [10:0] x, y;


    enum logic [2:0] {S_IDLE, S_SETUP,S_DRAW, S_ERROR, S_DONE} ps, ns;

	
	//all the values in the datapath are created

    logic is_steep;
    logic [10:0] sx0, sy0, sx1;
    logic [10:0] deltax, deltay;
    logic signed [11:0] y_step;
    logic signed [11:0] error;
    logic [10:0] x_curr, y_curr;


    logic [10:0] abs_dx, abs_dy;
    logic        steep_c;
    logic [10:0] tx0, ty0, tx1, ty1;
    logic [10:0] fx0, fy0, fx1, fy1;

	 //initialize all the values 
    assign abs_dx  = (x1 >= x0) ? (x1 - x0) : (x0 - x1);
    assign abs_dy  = (y1 >= y0) ? (y1 - y0) : (y0 - y1);
    assign steep_c = (abs_dy > abs_dx);
    assign tx0     = steep_c ? y0 : x0;
    assign ty0     = steep_c ? x0 : y0;
    assign tx1     = steep_c ? y1 : x1;
    assign ty1     = steep_c ? x1 : y1;
    assign fx0     = (tx0 > tx1) ? tx1 : tx0;
    assign fy0     = (tx0 > tx1) ? ty1 : ty0;
    assign fx1     = (tx0 > tx1) ? tx0 : tx1;
    assign fy1     = (tx0 > tx1) ? ty0 : ty1;

	//create the control signals

    logic ctrl_setup;   // setup everything
    logic ctrl_write_pixel;   // signal to draw
    logic ctrl_update_error;  // signal to calculate error
    logic ctrl_done;          // done control signal


    always_ff @(posedge clk) begin
        if (reset) ps <= S_IDLE;
        else       ps <= ns;
    end


    always_comb begin
        
		  //default everything is zero
        ns = ps;
        ctrl_setup  = 1'b0;
        ctrl_write_pixel  = 1'b0;
        ctrl_update_error = 1'b0;
        ctrl_done         = 1'b0;

        case (ps)
            S_IDLE: begin
                //idle goes straight to setup
                ns = S_SETUP;
            end

            S_SETUP: begin
                ctrl_setup = 1'b1;  //setup control signal asserted
                ns = S_DRAW;
            end

            S_DRAW: begin
                ctrl_write_pixel = 1'b1;  //logic for the draw state
                if (x_curr == sx1)
                    ns = S_DONE;          // boundry pixel
                else
                    ns = S_ERROR;         // update the error
            end

            S_ERROR: begin
                ctrl_update_error = 1'b1; // tell datapath to update error
                ns = S_DRAW;              // loop back to draw next pixel
            end

            S_DONE: begin
                ctrl_done = 1'b1;         // assert done
                ns = S_DONE;              // stay here until reset
            end

            default: ns = S_IDLE;
        endcase
    end


    always_ff @(posedge clk) begin
        if (reset) begin
            // clear everything on reset
            done   <= 1'b0;
            x      <= 11'd0;
            y      <= 11'd0;
            x_curr <= 11'd0;
            y_curr <= 11'd0;
            error  <= 12'sd0;

        end else begin

            //control signal to start the setup all of the values in the datapath will change
            if (ctrl_setup) begin
                is_steep <= steep_c;
                sx0      <= fx0;
                sy0      <= fy0;
                sx1      <= fx1;
                deltax   <= fx1 - fx0;
                deltay   <= (fy1 >= fy0) ? (fy1 - fy0) : (fy0 - fy1);
                error    <= -$signed({1'b0, (fx1 - fx0) >> 1});
                y_step   <= (fy0 <= fy1) ? 12'sd1 : -12'sd1;
                x_curr   <= fx0;
                y_curr   <= fy0;
                done     <= 1'b0;
            end

            //control signal to draw the pixel, updates the datapath values
            if (ctrl_write_pixel) begin
                x <= is_steep ? y_curr : x_curr;
                y <= is_steep ? x_curr : y_curr;
                // advance x here so S_ERROR sees the updated x_curr
                // (but only if not the last pixel)
                if (x_curr != sx1)
                    x_curr <= x_curr + 11'd1;
            end

            //control signal to calculate the edge to see if it reaches the bounds, updates the datapath values
            if (ctrl_update_error) begin
                if (error + $signed({1'b0, deltay}) >= 12'sd0) begin
                    // ideal line crossed a row — step y, reset error
                    y_curr <= $unsigned($signed({1'b0, y_curr}) + y_step);
                    error  <= error + $signed({1'b0, deltay})
                                    - $signed({1'b0, deltax});
                end else begin
                    // not yet — just accumulate drift
                    error  <= error + $signed({1'b0, deltay});
                end
            end

            //control signal to set done where done in the datapath becomes 1
            if (ctrl_done) begin
                done <= 1'b1;
            end

        end
    end

endmodule


	
	
	
	