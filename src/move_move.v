`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module move_move(
   input clk,
   input rst_n,
   input move_left,
   input move_right,
   input [2:0] game_current_state,
   input [2:0] game_next_state,
   input [199:0] blocks_exist,
   input [2:0] current_block_type,
   input [1:0] current_block_rotation,
   input [7:0] location,
   input [255:0] is_col_9,
   output reg [2:0] game_next_state_move,
   output reg [7:0] location_move
);
    reg reg_move_left, reg_move_right; 
    always@(posedge clk or negedge rst_n)begin
        if (move_left)
            reg_move_left <= 1'b1;
        else if (move_right)
            reg_move_right <= 1'b1;
        else ;
        if (!rst_n)begin
            reg_move_left <= 1'b0;
            reg_move_right <= 1'b0;
            game_next_state_move <= `MOVE;
            location_move <= 8'd194;
        end
        else begin
            if (game_next_state == `MOVE)begin
                case(current_block_type)
                    `SQUARE:begin
                        if (reg_move_left && ! is_col_9[location - 1] && !(blocks_exist[location - 1] || blocks_exist[location - 10 - 1]))
                            location_move <= location - 1;
                        else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location + 1] || blocks_exist[location - 10 + 1]))
                            location_move <= location + 1;
                        else location_move <= location;
                    end
                    `BAR:begin
                        case(current_block_rotation)
                            2'b00, 2'b10: begin
                                if (reg_move_left && ! is_col_9[location - 2] && !(blocks_exist[location - 2]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 2] && !(blocks_exist[location + 3]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b01, 2'b11: begin
                                if (reg_move_left && !is_col_9[location - 1] && !(blocks_exist[location - 1] || blocks_exist[location - 10 - 1] || blocks_exist[location - 20 - 1] || (location + 10 < 200 && blocks_exist[location + 10 - 1])))
                                    location_move <= location - 1;
                                else if (reg_move_right && !is_col_9[location] && !(blocks_exist[location + 1] || blocks_exist[location - 10 + 1] || blocks_exist[location - 20 + 1] || (location + 10 < 200 && blocks_exist[location + 10 + 1])))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            default:;
                        endcase
                    end
                    `S:begin
                        case(current_block_rotation)
                            2'b00, 2'b10: begin
                                if (reg_move_left && ! is_col_9[location - 2] && !(blocks_exist[location - 1] || blocks_exist[location - 10 - 2]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location + 2] || blocks_exist[location - 10 + 1]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b01, 2'b11: begin
                                if (reg_move_left && ! is_col_9[location - 1] && !(blocks_exist[location - 1] || blocks_exist[location - 10 - 1] || blocks_exist[location - 20]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location + 1] || blocks_exist[location - 10 + 2] || blocks_exist[location - 20 + 2]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            default:;
                        endcase
                    end
                    `Z:begin
                        case(current_block_rotation)
                            2'b00, 2'b10: begin
                                if (reg_move_left && ! is_col_9[location - 1] && !(blocks_exist[location - 1] || blocks_exist[location - 10]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 2] && !(blocks_exist[location + 2] || blocks_exist[location - 10 + 3]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b01, 2'b11: begin
                                if (reg_move_left && ! is_col_9[location - 1] && !(blocks_exist[location] || blocks_exist[location - 10 - 1] || blocks_exist[location - 20 - 1]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location + 2] || blocks_exist[location - 10 + 2] || blocks_exist[location - 20 + 1]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            default:;
                        endcase
                    end
                    `L:begin
                        case(current_block_rotation)
                            2'b00: begin
                                if (reg_move_left && ! is_col_9[location - 1] && !(blocks_exist[location - 1] || blocks_exist[location - 10 - 1]) || blocks_exist[location - 20 - 1])
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location + 1] || blocks_exist[location - 10 + 1] || blocks_exist[location - 20 + 2]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b01: begin
                                if (reg_move_left && ! is_col_9[location - 1] && !(blocks_exist[location - 1] || blocks_exist[location - 10 - 1]) || blocks_exist[location - 20 - 2])
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 2] && !(blocks_exist[location + 3] || blocks_exist[location - 10 + 1]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b10: begin
                                if (reg_move_left && ! is_col_9[location - 1] && !(blocks_exist[location - 1] || blocks_exist[location - 10] || blocks_exist[location - 20]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location + 2] || blocks_exist[location - 10 + 2] || blocks_exist[location - 20 + 2]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b11: begin
                                if (reg_move_left && ! is_col_9[location - 1] && !(blocks_exist[location + 1] || blocks_exist[location - 10 - 1]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 2] && !(blocks_exist[location + 3] || blocks_exist[location - 10 + 3]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            default:;
                        endcase
                    end
                    `J:begin
                        case(current_block_rotation)
                            2'b00: begin
                                if (reg_move_left && ! is_col_9[location - 2] && !(blocks_exist[location - 1] || blocks_exist[location - 10 - 1] || blocks_exist[location - 20 - 2]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location] && !(blocks_exist[location + 1] || blocks_exist[location - 10 + 1] || blocks_exist[location - 20 + 1]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b01: begin
                                if (reg_move_left && ! is_col_9[location - 2] && !(blocks_exist[location - 2] || blocks_exist[location - 10 - 2]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location] || blocks_exist[location - 10 + 2]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b10: begin
                                if (reg_move_left && ! is_col_9[location - 1] && !(blocks_exist[location - 2] || blocks_exist[location - 10 - 2] || blocks_exist[location - 20 - 2]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location] && !(blocks_exist[location + 1] || blocks_exist[location - 10 + 1] || blocks_exist[location - 20 + 1]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b11: begin
                                if (reg_move_left && ! is_col_9[location - 2] && !(blocks_exist[location - 2] || blocks_exist[location - 10]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location + 2] || blocks_exist[location - 10 + 2]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            default:;
                        endcase
                    end
                    `T:begin
                        case(current_block_rotation)
                            2'b00: begin
                                if (reg_move_left && ! is_col_9[location - 2] && !(blocks_exist[location - 2] || blocks_exist[location - 10 - 1]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location + 2] || blocks_exist[location - 10 + 1]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b01: begin
                                if (reg_move_left && ! is_col_9[location - 2] && !(blocks_exist[location - 2] || blocks_exist[location - 10 - 1] || blocks_exist[location + 10 - 1]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location] && !(blocks_exist[location + 1] || blocks_exist[location - 10 + 1] || blocks_exist[location + 10 + 1]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b10: begin
                                if (reg_move_left && ! is_col_9[location - 2] && !(blocks_exist[location - 2] || blocks_exist[location + 10 - 1]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location + 2] || blocks_exist[location + 10 + 1]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            2'b11: begin
                                if (reg_move_left && ! is_col_9[location - 1] && !(blocks_exist[location - 1] || blocks_exist[location - 10 - 1] || blocks_exist[location + 10 -1 ]))
                                    location_move <= location - 1;
                                else if (reg_move_right && ! is_col_9[location + 1] && !(blocks_exist[location + 2] || blocks_exist[location - 10 + 1] || blocks_exist[location + 10 + 1]))
                                    location_move <= location + 1;
                                else location_move <= location;
                            end
                            default:;
                        endcase
                    end
                    default:;
                endcase
                game_next_state_move <= `GENERATE_PIECE;
                reg_move_left <= 1'b0;
                reg_move_right <= 1'b0;
            end  
        end
    end
    endmodule
