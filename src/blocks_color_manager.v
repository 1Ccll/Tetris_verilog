`timescale 1ns / 1ps
`include "tetris_states.vh"

module blocks_color_manager(
    input  wire         clk,
    input  wire         rst_n,
    input  wire [2:0]   game_current_state,
    input  wire         done_collision,
    input  wire         done_clear,
    input  wire [19:0]  is_full_row,
    input  wire [7:0]   location_prev,
    input  wire [2:0]   current_block_type,
    input  wire [1:0]   current_block_rotation,
    input  wire [7:0]   vga_read_addr,
    output wire [2:0]   vga_read_data
);

    // 10x20 grid memory (200 blocks)
    reg [2:0] color_ram [0:199];

    // Input Latching Logic
    reg [2:0] latched_block_type;
    reg [7:0] latched_location;
    reg [1:0] latched_rotation;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            latched_block_type <= 3'b000;
            latched_location   <= 8'd0;
            latched_rotation   <= 2'b00;
        end 
        else begin
            // 1. Block Type and Rotation: Lock during COLLISION to prevent data corruption
            case(game_current_state)
                `GENERATE_PIECE, `MOVE, `ROTATE_PIECE, `TOBOTTOM, `INITIAL: begin
                    latched_block_type <= current_block_type;
                    latched_rotation   <= current_block_rotation;
                end
                default: begin
                    // Hold current values during COLLISION and CLEAR_ROW
                    latched_block_type <= latched_block_type;
                    latched_rotation   <= latched_rotation;
                end
            endcase

            // 2. Location: Must update during COLLISION
            // location_prev settles one cycle late; blocking update here would lock stale coordinates.
            case(game_current_state)
                `GENERATE_PIECE, `MOVE, `ROTATE_PIECE, `TOBOTTOM, `INITIAL, `COLLISION: begin
                    latched_location <= location_prev;
                end
                default: begin
                    // Lock location only during CLEAR_ROW (when coord resets to spawn point)
                    latched_location <= latched_location;
                end
            endcase
        end
    end

    // Coordinate Calculation (Combinatorial)
    // Calculates the 4 target memory indices based on latched data
    reg [7:0] dest_pos [0:3];

    always @(*) begin
        // Default invalid position (255)
        dest_pos[0] = 255; 
        dest_pos[1] = 255; 
        dest_pos[2] = 255; 
        dest_pos[3] = 255;

        case(latched_block_type)
            `SQUARE: begin
                dest_pos[0] = latched_location;
                dest_pos[1] = latched_location + 1;
                if (latched_location >= 10) begin
                    dest_pos[2] = latched_location - 10;
                end
                if (latched_location >= 9) begin
                    dest_pos[3] = latched_location - 9;
                end
            end
            `BAR: begin
                case(latched_rotation)
                    2'b00, 2'b10: begin // Horizontal
                        dest_pos[0] = latched_location;
                        if (latched_location >= 1) begin
                            dest_pos[1] = latched_location - 1;
                        end
                        dest_pos[2] = latched_location + 1;
                        dest_pos[3] = latched_location + 2;
                    end
                    2'b01, 2'b11: begin // Vertical
                        dest_pos[0] = latched_location + 10;
                        dest_pos[1] = latched_location;
                        if (latched_location >= 10) begin
                            dest_pos[2] = latched_location - 10;
                        end
                        if (latched_location >= 20) begin
                            dest_pos[3] = latched_location - 20;
                        end
                    end
                endcase
            end
            `S: begin
                case(latched_rotation)
                    2'b00, 2'b10: begin
                        dest_pos[0] = latched_location;
                        dest_pos[1] = latched_location + 1;
                        if (latched_location >= 10) begin
                            dest_pos[2] = latched_location - 10;
                        end
                        if (latched_location >= 11) begin
                            dest_pos[3] = latched_location - 11;
                        end
                    end
                    2'b01, 2'b11: begin
                        dest_pos[0] = latched_location;
                        if (latched_location >= 10) begin
                            dest_pos[1] = latched_location - 10;
                        end
                        if (latched_location >= 9) begin
                            dest_pos[2] = latched_location - 9;
                        end
                        if (latched_location >= 19) begin
                            dest_pos[3] = latched_location - 19;
                        end
                    end
                endcase
            end
            `Z: begin
                case(latched_rotation)
                    2'b00, 2'b10: begin
                        dest_pos[0] = latched_location;
                        dest_pos[1] = latched_location + 1;
                        if (latched_location >= 9) begin
                            dest_pos[2] = latched_location - 9;
                        end
                        if (latched_location >= 8) begin
                            dest_pos[3] = latched_location - 8;
                        end
                    end
                    2'b01, 2'b11: begin
                        dest_pos[0] = latched_location + 1;
                        if (latched_location >= 9) begin
                            dest_pos[1] = latched_location - 9;
                        end
                        if (latched_location >= 10) begin
                            dest_pos[2] = latched_location - 10;
                        end
                        if (latched_location >= 20) begin
                            dest_pos[3] = latched_location - 20;
                        end
                    end
                endcase
            end
            `L: begin
                case(latched_rotation)
                    2'b00: begin
                        dest_pos[0] = latched_location;
                        if (latched_location >= 10) begin
                            dest_pos[1] = latched_location - 10;
                        end
                        if (latched_location >= 20) begin
                            dest_pos[2] = latched_location - 20;
                        end
                        if (latched_location >= 19) begin
                            dest_pos[3] = latched_location - 19;
                        end
                    end
                    2'b01: begin
                        dest_pos[0] = latched_location;
                        dest_pos[1] = latched_location + 1;
                        dest_pos[2] = latched_location + 2;
                        if (latched_location >= 10) begin
                            dest_pos[3] = latched_location - 10;
                        end
                    end
                    2'b10: begin
                        dest_pos[0] = latched_location;
                        dest_pos[1] = latched_location + 1;
                        if (latched_location >= 9) begin
                            dest_pos[2] = latched_location - 9;
                        end
                        if (latched_location >= 19) begin
                            dest_pos[3] = latched_location - 19;
                        end
                    end
                    2'b11: begin
                        dest_pos[0] = latched_location + 2;
                        if (latched_location >= 8) begin
                            dest_pos[1] = latched_location - 8;
                        end
                        if (latched_location >= 9) begin
                            dest_pos[2] = latched_location - 9;
                        end
                        if (latched_location >= 10) begin
                            dest_pos[3] = latched_location - 10;
                        end
                    end
                endcase
            end
            `J: begin
                case(latched_rotation)
                    2'b00: begin
                        dest_pos[0] = latched_location;
                        if (latched_location >= 10) begin
                            dest_pos[1] = latched_location - 10;
                        end
                        if (latched_location >= 20) begin
                            dest_pos[2] = latched_location - 20;
                        end
                        if (latched_location >= 21) begin
                            dest_pos[3] = latched_location - 21;
                        end
                    end
                    2'b01: begin
                        if (latched_location >= 1) begin
                            dest_pos[0] = latched_location - 1;
                        end
                        if (latched_location >= 11) begin
                            dest_pos[1] = latched_location - 11;
                        end
                        if (latched_location >= 10) begin
                            dest_pos[2] = latched_location - 10;
                        end
                        if (latched_location >= 9) begin
                            dest_pos[3] = latched_location - 9;
                        end
                    end
                    2'b10: begin
                        dest_pos[0] = latched_location;
                        if (latched_location >= 1) begin
                            dest_pos[1] = latched_location - 1;
                        end
                        if (latched_location >= 11) begin
                            dest_pos[2] = latched_location - 11;
                        end
                        if (latched_location >= 21) begin
                            dest_pos[3] = latched_location - 21;
                        end
                    end
                    2'b11: begin
                        if (latched_location >= 1) begin
                            dest_pos[0] = latched_location - 1;
                        end
                        dest_pos[1] = latched_location;
                        dest_pos[2] = latched_location + 1;
                        if (latched_location >= 9) begin
                            dest_pos[3] = latched_location - 9;
                        end
                    end
                endcase
            end
            `T: begin
                case(latched_rotation)
                    2'b00: begin
                        dest_pos[0] = latched_location;
                        if (latched_location >= 1) begin
                            dest_pos[1] = latched_location - 1;
                        end
                        dest_pos[2] = latched_location + 1;
                        if (latched_location >= 10) begin
                            dest_pos[3] = latched_location - 10;
                        end
                    end
                    2'b01: begin
                        dest_pos[0] = latched_location;
                        dest_pos[1] = latched_location + 10;
                        if (latched_location >= 10) begin
                            dest_pos[2] = latched_location - 10;
                        end
                        if (latched_location >= 1) begin
                            dest_pos[3] = latched_location - 1;
                        end
                    end
                    2'b10: begin
                        dest_pos[0] = latched_location;
                        dest_pos[1] = latched_location + 10;
                        dest_pos[2] = latched_location + 1;
                        if (latched_location >= 1) begin
                            dest_pos[3] = latched_location - 1;
                        end
                    end
                    2'b11: begin
                        dest_pos[0] = latched_location;
                        dest_pos[1] = latched_location + 10;
                        if (latched_location >= 10) begin
                            dest_pos[2] = latched_location - 10;
                        end
                        dest_pos[3] = latched_location + 1;
                    end
                endcase
            end
            default: ;
        endcase
    end

    // State Machine: Memory Update and Row Clearing
    localparam S_IDLE        = 0;
    localparam S_WRITE_PIECE = 1;
    localparam S_CLEAR_SCAN  = 2;

    reg [2:0] state;
    reg [2:0] piece_step;
    reg [4:0] read_row;
    reg [4:0] write_row;
    reg [3:0] col_idx;
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            piece_step <= 0;
            read_row   <= 0;
            write_row  <= 0;
            col_idx    <= 0;
            for (i = 0; i < 200; i = i + 1) begin
                color_ram[i] <= 3'b000;
            end
        end 
        else begin
            case (state)
                S_IDLE: begin
                    if (done_collision) begin
                        state      <= S_WRITE_PIECE;
                        piece_step <= 0;
                    end 
                    else if (game_current_state == `CLEAR_ROW && done_clear) begin
                        state     <= S_CLEAR_SCAN;
                        read_row  <= 0;
                        write_row <= 0;
                        col_idx   <= 0;
                    end
                end

                // Write the 4 distinct blocks of the current piece into memory
                S_WRITE_PIECE: begin
                    if (dest_pos[piece_step] < 200) begin
                        color_ram[dest_pos[piece_step]] <= latched_block_type;
                    end

                    if (piece_step == 3) begin
                        state      <= S_IDLE;
                        piece_step <= 0;
                    end 
                    else begin
                        piece_step <= piece_step + 1;
                    end
                end

                // Process full row clearing by shifting valid rows down
                S_CLEAR_SCAN: begin
                    if (read_row < 20) begin
                        if (is_full_row[read_row]) begin
                            // If row is full, skip it (do not copy to write_row)
                            read_row <= read_row + 1;
                            col_idx  <= 0;
                        end 
                        else begin
                            // If row is valid, copy to current write position
                            color_ram[write_row * 10 + col_idx] <= color_ram[read_row * 10 + col_idx];

                            if (col_idx == 9) begin
                                col_idx   <= 0;
                                read_row  <= read_row + 1;
                                write_row <= write_row + 1;
                            end 
                            else begin
                                col_idx <= col_idx + 1;
                            end
                        end
                    end 
                    else begin
                        // Fill the remaining top rows with empty space (zeros)
                        if (write_row < 20) begin
                            color_ram[write_row * 10 + col_idx] <= 3'b000;

                            if (col_idx == 9) begin
                                col_idx   <= 0;
                                write_row <= write_row + 1;
                            end 
                            else begin
                                col_idx <= col_idx + 1;
                            end
                        end 
                        else begin
                            state <= S_IDLE;
                        end
                    end
                end
            endcase
        end
    end

    // Asynchronous Read
    assign vga_read_data = color_ram[vga_read_addr];

endmodule