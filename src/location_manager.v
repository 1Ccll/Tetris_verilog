`timescale 1ns / 1ps
`include "tetris_states.vh"

module location_manager(
    input clk,
    input rst_n,
    input [2:0] game_current_state,
    input en_fall,
    input [2:0] game_next_state,
    input [7:0] location_move,
    input [7:0] location_tobottom,
    input done_tobottom,
    input will_collide_below,
    output reg [7:0] location,
    output reg [7:0] location_prev
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            location_prev <= 8'd194; 
        end
        else begin
            location_prev <= location;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            location <= 8'd194;
        end 
        else if (game_current_state != `TOBOTTOM && game_next_state == `COLLISION)begin
            location <= location;
        end
        else begin
            case (game_current_state)
                `INITIAL: begin
                    location <= 8'd194;
                end
                `GENERATE_PIECE: begin
                    if (en_fall && !will_collide_below)begin
                        location <= location - 10;
                    end
                end
                `ROTATE_PIECE: begin
                    if (en_fall && !will_collide_below)
                        location <= location - 10;
                    else;
                end
                `COLLISION: begin
                    location <= location;
                end
                `CLEAR_ROW: begin
                    if (location == 8'd194 && will_collide_below)begin
                        location <= 8'd214;
                    end
                    else if (location != 8'd214)begin
                        location <= 8'd194;
                    end
                    else ;
                end
                `MOVE: begin
                    if (en_fall) begin
                        location <= location - 10;
                    end 
                    else begin
                        location <= location_move;
                    end
                end
                `TOBOTTOM: begin
                    if (done_tobottom)begin
                        location <= location_tobottom;
                    end
                    else begin
                        location <= location;
                    end
                end
                `LOSE: begin
                    location <= location;
                end
                default: begin
                    location <= location;
                end
            endcase
        end
    end

endmodule