//Kavin SUndar
//Module that reads rom and retuyrns values to go into audio codec and play the insturments
module soundSelector (
    input  logic        clk, reset,
    input  logic        write_ready,
    input  logic        switcher,               // high on last clk of beat
    input  logic        kickPlay, clapPlay, hhPlay, ohPlay,
    output logic        write,
    output logic [23:0] writedata_left,
    output logic [23:0] writedata_right
);

    parameter KICK_LEN = 6625;
    parameter CLAP_LEN = 5537;
    parameter HH_LEN   = 4890;
    parameter OH_LEN   = 16845;

    //Expanded address counters to 15-bits to stop bit-width register wrapping overflow. Allow multiple sounds
    logic [14:0] kick_addr, hh_addr, clap_addr, oh_addr;

    // Playing flags that set on trigger, cleared when sample finishes
    logic kick_playing, clap_playing, hh_playing, oh_playing;

    // ROM outputs
    logic [23:0] kick_data, clap_data, hh_data, oh_data;

    // Mix signals
    logic signed [27:0] mix;
    logic signed [23:0] selected;
    logic                any_play;

    // ROMs (Addresses are implicitly zero-extended safely by named port mappings)
    kick_rom  k (.clock(clk), .address(kick_addr), .q(kick_data));
    clap_rom  c (.clock(clk), .address(clap_addr), .q(clap_data));
    hh_rom    h (.clock(clk), .address(hh_addr),   .q(hh_data));
    oh_rom    o (.clock(clk), .address(oh_addr),   .q(oh_data));

    // Mix: only mix sounds that are actively playing
    always_comb begin
        mix = 28'b0;
        if (kick_playing) mix = mix + ({{4{kick_data[23]}}, kick_data} <<< 6); ///2^6 louder
        if (clap_playing) mix = mix + ({{4{clap_data[23]}}, clap_data} <<< 7); 
        if (oh_playing)   mix = mix + ({{4{oh_data[23]}},   oh_data}   <<< 2); 
        if (hh_playing)   mix = mix + ({{4{hh_data[23]}},   hh_data}   <<< 8); 
    end

    // COndense to 24-bit safely
    always_comb begin
        if      (mix > 28'sh7FFFFF)  selected = 24'sh7FFFFF;
        else if (mix < -28'sh800000) selected = 24'sh800000;
        else                          selected = mix[23:0];
    end

    assign any_play = kick_playing | clap_playing | hh_playing | oh_playing;

    // Kick
    always_ff @(posedge clk) begin
        if (reset) begin
            kick_addr    <= 0;
            kick_playing <= 0;
        end
        else if (switcher) begin
            kick_addr    <= 0;       
            kick_playing <= 0;
        end
        else if (kickPlay) begin     
            kick_addr    <= 0;
            kick_playing <= 1;
        end
        else if (kick_playing && write_ready) begin
            if (kick_addr == KICK_LEN-1) begin
                kick_playing <= 0;   
                kick_addr    <= 0;
            end
            else
                kick_addr <= kick_addr + 1'b1;
        end
    end

    // Clap
    always_ff @(posedge clk) begin
        if (reset) begin
            clap_addr    <= 0;
            clap_playing <= 0;
        end
        else if (switcher) begin
            clap_addr    <= 0;
            clap_playing <= 0;
        end
        else if (clapPlay) begin
            clap_addr    <= 0;
            clap_playing <= 1;
        end
        else if (clap_playing && write_ready) begin
            if (clap_addr == CLAP_LEN-1) begin
                clap_playing <= 0;
                clap_addr    <= 0;
            end
            else
                clap_addr <= clap_addr + 1'b1;
        end
    end

    // Hi-Hat
    always_ff @(posedge clk) begin
        if (reset) begin
            hh_addr      <= 0;
            hh_playing   <= 0;
        end
        else if (switcher) begin
            hh_addr      <= 0;
            hh_playing   <= 0;
        end
        else if (hhPlay) begin
            hh_addr      <= 0;
            hh_playing   <= 1;
        end
        else if (hh_playing && write_ready) begin
            if (hh_addr == HH_LEN-1) begin
                hh_playing <= 0;
                hh_addr    <= 0;
            end
            else
                hh_addr <= hh_addr + 1'b1;
        end
    end

    // Open Hat
    always_ff @(posedge clk) begin
        if (reset) begin
            oh_addr      <= 0;
            oh_playing   <= 0;
        end
        else if (switcher) begin
            oh_addr      <= 0;
            oh_playing   <= 0;
        end
        else if (ohPlay) begin
            oh_addr      <= 0;
            oh_playing   <= 1;
        end
        else if (oh_playing && write_ready) begin
            if (oh_addr == OH_LEN-1) begin
                oh_playing <= 0;
                oh_addr    <= 0;
            end
            else
                oh_addr <= oh_addr + 1'b1;
        end
    end

    // Write to CODEC
    always_ff @(posedge clk) begin
        if (reset) begin
            write           <= 0;
            writedata_left  <= 0;
            writedata_right <= 0;
        end
        else if (write_ready) begin
            write           <= any_play;
            writedata_left  <= selected;
            writedata_right <= selected;
        end
        else
            write <= 0;
    end

endmodule