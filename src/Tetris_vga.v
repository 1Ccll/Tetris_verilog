`timescale 1ns / 1ps
`include "tetris_states.vh"

module Tetris_vga(
    input  wire         clk,
    input  wire         rst_n,
    
    input  wire [199:0] blocks_exist,
    input  wire [7:0]   active_pos0, 
    input  wire [7:0]   active_pos1, 
    input  wire [7:0]   active_pos2, 
    input  wire [7:0]   active_pos3,
    
    output wire [7:0]   color_read_addr,
    input  wire [2:0]   color_read_data,
    
    input  wire [2:0]   current_block_type,
    input  wire [2:0]   next_block_type, 
    input  wire [1:0]   next_block_rotation,
    input  wire [3:0]   score_d3, 
    input  wire [3:0]   score_d2, 
    input  wire [3:0]   score_d1, 
    input  wire [3:0]   score_d0,
    
    input  wire [2:0]   game_current_state,
    input  wire         twinkle_color,   
    input  wire [19:0]  is_full_row,
    
    output reg          vga_hsync,
    output reg          vga_vsync,
    output reg  [3:0]   vga_r,
    output reg  [3:0]   vga_g,
    output reg  [3:0]   vga_b
);

    // Stage 0: Basic Counters and Timing Generation
    localparam H_SYNC   = 96; 
    localparam H_BACK   = 48; 
    localparam H_ACTIVE = 640;
    localparam H_FRONT  = 16; 
    localparam H_TOTAL  = 800;
    
    localparam V_SYNC   = 2; 
    localparam V_BACK   = 33; 
    localparam V_ACTIVE = 480;
    localparam V_FRONT  = 10; 
    localparam V_TOTAL  = 525;
    
    reg [9:0] h_cnt;
    reg [9:0] v_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin 
            h_cnt <= 0; 
            v_cnt <= 0; 
        end 
        else begin
            if (h_cnt == H_TOTAL - 1) begin
                h_cnt <= 0;
                if (v_cnt == V_TOTAL - 1) begin
                    v_cnt <= 0; 
                end
                else begin
                    v_cnt <= v_cnt + 1;
                end
            end 
            else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    wire hsync_raw;
    wire vsync_raw;
    wire video_on_raw;
    
    assign hsync_raw = (h_cnt < H_SYNC) ? 1'b0 : 1'b1;
    assign vsync_raw = (v_cnt < V_SYNC) ? 1'b0 : 1'b1;
    assign video_on_raw = (h_cnt >= H_SYNC + H_BACK) && (h_cnt < H_SYNC + H_BACK + H_ACTIVE) &&
                          (v_cnt >= V_SYNC + V_BACK) && (v_cnt < V_SYNC + V_BACK + V_ACTIVE);
    
    // Screen coordinates
    wire [9:0] pix_x;
    wire [9:0] pix_y;
    assign pix_x = video_on_raw ? (h_cnt - (H_SYNC + H_BACK)) : 10'd0;
    assign pix_y = video_on_raw ? (v_cnt - (V_SYNC + V_BACK)) : 10'd0;

    // --- Layout Parameters ---
    localparam BLOCK_SIZE  = `BLOCK_SIZE;
    localparam BEVEL_WIDTH = `BEVEL_WIDTH;
    
    // Main Game Board
    localparam BOARD_W       = `BOARD_W; 
    localparam BOARD_H       = `BOARD_H;
    localparam BORDER        = `BORDER; 
    localparam OFFSET_X      = `OFFSET_X; 
    localparam OFFSET_Y      = `OFFSET_Y;
    localparam BOARD_X_START = H_SYNC + H_BACK + OFFSET_X;
    localparam BOARD_Y_START = V_SYNC + V_BACK + OFFSET_Y;
    
    // Next Piece Area
    localparam NEXT_X_OFF    = `NEXT_X_OFF; 
    localparam NEXT_Y_OFF    = `NEXT_Y_OFF;
    localparam NEXT_W        = 6 * BLOCK_SIZE; 
    localparam NEXT_H        = 4 * BLOCK_SIZE;
    localparam NEXT_X_START  = H_SYNC + H_BACK + NEXT_X_OFF;
    localparam NEXT_Y_START  = V_SYNC + V_BACK + NEXT_Y_OFF;
    
    // Score Area
    localparam CHAR_SCALE    = `CHAR_SCALE; 
    localparam CHAR_SPACE    = `CHAR_SPACE;
    localparam CHAR_W        = 3 * CHAR_SCALE; 
    localparam CHAR_H        = 5 * CHAR_SCALE;
    localparam SCORE_X_OFF   = `SCORE_X_OFF; 
    localparam SCORE_Y_OFF   = `SCORE_Y_OFF;
    localparam SCORE_AREA_W  = (CHAR_W + CHAR_SPACE) * 4; 
    localparam SCORE_AREA_H  = CHAR_H;
    localparam SCORE_X_START = H_SYNC + H_BACK + SCORE_X_OFF;
    localparam SCORE_Y_START = V_SYNC + V_BACK + SCORE_Y_OFF;
    
    // Logo Area
    localparam LOGO_W = `LOGO_W;
    localparam LOGO_H = `LOGO_H;
    localparam LOGO_X = `LOGO_X;
    localparam LOGO_Y = `LOGO_Y;

    // Logo Area Detection
    wire in_logo_area_raw;
    assign in_logo_area_raw = (pix_x >= LOGO_X) && (pix_x < LOGO_X + LOGO_W) && 
                              (pix_y >= LOGO_Y) && (pix_y < LOGO_Y + LOGO_H);

    // --- Area Counters ---
    
    // [Counter 1] Main Game Board
    reg [3:0] current_col; 
    reg [4:0] pixel_in_col; 
    reg [4:0] current_row; 
    reg [4:0] pixel_in_row;
    
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            current_col  <= 0; 
            pixel_in_col <= 0; 
        end 
        else if (h_cnt == BOARD_X_START - 1) begin 
            current_col  <= 0; 
            pixel_in_col <= 0; 
        end 
        else if (h_cnt >= BOARD_X_START && h_cnt < BOARD_X_START + BOARD_W) begin 
            if (pixel_in_col == BLOCK_SIZE - 1) begin 
                pixel_in_col <= 0; 
                current_col  <= current_col + 1; 
            end 
            else begin
                pixel_in_col <= pixel_in_col + 1; 
            end
        end 
    end
    
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            current_row  <= 19; 
            pixel_in_row <= 0; 
        end 
        else if (v_cnt == BOARD_Y_START - 1 && h_cnt == H_TOTAL - 1) begin 
            current_row  <= 19; 
            pixel_in_row <= 0; 
        end 
        else if (v_cnt >= BOARD_Y_START && v_cnt < BOARD_Y_START + BOARD_H) begin 
            if (h_cnt == H_TOTAL - 1) begin 
                if (pixel_in_row == BLOCK_SIZE - 1) begin 
                    pixel_in_row <= 0; 
                    if (current_row > 0) begin
                        current_row <= current_row - 1; 
                    end
                end 
                else begin
                    pixel_in_row <= pixel_in_row + 1; 
                end
            end 
        end 
    end
    
    // [Counter 2] Next Piece Area
    reg [2:0] next_col; 
    reg [4:0] pix_in_next_col; 
    reg [2:0] next_row; 
    reg [4:0] pix_in_next_row;
    
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            next_col        <= 0; 
            pix_in_next_col <= 0; 
        end 
        else if (h_cnt == NEXT_X_START - 1) begin 
            next_col        <= 0; 
            pix_in_next_col <= 0; 
        end 
        else if (h_cnt >= NEXT_X_START && h_cnt < NEXT_X_START + NEXT_W) begin 
            if (pix_in_next_col == BLOCK_SIZE - 1) begin 
                pix_in_next_col <= 0; 
                next_col        <= next_col + 1; 
            end 
            else begin
                pix_in_next_col <= pix_in_next_col + 1; 
            end
        end 
    end
    
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            next_row        <= 0; 
            pix_in_next_row <= 0; 
        end 
        else if (v_cnt == NEXT_Y_START - 1 && h_cnt == H_TOTAL - 1) begin 
            next_row        <= 0; 
            pix_in_next_row <= 0; 
        end 
        else if (v_cnt >= NEXT_Y_START && v_cnt < NEXT_Y_START + NEXT_H) begin 
            if (h_cnt == H_TOTAL - 1) begin 
                if (pix_in_next_row == BLOCK_SIZE - 1) begin 
                    pix_in_next_row <= 0; 
                    next_row        <= next_row + 1; 
                end 
                else begin
                    pix_in_next_row <= pix_in_next_row + 1; 
                end
            end 
        end 
    end
    
    // [Counter 3] Score Area
    reg [2:0] score_digit_idx; 
    reg [4:0] score_pix_x; 
    reg [4:0] score_pix_y; 
    
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            score_digit_idx <= 0; 
            score_pix_x     <= 0; 
        end 
        else if (h_cnt == SCORE_X_START - 1) begin 
            score_digit_idx <= 0; 
            score_pix_x     <= 0; 
        end 
        else if (h_cnt >= SCORE_X_START && h_cnt < SCORE_X_START + SCORE_AREA_W) begin 
            if (score_pix_x == (CHAR_W + CHAR_SPACE) - 1) begin 
                score_pix_x     <= 0; 
                score_digit_idx <= score_digit_idx + 1; 
            end 
            else begin
                score_pix_x <= score_pix_x + 1; 
            end
        end 
    end
    
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            score_pix_y <= 0; 
        end
        else if (v_cnt == SCORE_Y_START - 1 && h_cnt == H_TOTAL - 1) begin
            score_pix_y <= 0; 
        end
        else if (v_cnt >= SCORE_Y_START && v_cnt < SCORE_Y_START + SCORE_AREA_H) begin 
            if (h_cnt == H_TOTAL - 1) begin 
                if (score_pix_y < CHAR_H - 1) begin
                    score_pix_y <= score_pix_y + 1; 
                end
                else begin
                    score_pix_y <= 0; 
                end
            end 
        end 
    end

    // --- Pre-calculation Logic ---
    wire in_board_raw;
    wire is_border_raw;
    wire is_grid_line_raw;
    wire [7:0] next_block_index;
    wire in_next_area_raw;
    wire in_score_area_raw;

    assign in_board_raw      = (pix_x >= OFFSET_X) && (pix_x < OFFSET_X + BOARD_W) && (pix_y >= OFFSET_Y) && (pix_y < OFFSET_Y + BOARD_H);
    assign is_border_raw     = (pix_x >= OFFSET_X - BORDER) && (pix_x < OFFSET_X + BOARD_W + BORDER) && (pix_y >= OFFSET_Y - BORDER) && (pix_y < OFFSET_Y + BOARD_H + BORDER) && !in_board_raw;
    assign is_grid_line_raw  = (pixel_in_col == 0) || (pixel_in_col == BLOCK_SIZE - 1) || (pixel_in_row == 0) || (pixel_in_row == BLOCK_SIZE - 1);
    assign next_block_index  = (current_row << 3) + (current_row << 1) + current_col;
    assign in_next_area_raw  = (h_cnt >= NEXT_X_START && h_cnt < NEXT_X_START + NEXT_W) && (v_cnt >= NEXT_Y_START && v_cnt < NEXT_Y_START + NEXT_H);
    assign in_score_area_raw = (h_cnt >= SCORE_X_START && h_cnt < SCORE_X_START + SCORE_AREA_W) && (v_cnt >= SCORE_Y_START && v_cnt < SCORE_Y_START + SCORE_AREA_H) && (score_pix_x < CHAR_W);

    // Bevel Mode Logic
    wire [4:0] eff_pix_row;
    wire [4:0] eff_pix_col;
    wire is_highlight_zone;
    wire is_shadow_zone;
    
    assign eff_pix_row       = in_next_area_raw ? pix_in_next_row : pixel_in_row;
    assign eff_pix_col       = in_next_area_raw ? pix_in_next_col : pixel_in_col;
    assign is_highlight_zone = (eff_pix_row < BEVEL_WIDTH) || (eff_pix_col < BEVEL_WIDTH);
    assign is_shadow_zone    = !is_highlight_zone && ((eff_pix_row >= BLOCK_SIZE - BEVEL_WIDTH) || (eff_pix_col >= BLOCK_SIZE - BEVEL_WIDTH));
    
    reg [1:0] next_bevel_mode;
    always @(*) begin 
        if (is_highlight_zone) begin
            next_bevel_mode = 2'b01; 
        end
        else if (is_shadow_zone) begin
            next_bevel_mode = 2'b10; 
        end
        else begin
            next_bevel_mode = 2'b00; 
        end
    end

    // Stage 1: Pipeline Registers & Image Address Calculation
    reg video_on_d1, in_board_d1, is_border_d1, is_grid_line_d1, hsync_d1, vsync_d1;
    reg [7:0] block_index_d1; 
    reg [1:0] bevel_mode_d1;
    reg in_next_area_d1; 
    reg [2:0] next_col_d1, next_row_d1; 
    reg [2:0] next_block_type_d1; 
    reg [1:0] next_block_rotation_d1;
    reg in_score_area_d1; 
    reg [4:0] score_pix_x_d1, score_pix_y_d1; 
    reg [3:0] digit_val_d1; 
    reg [4:0] row_d1; 
    reg in_logo_area_d1;
    reg [2:0] game_state_d1;
    reg [14:0] img_init_rom_addr_d1;
    reg [14:0] img_lose_rom_addr_d1;
    reg [13:0] img_logo_rom_addr_d1;

    always @(posedge clk) begin
        hsync_d1             <= hsync_raw; 
        vsync_d1             <= vsync_raw; 
        video_on_d1          <= video_on_raw;
        in_board_d1          <= in_board_raw; 
        is_border_d1         <= is_border_raw; 
        is_grid_line_d1      <= is_grid_line_raw;
        block_index_d1       <= next_block_index; 
        bevel_mode_d1        <= next_bevel_mode; 
        row_d1               <= current_row;
        
        in_next_area_d1      <= in_next_area_raw; 
        next_col_d1          <= next_col; 
        next_row_d1          <= next_row; 
        next_block_type_d1   <= next_block_type; 
        next_block_rotation_d1 <= next_block_rotation;
        
        in_score_area_d1     <= in_score_area_raw; 
        score_pix_x_d1       <= score_pix_x; 
        score_pix_y_d1       <= score_pix_y;
        
        case(score_digit_idx) 
            0: begin 
                digit_val_d1 <= score_d3; 
            end
            1: begin 
                digit_val_d1 <= score_d2; 
            end
            2: begin 
                digit_val_d1 <= score_d1; 
            end
            3: begin 
                digit_val_d1 <= score_d0; 
            end
            default: begin 
                digit_val_d1 <= 0; 
            end
        endcase
        
        game_state_d1 <= game_current_state;
        
        // Image Address Calculation
        img_init_rom_addr_d1 <= ((pix_y[9:2] << 7) + (pix_y[9:2] << 5)) + pix_x[9:2];
        img_lose_rom_addr_d1 <= ((pix_y[9:2] << 7) + (pix_y[9:2] << 5)) + pix_x[9:2];
        in_logo_area_d1      <= in_logo_area_raw;
        
        if (in_logo_area_raw) begin
            img_logo_rom_addr_d1 <= ((pix_y - LOGO_Y) << 7) - ((pix_y - LOGO_Y) << 3) + (pix_x - LOGO_X);
        end
        else begin
            img_logo_rom_addr_d1 <= 0;
        end
    end
    assign color_read_addr = block_index_d1;

    // Stage 2: Data Fetch & Logic Lookup
    reg video_on_d2, in_board_d2, is_border_d2, is_grid_line_d2, hsync_d2, vsync_d2;
    reg is_active_d2, is_exist_d2; 
    reg [2:0] ram_color_d2, active_color_d2; 
    reg [1:0] bevel_mode_d2;
    reg in_next_area_d2, is_next_block_exist_d2; 
    reg [2:0] next_block_type_d2;
    reg in_score_area_d2, is_font_pixel_d2; 
    reg [4:0] row_d2; 
    reg [2:0] game_state_d2;
    reg in_logo_area_d2;

    // Image Data Wires
    wire [15:0] init_img_data_raw;
    wire [15:0] lose_img_data_raw;
    wire [15:0] logo_img_data_raw;
    
    // Converted 12-bit RGB Wires
    wire [11:0] init_img_rgb;
    wire [11:0] lose_img_rgb;
    wire [11:0] logo_img_rgb;
    
    // Instantiate ROMs
    rom_pic_initial u_rom_init (
        .clka(clk),
        .addra(img_init_rom_addr_d1),
        .douta(init_img_data_raw)
    );
    
    rom_pic_lose u_rom_lose (
        .clka(clk),
        .addra(img_lose_rom_addr_d1),
        .douta(lose_img_data_raw)
    );

    rom_pic_logo u_rom_logo (
        .clka(clk),
        .addra(img_logo_rom_addr_d1),
        .douta(logo_img_data_raw)
    );
    
    // Color Format Conversion
    assign init_img_rgb = init_img_data_raw[11:0];
    assign lose_img_rgb = lose_img_data_raw[11:0];
    // Fix BGR to RGB for Logo
    assign logo_img_rgb = { logo_img_data_raw[3:0], logo_img_data_raw[7:4], logo_img_data_raw[11:8] };
    
    // Font Logic
    reg [2:0] font_row_bits; 
    reg [2:0] font_y_idx; 
    reg [1:0] font_x_idx;
    

    always @(posedge clk) begin
        hsync_d2           <= hsync_d1; 
        vsync_d2           <= vsync_d1; 
        video_on_d2        <= video_on_d1; 
        in_board_d2        <= in_board_d1;
        is_border_d2       <= is_border_d1; 
        is_grid_line_d2    <= is_grid_line_d1; 
        bevel_mode_d2      <= bevel_mode_d1;
        in_next_area_d2    <= in_next_area_d1; 
        next_block_type_d2 <= next_block_type_d1; 
        row_d2             <= row_d1;
        game_state_d2      <= game_state_d1;
        in_logo_area_d2    <= in_logo_area_d1;
        
        if (block_index_d1 == active_pos0 || block_index_d1 == active_pos1 || block_index_d1 == active_pos2 || block_index_d1 == active_pos3) begin
            is_active_d2 <= 1'b1; 
        end
        else begin
            is_active_d2 <= 1'b0;
        end
        is_exist_d2        <= blocks_exist[block_index_d1]; 
        ram_color_d2       <= color_read_data; 
        active_color_d2    <= current_block_type;
        is_next_block_exist_d2 <= 1'b0; 
        
        if (in_next_area_d1) begin
            case (next_block_type_d1)
                `SQUARE: begin
                    if ((next_row_d1==1 || next_row_d1==2) && (next_col_d1==2 || next_col_d1==3)) begin 
                        is_next_block_exist_d2 <= 1'b1;
                    end
                end
                `BAR: begin 
                    case(next_block_rotation_d1)
                        2'b00, 2'b10: begin 
                            if (next_row_d1==2 && (next_col_d1>=1 && next_col_d1<=4)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b01, 2'b11: begin
                            if ((next_row_d1>=0 && next_row_d1<=3) && next_col_d1==2) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                    endcase
                end
                `S: begin
                    case(next_block_rotation_d1)
                        2'b00, 2'b10: begin 
                            if ((next_row_d1==1 && (next_col_d1==2 || next_col_d1==3)) || (next_row_d1==2 && (next_col_d1==1 || next_col_d1==2))) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b01, 2'b11: begin 
                            if ((next_col_d1==2 && (next_row_d1==1 || next_row_d1==2)) || (next_col_d1==1 && (next_row_d1==0 || next_row_d1==1))) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                    endcase
                end
                `Z: begin
                    case(next_block_rotation_d1)
                        2'b00, 2'b10: begin
                            if ((next_row_d1==1 && (next_col_d1==1 || next_col_d1==2)) || (next_row_d1==2 && (next_col_d1==2 || next_col_d1==3))) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b01, 2'b11: begin
                            if ((next_col_d1==2 && (next_row_d1==1 || next_row_d1==2)) || (next_col_d1==1 && (next_row_d1==2 || next_row_d1==3))) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                    endcase
                end
                `L: begin
                    case(next_block_rotation_d1)
                        2'b00: begin
                            if ((next_col_d1==2 && next_row_d1>=0 && next_row_d1<=2) || (next_col_d1==3 && next_row_d1==2)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b01: begin
                            if ((next_row_d1==1 && next_col_d1>=1 && next_col_d1<=3) || (next_row_d1==2 && next_col_d1==1)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b10: begin
                            if ((next_col_d1==2 && next_row_d1>=0 && next_row_d1<=2) || (next_col_d1==1 && next_row_d1==0)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b11: begin
                            if ((next_row_d1==1 && next_col_d1==3) || (next_row_d1==2 && next_col_d1>=1 && next_col_d1<=3)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                    endcase
                end
                `J: begin
                    case(next_block_rotation_d1)
                        2'b00: begin
                            if ((next_col_d1==2 && next_row_d1>=0 && next_row_d1<=2) || (next_col_d1==1 && next_row_d1==2)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b01: begin
                            if ((next_row_d1==1 && next_col_d1==1) || (next_row_d1==2 && next_col_d1>=1 && next_col_d1<=3)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b10: begin
                            if ((next_col_d1==2 && next_row_d1>=0 && next_row_d1<=2) || (next_col_d1==3 && next_row_d1==0)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b11: begin
                            if ((next_row_d1==1 && next_col_d1>=1 && next_col_d1<=3) || (next_row_d1==2 && next_col_d1==3)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                    endcase
                end
                `T: begin
                    case(next_block_rotation_d1)
                        2'b00: begin
                            if ((next_row_d1==1 && next_col_d1>=1 && next_col_d1<=3) || (next_row_d1==2 && next_col_d1==2)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b01: begin
                            if ((next_col_d1==2 && next_row_d1>=0 && next_row_d1<=2) || (next_col_d1==1 && next_row_d1==1)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b10: begin
                            if ((next_row_d1==1 && next_col_d1==2) || (next_row_d1==2 && next_col_d1>=1 && next_col_d1<=3)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                        2'b11: begin
                            if ((next_col_d1==2 && next_row_d1>=0 && next_row_d1<=2) || (next_col_d1==3 && next_row_d1==1)) begin
                                is_next_block_exist_d2 <= 1'b1;
                            end
                        end
                    endcase
                end
            endcase
        end

        in_score_area_d2 <= in_score_area_d1; 
        is_font_pixel_d2 <= 1'b0;
        
        if (in_score_area_d1) begin
            font_y_idx = score_pix_y_d1[4:2]; 
            font_x_idx = score_pix_x_d1[3:2]; 
            if (font_x_idx < 3 && font_y_idx < 5) begin
                font_row_bits = get_font_row(digit_val_d1, font_y_idx);
                if (font_row_bits[2 - font_x_idx]) begin
                    is_font_pixel_d2 <= 1'b1;
                end
            end
        end
    end

    // Stage 3: Final Mixing and Output
    reg [11:0] game_layer_rgb;
    reg [11:0] final_mixed_rgb;

    always @(posedge clk) begin
        vga_hsync <= hsync_d2; 
        vga_vsync <= vsync_d2;
        
        // 1. Calculate Game Layer
        if (video_on_d2) begin
            if (is_border_d2) begin
                // Border
                if (game_state_d2 == `LOSE) begin
                    game_layer_rgb = `C_RED; 
                end
                else begin
                    game_layer_rgb = `C_GREY;
                end
            end
            else if (in_board_d2) begin
                // Game Board
                if (is_active_d2) begin
                    game_layer_rgb = get_rgb(active_color_d2, bevel_mode_d2);
                end
                else if (is_exist_d2) begin
                    if (twinkle_color && is_full_row[row_d2]) begin
                        game_layer_rgb = `C_WHITE; 
                    end
                    else begin
                        game_layer_rgb = get_rgb(ram_color_d2, bevel_mode_d2);
                    end
                end
                else begin
                    if (is_grid_line_d2) begin
                        game_layer_rgb = `C_GRID; 
                    end
                    else begin
                        game_layer_rgb = `C_BLACK;
                    end
                end
            end
            else if (in_logo_area_d2 && logo_img_rgb != 12'h000) begin
                game_layer_rgb = logo_img_rgb;
            end
            else if (in_next_area_d2) begin
                // Next Piece Area
                if (is_next_block_exist_d2) begin
                    game_layer_rgb = get_rgb(next_block_type_d2, bevel_mode_d2);
                end
                else begin
                    game_layer_rgb = `C_BLACK;
                end
            end
            else if (in_score_area_d2) begin
                // Score Area
                if (is_font_pixel_d2) begin
                    game_layer_rgb = `C_WHITE; 
                end
                else begin
                    game_layer_rgb = `C_BLACK;
                end
            end
            else begin
                // Background
                game_layer_rgb = `C_BLACK;
            end
        end
        else begin
            game_layer_rgb = `C_BLACK;
        end

        // 2. Overlay Mixer
        if (video_on_d2) begin
            if (game_state_d2 == `INITIAL) begin
                // [INITIAL] Show full screen image
                final_mixed_rgb = init_img_rgb;
            end
            else if (game_state_d2 == `LOSE) begin
                // [LOSE] Show lose image
                final_mixed_rgb = lose_img_rgb;
            end
            else begin
                // [NORMAL] Show game layer
                final_mixed_rgb = game_layer_rgb;
            end
        end
        else begin
            final_mixed_rgb = `C_BLACK;
        end

        // 3. Output
        if (!rst_n) begin
            {vga_r, vga_g, vga_b} <= `C_RED;
        end
        else begin
            {vga_r, vga_g, vga_b} <= final_mixed_rgb;
        end
    end

    // Expanded Font Lookup Function
    function [2:0] get_font_row(input [3:0] digit, input [2:0] row); 
        case(digit) 
            4'd0: begin
                case(row) 
                    0: get_font_row = 3'b111; 
                    1: get_font_row = 3'b101; 
                    2: get_font_row = 3'b101; 
                    3: get_font_row = 3'b101; 
                    4: get_font_row = 3'b111; 
                    default: get_font_row = 0; 
                endcase
            end
            4'd1: begin
                case(row) 
                    0: get_font_row = 3'b010; 
                    1: get_font_row = 3'b110; 
                    2: get_font_row = 3'b010; 
                    3: get_font_row = 3'b010; 
                    4: get_font_row = 3'b111; 
                    default: get_font_row = 0; 
                endcase 
            end
            4'd2: begin
                case(row) 
                    0: get_font_row = 3'b111; 
                    1: get_font_row = 3'b001; 
                    2: get_font_row = 3'b111; 
                    3: get_font_row = 3'b100; 
                    4: get_font_row = 3'b111; 
                    default: get_font_row = 0; 
                endcase 
            end
            4'd3: begin
                case(row) 
                    0: get_font_row = 3'b111; 
                    1: get_font_row = 3'b001; 
                    2: get_font_row = 3'b111; 
                    3: get_font_row = 3'b001; 
                    4: get_font_row = 3'b111; 
                    default: get_font_row = 0; 
                endcase 
            end
            4'd4: begin
                case(row) 
                    0: get_font_row = 3'b101; 
                    1: get_font_row = 3'b101; 
                    2: get_font_row = 3'b111; 
                    3: get_font_row = 3'b001; 
                    4: get_font_row = 3'b001; 
                    default: get_font_row = 0; 
                endcase 
            end
            4'd5: begin
                case(row) 
                    0: get_font_row = 3'b111; 
                    1: get_font_row = 3'b100; 
                    2: get_font_row = 3'b111; 
                    3: get_font_row = 3'b001; 
                    4: get_font_row = 3'b111; 
                    default: get_font_row = 0; 
                endcase 
            end
            4'd6: begin
                case(row) 
                    0: get_font_row = 3'b111; 
                    1: get_font_row = 3'b100; 
                    2: get_font_row = 3'b111; 
                    3: get_font_row = 3'b101; 
                    4: get_font_row = 3'b111; 
                    default: get_font_row = 0; 
                endcase 
            end
            4'd7: begin
                case(row) 
                    0: get_font_row = 3'b111; 
                    1: get_font_row = 3'b001; 
                    2: get_font_row = 3'b001; 
                    3: get_font_row = 3'b010; 
                    4: get_font_row = 3'b010; 
                    default: get_font_row = 0; 
                endcase 
            end
            4'd8: begin
                case(row) 
                    0: get_font_row = 3'b111; 
                    1: get_font_row = 3'b101; 
                    2: get_font_row = 3'b111; 
                    3: get_font_row = 3'b101; 
                    4: get_font_row = 3'b111; 
                    default: get_font_row = 0; 
                endcase 
            end
            4'd9: begin
                case(row) 
                    0: get_font_row = 3'b111; 
                    1: get_font_row = 3'b101; 
                    2: get_font_row = 3'b111; 
                    3: get_font_row = 3'b001; 
                    4: get_font_row = 3'b111; 
                    default: get_font_row = 0; 
                endcase 
            end
            default: begin
                get_font_row = 3'b000; 
            end
        endcase 
    endfunction
    // Expanded get_rgb function
    function [11:0] get_rgb(input [2:0] b_type, input [1:0] mode); 
        reg [11:0] base, hi, lo; 
        begin 
            case(b_type) 
                `SQUARE: begin 
                    base = `CY_BASE; 
                    hi = `CY_HI; 
                    lo = `CY_LO; 
                end 
                `BAR: begin 
                    base = `CC_BASE; 
                    hi = `CC_HI; 
                    lo = `CC_LO; 
                end 
                `S: begin 
                    base = `CG_BASE; 
                    hi = `CG_HI; 
                    lo = `CG_LO; 
                end 
                `Z: begin 
                    base = `CR_BASE; 
                    hi = `CR_HI; 
                    lo = `CR_LO; 
                end 
                `L: begin 
                    base = `CO_BASE; 
                    hi = `CO_HI; 
                    lo = `CO_LO; 
                end 
                `J: begin 
                    base = `CB_BASE; 
                    hi = `CB_HI; 
                    lo = `CB_LO; 
                end 
                `T: begin 
                    base = `CP_BASE; 
                    hi = `CP_HI; 
                    lo = `CP_LO; 
                end 
                default: begin 
                    base = `C_WHITE; 
                    hi = `C_WHITE; 
                    lo = `C_GREY; 
                end 
            endcase 
            
            case(mode) 
                2'b01: begin 
                    get_rgb = hi; 
                end
                2'b10: begin 
                    get_rgb = lo; 
                end
                default: begin 
                    get_rgb = base; 
                end
            endcase 
        end 
    endfunction
endmodule