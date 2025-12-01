`timescale 1ns / 1ps
`include "tetris_states.vh"

module blocks_active_manager(
    input [2:0] game_current_state,
    input [2:0] current_block_type,
    input [1:0] current_block_rotation,
    input [7:0] location,
    output reg [7:0] pos0,
    output reg [7:0] pos1,
    output reg [7:0] pos2,
    output reg [7:0] pos3
);

    always @(*) begin
        pos0 = 8'd255;
        pos1 = 8'd255;
        pos2 = 8'd255;
        pos3 = 8'd255;
        
        if (game_current_state != `INITIAL && game_current_state != `CLEAR_ROW) begin
            case(current_block_type)
                `SQUARE: begin
                    pos0 = location;
                    pos1 = location + 1;
                    pos2 = location - 10;
                    pos3 = location - 9;
                end
                `BAR: begin
                    case(current_block_rotation)
                        2'b00, 2'b10: begin 
                            pos0 = location;
                            pos1 = location - 1;
                            pos2 = location + 1;
                            pos3 = location + 2;
                        end
                        2'b01, 2'b11: begin 
                            pos0 = location;
                            pos1 = location + 10;
                            pos2 = location - 10;
                            pos3 = location - 20;
                        end
                    endcase
                end
                `S: begin
                    case(current_block_rotation)
                        2'b00, 2'b10: begin 
                            pos0 = location;
                            pos1 = location + 1;
                            pos2 = location - 10;
                            pos3 = location - 11;
                        end
                        2'b01, 2'b11: begin 
                            pos0 = location;
                            pos1 = location - 10;
                            pos2 = location - 9;
                            pos3 = location - 19;
                        end
                    endcase
                end
                `Z: begin
                    case(current_block_rotation)
                        2'b00, 2'b10: begin 
                            pos0 = location;
                            pos1 = location + 1;
                            pos2 = location - 9;
                            pos3 = location - 8;
                        end
                        2'b01, 2'b11: begin 
                            pos0 = location + 1;
                            pos1 = location - 9;
                            pos2 = location - 10;
                            pos3 = location - 20;
                        end
                    endcase
                end
                `L: begin
                    case(current_block_rotation)
                        2'b00: begin 
                            pos0 = location;
                            pos1 = location - 10;
                            pos2 = location - 20;
                            pos3 = location - 19;
                        end
                        2'b01: begin 
                            pos0 = location;
                            pos1 = location + 1;
                            pos2 = location + 2;
                            pos3 = location - 10;
                        end
                        2'b10: begin 
                            pos0 = location;
                            pos1 = location + 1;
                            pos2 = location - 9;
                            pos3 = location - 19;
                        end
                        2'b11: begin 
                            pos0 = location + 2;
                            pos1 = location - 8;
                            pos2 = location - 9;
                            pos3 = location - 10;
                        end
                    endcase
                end
                `J: begin
                    case(current_block_rotation)
                        2'b00: begin 
                            pos0 = location;
                            pos1 = location - 10;
                            pos2 = location - 20;
                            pos3 = location - 21;
                        end
                        2'b01: begin 
                            pos0 = location - 1;
                            pos1 = location - 11;
                            pos2 = location - 10;
                            pos3 = location - 9;
                        end
                        2'b10: begin 
                            pos0 = location;
                            pos1 = location - 1;
                            pos2 = location - 11;
                            pos3 = location - 21;
                        end
                        2'b11: begin 
                            pos0 = location - 1;
                            pos1 = location;
                            pos2 = location + 1;
                            pos3 = location - 9;
                        end
                    endcase
                end
                `T: begin
                    case(current_block_rotation)
                        2'b00: begin 
                            pos0 = location;
                            pos1 = location - 1;
                            pos2 = location + 1;
                            pos3 = location - 10;
                        end
                        2'b01: begin 
                            pos0 = location;
                            pos1 = location + 10;
                            pos2 = location - 10;
                            pos3 = location - 1;
                        end
                        2'b10: begin 
                            pos0 = location;
                            pos1 = location + 10;
                            pos2 = location + 1;
                            pos3 = location - 1;
                        end
                        2'b11: begin 
                            pos0 = location;
                            pos1 = location + 10;
                            pos2 = location - 10;
                            pos3 = location + 1;
                        end
                    endcase
                end
                default: ;
            endcase
        end 
    end
endmodule
