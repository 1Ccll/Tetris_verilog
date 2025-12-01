`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module block_state_manager(
    input clk,
    input rst_n,
    input [2:0] game_current_state,
    input [2:0] rand_num1, 
    input [2:0] rand_num2,
    input [1:0] rand_num3, 
    input [1:0] rand_num4,
    input done_rotate,
    //current_block_rotation
    input [1:0] current_block_rotation_rotate,
    output reg [1:0] current_block_rotation,
    //current_block_type
    output reg [2:0] current_block_type,
    //next_block_rotation
    output reg [1:0] next_block_rotation,
    //next_block_type
    output reg [2:0] next_block_type
);
    reg start_update_state;
    always@(posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            current_block_rotation <= 2'b00;
            current_block_type <= 3'b000;
            next_block_rotation <= 2'b00;
            next_block_type <= 3'b000;
            start_update_state <= 1'b0;
        end
        else begin
            case (game_current_state)
                `INITIAL: begin
                    if (!start_update_state) begin
                        current_block_type <= rand_num1;
                        next_block_type <= rand_num2;
                        current_block_rotation <= rand_num3;
                        next_block_rotation <= rand_num4;
                        start_update_state <= 1'b1;
                    end
                end
                `ROTATE_PIECE: begin
                    if (done_rotate)begin
                        current_block_rotation <= current_block_rotation_rotate;
                    end
                end
                `CLEAR_ROW: begin
                    if (!start_update_state)begin
                        current_block_type <= next_block_type;
                        current_block_rotation <= next_block_rotation;
                        next_block_type <= rand_num2;
                        next_block_rotation <= rand_num4;
                        start_update_state <= 1'b1;
                    end
                end
                default: start_update_state <= 1'b0;
            endcase
        end
    end
endmodule
