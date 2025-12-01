`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module generate_piece_move(
   input rotate,
   input clk,
   input rst_n,
   input move_left,
   input move_right,
   input move_tobottom,
   input [2:0] game_current_state,
   input en_fall,
   input will_collide_below,
   output reg [2:0] game_next_state_generate
);
   always@(posedge clk or negedge rst_n)begin
      if (!rst_n)begin
         game_next_state_generate <= `GENERATE_PIECE;
      end
      else begin
         if (game_current_state == `GENERATE_PIECE)begin
            if (en_fall) begin
               if (will_collide_below)begin
                  game_next_state_generate <= `COLLISION;
               end
               else begin
                  game_next_state_generate <= `GENERATE_PIECE;
               end
            end
            else if (rotate)begin
               game_next_state_generate <= `ROTATE_PIECE;
            end
            else if (move_left || move_right)begin
               game_next_state_generate <= `MOVE;
            end
            else if (move_tobottom)begin
               game_next_state_generate <= `TOBOTTOM;
            end
            else ;
         end
         else begin
            game_next_state_generate <= `GENERATE_PIECE;
         end
      end
   end
endmodule 


