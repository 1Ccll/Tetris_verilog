`timescale 1ns / 1ps
`include "tetris_states.vh"

module tobottom_move(
    input  wire         clk,
    input  wire         rst_n,
    input  wire [2:0]   game_current_state,
    input  wire [199:0] blocks_exist,
    input  wire [2:0]   current_block_type,
    input  wire [1:0]   current_block_rotation,
    input  wire [7:0]   location,
    output reg          done_tobottom,
    output reg  [2:0]   game_next_state_tobottom,
    output reg  [7:0]   location_tobottom
);

    reg [7:0] location_temp;
    reg       start;
    reg       delay_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start                    <= 1'b0;
            done_tobottom            <= 1'b0;
            location_temp            <= 8'd194;
            location_tobottom        <= 8'd194;
            game_next_state_tobottom <= `TOBOTTOM;
            delay_state              <= 1'b0;
        end 
        else begin
            if (game_current_state == `TOBOTTOM) begin
                if (delay_state == 1'b0) begin
                    // Phase 1: Initialization
                    if (!start) begin
                        done_tobottom            <= 1'b0;
                        start                    <= 1'b1;
                        location_tobottom        <= location;
                        location_temp            <= location;
                        game_next_state_tobottom <= `TOBOTTOM;
                    end 
                    // Phase 2: Iterative drop calculation
                    else begin
                        // check_if_collision verifies if the block at 'location_temp'
                        // is supported by an obstacle immediately below it.
                        if (check_if_collision(location_temp, current_block_type, current_block_rotation, blocks_exist)) begin
                            // If collision detected below, location_temp is the valid resting spot.
                            start                    <= 1'b0;
                            done_tobottom            <= 1'b1;
                            location_tobottom        <= location_temp;
                            delay_state              <= 1'b1;
                            game_next_state_tobottom <= `TOBOTTOM;
                        end 
                        else begin
                            // No obstacle below, continue searching downwards (move -10)
                            location_temp <= location_temp - 10;
                        end
                    end
                end 
                else begin
                    // Phase 3: Handshake delay to allow external modules to latch data
                    game_next_state_tobottom <= `COLLISION;
                end
            end 
            else begin
                // Reset internal state when not in TOBOTTOM mode
                start                    <= 1'b0;
                done_tobottom            <= 1'b0;
                delay_state              <= 1'b0;
                game_next_state_tobottom <= `TOBOTTOM;
            end
        end
    end

    // Function: Check Bottom Collision
    // Checks if the block at 'loc' has obstacles directly underneath (loc - 10/20/30)
    // or has reached the floor.
    function check_if_collision;
        input [7:0]   loc;
        input [2:0]   block_type;
        input [1:0]   rotation;
        input [199:0] exist_blocks;
        reg           collision;
        begin
            collision = 0;
            case(block_type)
                `SQUARE: begin 
                    if (loc < 20 || exist_blocks[loc - 20] || exist_blocks[loc - 19] || exist_blocks[loc - 10] || exist_blocks[loc - 9]) //later写在报告里
                    collision = 1'b1;
                end
                `BAR: begin
                    case(rotation)
                        2'b00, 2'b10: begin 
                            if (loc < 10 || exist_blocks[loc-10] || exist_blocks[loc-11] || exist_blocks[loc-9] || exist_blocks[loc-8]) 
                                collision = 1'b1;
                        end
                        2'b01, 2'b11: begin 
                            if (loc < 30 || exist_blocks[loc - 30] || exist_blocks[loc - 10]) 
                                collision = 1'b1;
                        end
                    endcase
                end
                `S: begin
                    case(rotation)
                        2'b00, 2'b10: begin 
                            if (loc < 20 || exist_blocks[loc - 20] || exist_blocks[loc - 21] || exist_blocks[loc - 9] || exist_blocks[loc - 10] || exist_blocks[loc - 11]) 
                                collision = 1'b1;
                        end
                        2'b01, 2'b11: begin
                            if (loc < 29 || exist_blocks[loc - 20] || exist_blocks[loc - 29] || exist_blocks[loc -10] || exist_blocks[loc - 9]) 
                                collision = 1'b1;
                        end
                    endcase
                end
                `Z: begin
                    case(rotation)
                        2'b00, 2'b10: begin 
                            if (loc < 19 || exist_blocks[loc - 10] || exist_blocks[loc - 18] || exist_blocks[loc - 19] || exist_blocks[loc - 9] || exist_blocks[loc - 8]) 
                            collision = 1'b1;
                        end
                        2'b01, 2'b11: begin 
                            if (loc < 30 || exist_blocks[loc - 19] || exist_blocks[loc - 30] || exist_blocks[loc - 10] || exist_blocks[loc - 9]) 
                            collision = 1'b1;
                        end
                    endcase
                end
                `L: begin
                    case(rotation)
                        2'b00: begin
                            if (loc < 30 || exist_blocks[loc - 30] || exist_blocks[loc - 29] || exist_blocks[loc - 10]) 
                            collision = 1'b1;
                        end
                        2'b01: begin
                            if (loc < 20 || exist_blocks[loc - 20] || exist_blocks[loc - 9] || exist_blocks[loc - 8] || exist_blocks[loc - 10]) 
                            collision = 1'b1;
                        end
                        2'b10: begin
                            if (loc < 29 || exist_blocks[loc - 10] || exist_blocks[loc - 29] || exist_blocks[loc - 9]) 
                            collision = 1'b1;
                        end
                        2'b11: begin
                            if (loc < 20 || exist_blocks[loc - 18] || exist_blocks[loc - 19] || exist_blocks[loc - 20] || exist_blocks[loc - 10] || exist_blocks[loc - 9] || exist_blocks[loc - 8]) 
                            collision = 1'b1;
                        end
                    endcase
                end
                `J: begin
                    case(rotation)
                        2'b00: begin
                            if (loc < 31 || exist_blocks[loc - 30] || exist_blocks[loc - 31] || exist_blocks[loc - 10]) 
                            collision = 1'b1;
                        end
                        2'b01: begin
                            if (loc < 21 || exist_blocks[loc - 21] || exist_blocks[loc - 20] || exist_blocks[loc - 19] || exist_blocks[loc - 10] || exist_blocks[loc - 9] || exist_blocks[loc - 11]) 
                            collision = 1'b1;
                        end
                        2'b10: begin
                            if (loc < 31 || exist_blocks[loc - 10] || exist_blocks[loc - 31] || exist_blocks[loc - 11]) 
                            collision = 1'b1;
                        end
                        2'b11: begin
                            if (loc < 19 || exist_blocks[loc - 11] || exist_blocks[loc - 10] || exist_blocks[loc - 19] || exist_blocks[loc - 9]) 
                            collision = 1'b1;
                        end
                    endcase
                end
                `T: begin
                    case(rotation)
                        2'b00: begin
                            if (loc < 20 || exist_blocks[loc - 11] || exist_blocks[loc - 9] || exist_blocks[loc - 20] || exist_blocks[loc - 10]) 
                            collision = 1'b1;
                        end
                        2'b01: begin
                            if (loc < 20 || exist_blocks[loc - 20] || exist_blocks[loc - 11] || exist_blocks[loc - 10]) 
                            collision = 1'b1;
                        end
                        2'b10: begin
                            if (loc < 11 || exist_blocks[loc - 10] || exist_blocks[loc - 9] || exist_blocks[loc - 11] || exist_blocks[loc - 10] || exist_blocks[loc - 9] || exist_blocks[loc - 11]) 
                            collision = 1'b1;
                        end
                        2'b11: begin
                            if (loc < 20 || exist_blocks[loc - 20] || exist_blocks[loc - 9] || exist_blocks[loc - 10]) 
                            collision = 1'b1;
                        end
                    endcase
                end
                default: collision = 1'b0;
            endcase
            check_if_collision = collision;
        end
            
    endfunction

endmodule