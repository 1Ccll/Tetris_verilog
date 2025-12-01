`timescale 1ns / 1ps
`define INITIAL        3'b000
`define GENERATE_PIECE 3'b001
`define ROTATE_PIECE   3'b010
`define COLLISION      3'b011
`define LOSE           3'b100
`define CLEAR_ROW      3'b101
`define MOVE           3'b110
`define TOBOTTOM       3'b111

`define SQUARE 3'b000
`define BAR    3'b001
`define S      3'b010
`define Z      3'b011
`define L      3'b100
`define J      3'b101
`define T      3'b110





`timescale 1ns / 1ps


module tb_tetris;
reg          clk;
reg          rst_n;
reg          move_left, move_right, rotate, move_fast, move_tobottom;

wire [2:0]   game_current_state;
wire [199:0] blocks_exist;
wire [19:0]  is_full_row;
wire [199:0] blocks_active;
wire twinkle_color;
wire [7:0] active_pos0, active_pos1, active_pos2, active_pos3;
wire [7:0] vga_read_addr;  // 来自 Top/VGA
wire [2:0] vga_read_data;



//---------------- 时钟 ----------------
always #5 clk = ~clk;

//---------------- 模块实例 ----------------
Tetris_design dut (
   .clk(clk),
   .rst_n(rst_n),
   .move_left(move_left),
   .move_right(move_right),
   .rotate(rotate),
   .move_fast(move_fast),
   .move_tobottom(move_tobottom),
   .game_current_state(game_current_state),
    .blocks_exist(blocks_exist),
    .active_pos0(active_pos0),
    .active_pos1(active_pos1),
    .active_pos2(active_pos2),
    .active_pos3(active_pos3),
    .vga_read_addr(vga_read_addr),   // 来自 Top/VGA
    .vga_read_data(vga_read_data), 
    .is_full_row(is_full_row),
    .twinkle_color(twinkle_color)
);
initial begin
    clk = 0;
    rst_n = 0;
    move_left = 0;
    move_right = 0;
    rotate = 0;
    move_fast = 0;
    move_tobottom = 0;
    #100 rst_n = 1;

    #10 rotate = 1;
    #10 rotate = 0;


    #100 move_tobottom = 1;
    #10 move_tobottom = 0;

    #1000 rotate = 1;
    #100 rotate = 0;
    // #10 rotate = 1;
    // #10 rotate = 0;
    // #10 rotate = 1;
    // #10 rotate = 0;
    // #10 rotate = 1;
    // #10 rotate = 0;
    // #100 rotate = 1;
    // #10 rotate = 0;
    // #10 rotate = 1;
    // #10 rotate = 0;
    // #10 rotate = 1;
    // #10 rotate = 0;
    // #100 rotate = 1;
    // #10 rotate = 0;
    // #10 rotate = 1;
    // #10 rotate = 0;
    // #10 rotate = 1;
    // #10 rotate = 0;
    

    #50 move_left = 1;
    #10 move_left = 0;
    // #50 move_left = 1;
    // #10 move_left = 0;
    // #50 move_left = 1;
    // #10 move_left = 0;
    // #50 move_left = 1;
    // #10 move_left = 0;
    // #50 move_left = 1;
    // #10 move_left = 0;

    // #2000 move_left = 1;
    // #10 move_left = 0;
    // #50 move_left = 1;
    // #10 move_left = 0;
    // #50 move_left = 1;
    // #10 move_left = 0;

    // #4300 move_right = 1;
    // #10 move_right = 0;
    // #50 move_right = 1;
    // #10 move_right = 0;

    // #2000 move_right = 1;
    // #10 move_right = 0;
    // #50 move_right = 1;
    // #10 move_right = 0;
    // #50 move_right = 1;
    // #10 move_right = 0;
    // #50 move_right = 1;
    // #10 move_right = 0;
    // #50 move_right = 1;
    // #10 move_right = 0;



end
endmodule