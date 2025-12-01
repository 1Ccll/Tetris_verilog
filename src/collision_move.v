`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module collision_move(
    input clk,
    input rst_n,
    input [2:0] game_current_state,
    input [199:0] blocks_exist,
    input[7:0] active_pos0,
    input wire [7:0] active_pos1,
    input wire [7:0] active_pos2,
    input wire [7:0] active_pos3,
    input [2:0] current_block_type,
    input [1:0] current_block_rotation,
    input [7:0] location_prev,
    output reg [199:0] blocks_exist_collision,
    output reg [2:0] game_next_state_collision,
    output reg start_collision,
    output reg done_collision
);
    
    always@(posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            start_collision <= 1'b0;
            blocks_exist_collision <= {199{1'b0}};
            game_next_state_collision <= `COLLISION;
            done_collision <= 1'b0;
        end
        else begin
            if (game_current_state == `COLLISION)begin
                blocks_exist_collision <= blocks_exist;
                if ((active_pos0 >= 193 && active_pos0 <= 196) || 
                    (active_pos1 >= 193 && active_pos1 <= 196) ||
                    (active_pos2 >= 193 && active_pos2 <= 196) ||
                    (active_pos3 >= 193 && active_pos3 <= 196))begin
                    game_next_state_collision <= `LOSE;                   
                end
                else if (!start_collision)begin
                    start_collision <= 1'b1;
                end
                else if (start_collision)begin
                    game_next_state_collision <= `CLEAR_ROW;
                    start_collision <= 1'b0;
                    done_collision <= 1'b1;
                    case(current_block_type)
                        `SQUARE: begin
                            if (location_prev < 200) 
                                blocks_exist_collision[location_prev] <= 1'b1;
                            if (location_prev + 1 < 200) 
                                blocks_exist_collision[location_prev + 1] <= 1'b1;         
                            if (location_prev >= 10) 
                                blocks_exist_collision[location_prev - 10] <= 1'b1;       
                            if (location_prev >= 9) 
                                blocks_exist_collision[location_prev - 9] <= 1'b1;
                        end
                        `BAR: begin
                            case(current_block_rotation)
                                2'b00, 2'b10: begin
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev >= 1) 
                                        blocks_exist_collision[location_prev - 1] <= 1'b1;  
                                    if (location_prev + 1 < 200) 
                                        blocks_exist_collision[location_prev + 1] <= 1'b1; 
                                    if (location_prev + 2 < 200) 
                                        blocks_exist_collision[location_prev + 2] <= 1'b1;
                                end
                                2'b01, 2'b11: begin
                                    if (location_prev + 10 < 200) 
                                        blocks_exist_collision[location_prev + 10] <= 1'b1;
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                    if (location_prev >= 20) 
                                        blocks_exist_collision[location_prev - 20] <= 1'b1;
                                end
                            endcase
                        end
                        `S: begin
                            case(current_block_rotation)
                                2'b00, 2'b10: begin
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;        
                                    if (location_prev + 1 < 200) 
                                        blocks_exist_collision[location_prev + 1] <= 1'b1;      
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                    if (location_prev >= 11) 
                                        blocks_exist_collision[location_prev - 11] <= 1'b1;
                                end
                                2'b01, 2'b11: begin
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                    if (location_prev >= 9) 
                                        blocks_exist_collision[location_prev - 9] <= 1'b1;
                                    if (location_prev >= 19) 
                                        blocks_exist_collision[location_prev - 19] <= 1'b1;
                                end
                            endcase
                        end
                        `Z: begin
                            case(current_block_rotation)
                                2'b00, 2'b10: begin
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev + 1 < 200) 
                                        blocks_exist_collision[location_prev + 1] <= 1'b1;
                                    if (location_prev >= 9) 
                                        blocks_exist_collision[location_prev - 9] <= 1'b1;
                                    if (location_prev >= 8) 
                                        blocks_exist_collision[location_prev - 8] <= 1'b1;
                                end
                                2'b01, 2'b11: begin
                                    if (location_prev + 1 < 200) 
                                        blocks_exist_collision[location_prev + 1] <= 1'b1;
                                    if (location_prev >= 9) 
                                        blocks_exist_collision[location_prev - 9] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                    if (location_prev >= 20) 
                                        blocks_exist_collision[location_prev - 20] <= 1'b1;
                                end
                            endcase
                        end
                        `L: begin
                            case(current_block_rotation)
                                2'b00: begin
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                    if (location_prev >= 20) 
                                        blocks_exist_collision[location_prev - 20] <= 1'b1;
                                    if (location_prev >= 19) 
                                        blocks_exist_collision[location_prev - 19] <= 1'b1;
                                end
                                2'b01: begin
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev + 1 < 200) 
                                        blocks_exist_collision[location_prev + 1] <= 1'b1;
                                    if (location_prev + 2 < 200) 
                                        blocks_exist_collision[location_prev + 2] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                end
                                2'b10: begin
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev + 1 < 200) 
                                        blocks_exist_collision[location_prev + 1] <= 1'b1;
                                    if (location_prev >= 9) 
                                        blocks_exist_collision[location_prev - 9] <= 1'b1;
                                    if (location_prev >= 19) 
                                        blocks_exist_collision[location_prev - 19] <= 1'b1;
                                end
                                2'b11: begin
                                    if (location_prev + 2 < 200) 
                                        blocks_exist_collision[location_prev + 2] <= 1'b1;
                                    if (location_prev >= 8) 
                                        blocks_exist_collision[location_prev - 8] <= 1'b1;
                                    if (location_prev >= 9) 
                                        blocks_exist_collision[location_prev - 9] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                end
                            endcase
                        end
                        `J: begin
                            case(current_block_rotation)
                                2'b00: begin
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                    if (location_prev >= 20) 
                                        blocks_exist_collision[location_prev - 20] <= 1'b1;
                                    if (location_prev >= 21) 
                                        blocks_exist_collision[location_prev - 21] <= 1'b1;
                                end
                                2'b01: begin
                                    if (location_prev >= 1) 
                                        blocks_exist_collision[location_prev - 1] <= 1'b1;
                                    if (location_prev >= 11) 
                                        blocks_exist_collision[location_prev - 11] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                    if (location_prev >= 9) 
                                        blocks_exist_collision[location_prev - 9] <= 1'b1;
                                end
                                2'b10: begin
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev >= 1) 
                                        blocks_exist_collision[location_prev - 1] <= 1'b1;
                                    if (location_prev >= 11) 
                                        blocks_exist_collision[location_prev - 11] <= 1'b1;
                                    if (location_prev >= 21) 
                                        blocks_exist_collision[location_prev - 21] <= 1'b1;
                                end
                                2'b11: begin
                                    if (location_prev >= 1) 
                                        blocks_exist_collision[location_prev - 1] <= 1'b1;
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev + 1 < 200) 
                                        blocks_exist_collision[location_prev + 1] <= 1'b1;
                                    if (location_prev >= 9) 
                                        blocks_exist_collision[location_prev - 9] <= 1'b1;
                                end
                            endcase
                        end
                        `T: begin
                            case(current_block_rotation)
                                2'b00: begin 
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev >= 1) 
                                        blocks_exist_collision[location_prev - 1] <= 1'b1;
                                    if (location_prev + 1 < 200) 
                                        blocks_exist_collision[location_prev + 1] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                end
                                2'b01: begin 
                                    if (location_prev + 10 < 200) 
                                        blocks_exist_collision[location_prev + 10] <= 1'b1;
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev >= 1) 
                                        blocks_exist_collision[location_prev - 1] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                end
                                2'b10: begin 
                                    if (location_prev + 10 < 200) 
                                        blocks_exist_collision[location_prev + 10] <= 1'b1;
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev + 1 < 200) 
                                        blocks_exist_collision[location_prev + 1] <= 1'b1;
                                    if (location_prev >= 1) 
                                        blocks_exist_collision[location_prev - 1] <= 1'b1;
                                end
                                2'b11: begin 
                                    if (location_prev + 10 < 200) 
                                        blocks_exist_collision[location_prev + 10] <= 1'b1;
                                    if (location_prev < 200) 
                                        blocks_exist_collision[location_prev] <= 1'b1;
                                    if (location_prev >= 10) 
                                        blocks_exist_collision[location_prev - 10] <= 1'b1;
                                    if (location_prev + 1 < 200) 
                                        blocks_exist_collision[location_prev + 1] <= 1'b1;
                                end
                            endcase
                        end
                    endcase
                end
                else begin
                    game_next_state_collision <= `COLLISION;
                    done_collision <= 1'b0;
                end
            end
            else begin
                done_collision <= 1'b0;
                start_collision <= 1'b0;
                game_next_state_collision <= `COLLISION;
            end
        end
    end
endmodule