`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module fall_move(
    input clk,
    input rst_n,
    input move_fast,
    input [2:0] game_next_state,
    input start_collision,
    output reg en_fall
);
    reg [31:0] fall_cnt;
    reg [31:0] current_divider;
    // define fast fall and low fall
    parameter fast_fall_cnt = 32'd4999999,
              slow_fall_cnt = 32'd49999999,
              test_fall_cnt = 32'd30;//only for simulation
    
    // generate en_fall
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fall_cnt <= 0;
            en_fall <= 0;
            current_divider <= slow_fall_cnt;
        end
        else if (start_collision || (game_next_state == `CLEAR_ROW))begin
            fall_cnt <= 0;
            en_fall <= 0;
        end
        else begin
            if (move_fast)begin
                current_divider <= fast_fall_cnt;
            end 
            else begin
                current_divider <= slow_fall_cnt;
            end            
            // current_divider <= test_fall_cnt;
            if (fall_cnt >= current_divider)begin
                fall_cnt <= 0;
                en_fall <= 1;
            end 
            else begin
                fall_cnt <= fall_cnt + 1;
                en_fall <= 0;           
            end
        end
    end

endmodule