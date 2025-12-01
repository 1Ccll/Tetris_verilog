`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module rotate_piece_move(
   input clk,
   input rst_n,
   input [2:0] game_current_state,
   input [7:0] location,
   input [199:0] blocks_exist,
   input [2:0] current_block_type,
   input [1:0] current_block_rotation,
   input [255:0] is_col_9,
   output reg [1:0] current_block_rotation_rotate,
   output reg done_rotate,
   output reg [2:0] game_next_state_rotate
);
    reg [1:0] start_rotate;
    always@(posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            start_rotate <= 2'b00;
            current_block_rotation_rotate <= 2'b00;
            game_next_state_rotate <= `ROTATE_PIECE;
            done_rotate <= 1'b0;
        end
        else begin
            if (game_current_state == `ROTATE_PIECE)begin
                if (start_rotate == 2'b00)begin
                    start_rotate <= 2'b01;
                    current_block_rotation_rotate <= current_block_rotation;
                    game_next_state_rotate <= `ROTATE_PIECE;
                end
                else if (start_rotate == 2'b01)begin
                    case(current_block_type)
                        `SQUARE:begin 
                            current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                        end
                        `BAR:begin
                            case(current_block_rotation_rotate)
                                2'b00, 2'b10: begin
                                    if (location < 20 || blocks_exist[location] || (location + 10 < 200 && blocks_exist[location + 10]) || blocks_exist[location - 10] || blocks_exist[location - 20])
                                    ;
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b01, 2'b11: begin
                                    if (is_col_9[location + 1] || is_col_9[location] || is_col_9[location - 1] || blocks_exist[location] || blocks_exist[location - 1] || blocks_exist[location + 1] || blocks_exist[location + 2])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;   
                                    end
                                end
                                default:;
                            endcase
                        end
                        `S:begin
                            case(current_block_rotation_rotate)
                                2'b00: begin
                                    if (location < 20 || blocks_exist[location] || blocks_exist[location - 10] || blocks_exist[location - 10 + 1] || blocks_exist[location - 20 + 1])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b01: begin
                                    if (blocks_exist[location] || blocks_exist[location + 1] || blocks_exist[location - 10] || blocks_exist[location - 10 - 1])
                                    ;   
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b10: begin
                                    if (location < 20 || blocks_exist[location] || blocks_exist[location - 10] || blocks_exist[location - 10 + 1] || blocks_exist[location - 20 + 1])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b11: begin
                                    if (blocks_exist[location] || blocks_exist[location + 1] || blocks_exist[location - 10] || blocks_exist[location - 10 - 1])
                                    ;   
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                default:;
                            endcase
                        end
                        `Z:begin
                            case(current_block_rotation_rotate)
                                2'b00: begin
                                    if (location < 20 || blocks_exist[location + 1] || blocks_exist[location + 1 - 10] || blocks_exist[location - 10] || blocks_exist[location - 20])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;  
                                    end
                                end
                                2'b01: begin
                                    if (blocks_exist[location] || blocks_exist[location + 1] || blocks_exist[location + 1 - 10] || blocks_exist[location + 2 - 10])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b10: begin
                                    if (location < 20 || blocks_exist[location + 1] || blocks_exist[location + 1 - 10] || blocks_exist[location - 10] || blocks_exist[location - 20])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;  
                                    end
                                end
                                2'b11: begin
                                        if (blocks_exist[location] || blocks_exist[location + 1] || blocks_exist[location + 1 - 10] || blocks_exist[location + 2 - 10])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                default:;
                            endcase
                        end
                        `L:begin
                            case(current_block_rotation_rotate)
                                2'b00: begin
                                    if (is_col_9[location] || blocks_exist[location] || blocks_exist[location + 1] || blocks_exist[location + 2] || blocks_exist[location - 10])   
                                    ;
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b01: begin
                                    if (location < 20 || blocks_exist[location] || blocks_exist[location + 1] || blocks_exist[location + 1 - 10] || blocks_exist[location + 1 - 20])
                                    ;      
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b10: begin
                                    if (is_col_9[location + 1] || blocks_exist[location + 2] || blocks_exist[location + 2 - 10] || blocks_exist[location + 1 - 10] || blocks_exist[location - 10])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b11: begin //cant rotate when stick to the ground
                                    if (location < 20 ||  blocks_exist[location] || blocks_exist[location - 10] || blocks_exist[location - 20] || blocks_exist[location - 20 + 1])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;  
                                    end
                                end
                                default:;
                            endcase
                        end
                        `J:begin
                            case(current_block_rotation_rotate)
                                2'b00: begin
                                    if (is_col_9[location] || blocks_exist[location - 1] || blocks_exist[location - 1 - 10] || blocks_exist[location - 10] || blocks_exist[location - 10 + 1])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b01: begin
                                    if (location  < 20 || blocks_exist[location] || blocks_exist[location - 1] || blocks_exist[location - 1 - 10] || blocks_exist[location - 1 - 20])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;  
                                    end
                                end
                                2'b10: begin
                                    if (is_col_9[location] || blocks_exist[location - 1] || blocks_exist[location] || blocks_exist[location + 1] || blocks_exist[location - 10 + 1])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1; 
                                    end
                                end
                                2'b11: begin
                                    if (location < 20 || blocks_exist[location] || blocks_exist[location - 10] || blocks_exist[location - 20] || blocks_exist[location - 20 - 1])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                default:;
                            endcase
                        end
                        `T:begin
                            case(current_block_rotation_rotate)
                                2'b00: begin
                                    if (blocks_exist[location] || (location + 10 < 200 && blocks_exist[location + 10]) || blocks_exist[location - 1] || blocks_exist[location - 10])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b01: begin
                                    if (is_col_9[location] || blocks_exist[location] || (location + 10 < 200 && blocks_exist[location + 10]) || blocks_exist[location + 1] || blocks_exist[location - 1])
                                    ;   
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b10: begin
                                    if (blocks_exist[location] || (location + 10 < 200 && blocks_exist[location + 10]) || blocks_exist[location + 1] || blocks_exist[location - 10])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                2'b11: begin
                                    if (is_col_9[location - 1] || blocks_exist[location] || blocks_exist[location - 1] || blocks_exist[location + 1] || blocks_exist[location - 10])
                                    ;    
                                    else begin
                                        current_block_rotation_rotate <= current_block_rotation_rotate + 1;
                                    end
                                end
                                default:;
                            endcase
                        end
                        default;
                    endcase
                    game_next_state_rotate <= `GENERATE_PIECE;
                    start_rotate <= 2'b10;
                    done_rotate <= 1'b1;
                end
                else if (start_rotate == 2'b10)begin
                    start_rotate <= 2'b00;
                    done_rotate <= 1'b0;
                    game_next_state_rotate <= `ROTATE_PIECE;
                end
            end
            else;
        end 
    end
endmodule