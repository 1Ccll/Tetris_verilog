`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module state_controller(
    input clk,
    input rst_n,
    
    // game_next_state
    input [2:0] game_next_state_initial,
    input [2:0] game_next_state_generate,
    input [2:0] game_next_state_rotate,
    input [2:0] game_next_state_collision,
    input [2:0] game_next_state_clear,
    input [2:0] game_next_state_move,
    input [2:0] game_next_state_tobottom,
    input [2:0] game_next_state_lose,

    output reg [2:0] game_next_state,
    output reg [2:0] game_current_state
    );
    always@(posedge clk or negedge rst_n)begin
        if (!rst_n)
            game_current_state <= `INITIAL;
        else begin
            game_current_state <= game_next_state;
        end
    end

    always@(*)begin
        game_next_state = `GENERATE_PIECE;
        case (game_current_state)
        `INITIAL: begin
            game_next_state = game_next_state_initial;
        end
        `GENERATE_PIECE: begin
            game_next_state = game_next_state_generate;
        end
        `ROTATE_PIECE: begin
            game_next_state = game_next_state_rotate;
        end
        `COLLISION: begin
            game_next_state = game_next_state_collision;
        end
        `CLEAR_ROW: begin
            game_next_state = game_next_state_clear;
        end
        `MOVE: begin
            game_next_state = game_next_state_move;
        end
        `TOBOTTOM: begin
            game_next_state = game_next_state_tobottom;
        end
        `LOSE: begin
            game_next_state = game_next_state_lose;
        end
        default: ;
        endcase
    end
endmodule