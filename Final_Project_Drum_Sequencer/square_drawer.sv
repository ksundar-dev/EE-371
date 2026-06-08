//Shomik Sen, Kavin Sundar
//This is the module that draws the boxes on the screen. It draws 4 lines one by one to make a box.
//The De1_Soc instantiates 64 of these one at a time. 
module square_drawer(
    input  logic [10:0] x0, y0, height, width, // Size and start positions
    input  logic        clock, reset, start,   // Handshake controls (fixed list)
    output logic        done,                  // Signal when square is finished
    output logic [10:0] x, y,                  // Coordinates to framebuffer
    output logic        pixel_write            // High when drawing lines
);

    // Temporary variables to hold current line coordinates
    logic [10:0] temp_x, temp_y, temp_x1, temp_y1; 
    
    logic [2:0]  count;       // Counter to tell which line to draw
    logic        line_done;   // Caught from the line drawer
    logic        line_reset;  // Managed internally to step the engine
    
    // Internal wires the will draw the actual line
    logic [10:0] line_x, line_y;
    
    // state declerations
    enum logic [1:0] {S_Idle, S_Setup, S_Draw, S_Done} ps, ns;

    // line drawer module is instantiated
    line_drawer line (.clk(clock), .reset(line_reset), .x0(temp_x),.y0(temp_y), .x1(temp_x1), .y1(temp_y1), .x(line_x), .y(line_y), .done(line_done));

    // assign the x and y lines to the internal lines
    assign x = line_x;
    assign y = line_y;
		
	//state transitions
    always_comb begin
        ns = ps; // Default to prevent hardware latches
        case(ps)
            S_Idle:  if (start) ns = S_Setup;
                     else       ns = S_Idle;
            
            S_Setup: if (count > 4 || count == 0) ns = S_Done;
                     else                         ns = S_Draw;
                     
            S_Draw:  if (line_done) ns = S_Setup;
                     else           ns = S_Draw;
            
            S_Done:  ns = S_Idle;
            default: ns = S_Idle;
        endcase
    end
    
	
	//datapath logic
    always_comb begin
        pixel_write = (ps == S_Draw); 
        done        = (ps == S_Done); 
        
        // To draw a new line during the setup phase
        line_reset  = (ps == S_Setup); 
    end
    
    //logic to change the coordinates
    always_ff @(posedge clock) begin
        if (reset) begin
            ps      <= S_Idle; //init regs
            count   <= 3'd0;
            temp_x  <= 11'd0;
            temp_y  <= 11'd0;
            temp_x1 <= 11'd0;
            temp_y1 <= 11'd0;
        end else begin
            ps <= ns; 
            
            if (ps == S_Idle && start == 1) begin
                temp_x  <= x0;
                temp_y  <= y0;
                temp_x1 <= x0 + width; 
                temp_y1 <= y0;
                count   <= 3'd1; // Initialize count to 1 for first line
            end
            else if (ps == S_Setup && count == 3'd1) begin //first edge
                temp_x  <= x0;
                temp_y  <= y0;
                temp_x1 <= x0 + width;
                temp_y1 <= y0;
            end
            else if (ps == S_Setup && count == 3'd2) begin //second line
                temp_x  <= x0 + width;
                temp_y  <= y0;
                temp_x1 <= x0 + width;
                temp_y1 <= y0 + height;
            end
            else if (ps == S_Setup && count == 3'd3) begin //third line
                temp_x  <= x0 + width;
                temp_y  <= y0 + height;
                temp_x1 <= x0;
                temp_y1 <= y0 + height;
            end
            else if (ps == S_Setup && count == 3'd4) begin //fourth line
                temp_x  <= x0;
                temp_y  <= y0 + height;
                temp_x1 <= x0;
                temp_y1 <= y0; 
            end
            
				//count will only increment when the line is done drawing
            if (ps == S_Draw && line_done) begin
                count <= count + 3'd1;
            end
        end
    end

endmodule
		