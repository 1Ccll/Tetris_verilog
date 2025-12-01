`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module lose_move(
    input clk,
    input rst_n,
    input [2:0] game_current_state,
    input rotate,
    output reg [2:0] game_next_state_lose
);
    always@(posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            game_next_state_lose <= `LOSE;
        end
        else begin
            if (game_current_state == `LOSE)begin
                if (rotate)begin
                    game_next_state_lose <= `INITIAL;
                end
                else begin
                    game_next_state_lose <= `LOSE;
                end
                end
            else;
        end
    end
endmodule