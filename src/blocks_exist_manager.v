`timescale 1ns / 1ps
`include "tetris_states.vh"

module blocks_exist_manager(
    input clk,
    input rst_n,
    input [2:0] game_current_state,
    input [199:0] blocks_exist_initial,
    input [199:0] blocks_exist_collision,
    input [199:0] blocks_exist_clear,
    input done_clear,
    input done_collision,
    output reg [199:0] blocks_exist
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            blocks_exist <= {200{1'b0}};
        end else begin
            case (game_current_state)
                `INITIAL: begin
                    // initialize
                    blocks_exist <= blocks_exist_initial;
                end
                
                `COLLISION: begin
                    // wait for blocks_exist_collision to change then update
                    if (done_collision)
                        blocks_exist <= blocks_exist_collision;
                end
                
                `CLEAR_ROW: begin
                    // wait for blocks_exist_clear to change then update
                    if (done_clear)
                        blocks_exist <= blocks_exist_clear;
                end
                default: begin
                    blocks_exist <= blocks_exist;
                end
            endcase
        end
    end

endmodule