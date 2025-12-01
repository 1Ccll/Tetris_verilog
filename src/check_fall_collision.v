`timescale 1ns / 1ps
`include "tetris_states.vh"

module check_fall_collision(
    input [7:0] current_loc,
    input [2:0] block_type,
    input [1:0] rotation,
    input [199:0] blocks_exist,
    output reg will_collide_below 
);
    //combinational logic
    always @(*) begin
        // default
        will_collide_below = 1'b0;
        case(block_type)
            `SQUARE: begin 
                if (current_loc < 20 || blocks_exist[current_loc - 20] || blocks_exist[current_loc - 19] || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 9]) //later写在报告里
                will_collide_below = 1'b1;
            end
            
            `BAR: begin
                case(rotation)
                    2'b00, 2'b10: begin 
                        if (current_loc < 10 || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 11] || blocks_exist[current_loc - 9] || blocks_exist[current_loc - 8]) 
                            will_collide_below = 1'b1;
                    end
                    2'b01, 2'b11: begin 
                        if (current_loc < 30 || blocks_exist[current_loc - 30] || blocks_exist[current_loc - 10]) 
                            will_collide_below = 1'b1;
                    end
                endcase
            end
            
            `S: begin
                case(rotation)
                    2'b00, 2'b10: begin 
                        if (current_loc < 20 || blocks_exist[current_loc - 20] || blocks_exist[current_loc - 21] || blocks_exist[current_loc - 9] || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 11]) 
                            will_collide_below = 1'b1;
                    end
                    2'b01, 2'b11: begin
                        if (current_loc < 29 || blocks_exist[current_loc - 20] || blocks_exist[current_loc - 29] || blocks_exist[current_loc -10] || blocks_exist[current_loc - 9]) 
                            will_collide_below = 1'b1;
                    end
                endcase
            end
            
            `Z: begin
                case(rotation)
                    2'b00, 2'b10: begin 
                        if (current_loc < 19 || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 18] || blocks_exist[current_loc - 19] || blocks_exist[current_loc - 9] || blocks_exist[current_loc - 8]) 
                        will_collide_below = 1'b1;
                    end
                    2'b01, 2'b11: begin 
                        if (current_loc < 30 || blocks_exist[current_loc - 19] || blocks_exist[current_loc - 30] || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 9]) 
                        will_collide_below = 1'b1;
                    end
                endcase
            end
            
            `L: begin
                case(rotation)
                    2'b00: begin
                        if (current_loc < 30 || blocks_exist[current_loc - 30] || blocks_exist[current_loc - 29] || blocks_exist[current_loc - 10]) 
                        will_collide_below = 1'b1;
                    end
                    2'b01: begin
                        if (current_loc < 20 || blocks_exist[current_loc - 20] || blocks_exist[current_loc - 9] || blocks_exist[current_loc - 8] || blocks_exist[current_loc - 10]) 
                        will_collide_below = 1'b1;
                    end
                    2'b10: begin
                        if (current_loc < 29 || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 29] || blocks_exist[current_loc - 9]) 
                        will_collide_below = 1'b1;
                    end
                    2'b11: begin
                        if (current_loc < 20 || blocks_exist[current_loc - 18] || blocks_exist[current_loc - 19] || blocks_exist[current_loc - 20] || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 9] || blocks_exist[current_loc - 8]) 
                        will_collide_below = 1'b1;
                    end
                endcase
            end

            `J: begin
                case(rotation)
                    2'b00: begin
                        if (current_loc < 31 || blocks_exist[current_loc - 30] || blocks_exist[current_loc - 31] || blocks_exist[current_loc - 10]) 
                        will_collide_below = 1'b1;
                    end
                    2'b01: begin
                        if (current_loc < 21 || blocks_exist[current_loc - 21] || blocks_exist[current_loc - 20] || blocks_exist[current_loc - 19] || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 9] || blocks_exist[current_loc - 11]) 
                        will_collide_below = 1'b1;
                    end
                    2'b10: begin
                        if (current_loc < 31 || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 31] || blocks_exist[current_loc - 11]) 
                        will_collide_below = 1'b1;
                    end
                    2'b11: begin
                        if (current_loc < 19 || blocks_exist[current_loc - 11] || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 19] || blocks_exist[current_loc - 9]) 
                        will_collide_below = 1'b1;
                    end
                endcase
            end
            
            `T: begin
                case(rotation)
                    2'b00: begin
                        if (current_loc < 20 || blocks_exist[current_loc - 11] || blocks_exist[current_loc - 9] || blocks_exist[current_loc - 20] || blocks_exist[current_loc - 10]) 
                        will_collide_below = 1'b1;
                    end
                    2'b01: begin
                        if (current_loc < 20 || blocks_exist[current_loc - 20] || blocks_exist[current_loc - 11] || blocks_exist[current_loc - 10]) 
                        will_collide_below = 1'b1;
                    end
                    2'b10: begin
                        if (current_loc < 11 || blocks_exist[current_loc - 10] || blocks_exist[current_loc - 9] || blocks_exist[current_loc - 11]) 
                        will_collide_below = 1'b1;
                    end
                    2'b11: begin
                        if (current_loc < 20 || blocks_exist[current_loc - 20] || blocks_exist[current_loc - 9] || blocks_exist[current_loc - 10]) 
                        will_collide_below = 1'b1;
                    end
                endcase
            end
            default: will_collide_below = 1'b0;
        endcase
    end
endmodule