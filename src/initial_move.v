`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module initial_move(
    input rotate,
    input clk,
    input rst_n,
    input [2:0] game_current_state,
    output reg [199:0] blocks_exist_initial,
    output reg [2:0] game_next_state_initial
);
    always@(posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            blocks_exist_initial <= {200{1'b0}}; 
            game_next_state_initial <= `INITIAL;
        end
        else begin
            if (game_current_state == `INITIAL)begin
                blocks_exist_initial <= {200{1'b0}}; 
                if (rotate) begin// use rotate button to control game start
                    game_next_state_initial <= `GENERATE_PIECE;
                end
                else
                    game_next_state_initial <= `INITIAL;
            end
            else ;
        end
    end
endmodule