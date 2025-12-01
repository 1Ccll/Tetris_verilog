module Tetris_top(
    input clk,
    input rst_n,
    input move_left,
    input move_right,
    input move_fast,
    input move_tobottom,
    input rotate,
    output wire vga_hsync,
    output wire vga_vsync,
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b
);

    wire twinkle_color;
    wire vga_clk;
    wire [199:0] blocks_exist;
    wire [7:0] active_pos0, active_pos1, active_pos2, active_pos3;
    wire [7:0] color_read_addr_w;
    wire [2:0] color_read_data_w;
    wire [19:0] is_full_row;
    wire [2:0] game_current_state;
    wire [2:0] current_block_type;
    wire [2:0] next_block_type;
    wire [1:0] next_block_rotation;
    wire [3:0] score_d3;
    wire [3:0] score_d2;
    wire [3:0] score_d1;          
    wire [3:0] score_d0;  
    
    // process input signals
    edge_transfer U_processed_move_left (.clk(clk), .rst_n(rst_n), .signal_in(move_left), .pulse(processed_move_left));
    edge_transfer U_processed_move_right (.clk(clk), .rst_n(rst_n), .signal_in(move_right), .pulse(processed_move_right));
    edge_transfer U_processed_move_tobottom (.clk(clk), .rst_n(rst_n), .signal_in(move_tobottom), .pulse(processed_move_tobottom));
    edge_transfer U_processed_rotate (.clk(clk), .rst_n(rst_n), .signal_in(rotate), .pulse(processed_rotate));

    // game logic
    Tetris_design u_main (
        .clk(clk), 
        .rst_n(rst_n), 
        .move_left(processed_move_left), 
        .move_right(processed_move_right),
        .move_fast(move_fast), 
        .move_tobottom(processed_move_tobottom), 
        .rotate(processed_rotate), 
        .blocks_exist(blocks_exist),
        .active_pos0(active_pos0),
        .active_pos1(active_pos1),
        .active_pos2(active_pos2),
        .active_pos3(active_pos3),
        .next_block_type(next_block_type),
        .next_block_rotation(next_block_rotation), 
        .score_d3(score_d3),
        .score_d2(score_d2),            
        .score_d1(score_d1),      
        .score_d0(score_d0),  
        .vga_read_addr(color_read_addr_w), 
        .vga_read_data(color_read_data_w), 
        .is_full_row(is_full_row), 
        .game_current_state(game_current_state), 
        .current_block_type(current_block_type),
        .twinkle_color(twinkle_color)
    );
    
    // vga clk 
    vga_clk u_vga_clk (
        .clk_in1(clk), 
        .clk_out1(vga_clk)
    );
        
    // vga display
    Tetris_vga u_vga (
        .clk(vga_clk), 
        .rst_n(rst_n),
        .blocks_exist(blocks_exist), 
        .active_pos0(active_pos0),
        .active_pos1(active_pos1),
        .active_pos2(active_pos2),
        .active_pos3(active_pos3),
        .next_block_type(next_block_type),
        .next_block_rotation(next_block_rotation), 
        .score_d3(score_d3),
        .score_d2(score_d2),            
        .score_d1(score_d1),      
        .score_d0(score_d0),  
        .color_read_addr(color_read_addr_w), 
        .color_read_data(color_read_data_w),
        .current_block_type(current_block_type), 
        .game_current_state(game_current_state), 
        .twinkle_color(twinkle_color), 
        .is_full_row(is_full_row), 
        .vga_hsync(vga_hsync), 
        .vga_vsync(vga_vsync),
        .vga_r(vga_r), 
        .vga_g(vga_g), 
        .vga_b(vga_b)
    );
endmodule
