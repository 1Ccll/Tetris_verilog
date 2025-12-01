`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module Tetris_design(
    input clk,
    input rst_n,
    input move_left,
    input move_right,
    input move_fast,
    input move_tobottom,
    input rotate,
    input wire [7:0] vga_read_addr,
    output wire [2:0] vga_read_data,
    output wire [199:0] blocks_exist,
    output wire [7:0] active_pos0,
    output wire [7:0] active_pos1,
    output wire [7:0] active_pos2,
    output wire [7:0] active_pos3,
    output wire [19:0] is_full_row,
    output wire [2:0] game_current_state,
    output wire [2:0] current_block_type,
    output wire [2:0] next_block_type,
    output wire [1:0] next_block_rotation, 
    output wire [3:0] score_d3,            // thousand
    output wire [3:0] score_d2,            // hundred
    output wire [3:0] score_d1,            // ten
    output wire [3:0] score_d0,             // one
    output wire twinkle_color
);
    // define game variables
    wire [7:0] location;
    wire [1:0] current_block_rotation;
    wire [2:0] game_next_state;
    
    reg [15:0] lfsr1, lfsr2;
    wire [2:0] rand_num1, rand_num2;
    wire [1:0] rand_num3, rand_num4;
    assign is_full_row = {&blocks_exist[199:190] ,&blocks_exist[189:180] , &blocks_exist[179:170] , &blocks_exist[169:160] , &blocks_exist[159:150] 
                        ,&blocks_exist[149:140] , &blocks_exist[139:130] , &blocks_exist[129:120] , &blocks_exist[119:110] , &blocks_exist[109:100]
                      ,&blocks_exist[99:90] , &blocks_exist[89:80] , &blocks_exist[79:70] , &blocks_exist[69:60] , &blocks_exist[59:50] 
                      ,&blocks_exist[49:40] , &blocks_exist[39:30] , &blocks_exist[29:20] , &blocks_exist[19:10] , &blocks_exist[9:0]};
    
    // initial_move
    wire [199:0] blocks_exist_initial;
    wire [2:0] game_next_state_initial;
    // generate_piece_move
    wire [2:0] game_next_state_generate;
    // rotate_piece_move
    wire [1:0] current_block_rotation_rotate;
    wire [2:0] game_next_state_rotate;
    wire done_rotate;
    // collision_move
    wire [199:0] blocks_exist_collision;
    wire [2:0] game_next_state_collision;
    wire start_collision;
    wire done_collision;
    wire [7:0] location_prev;
    // clear_row_move
    wire [199:0] blocks_exist_clear;
    wire [2:0] game_next_state_clear;
    wire [2:0] score_cnt;
    wire done_clear;
    // move_move
    wire [2:0] game_next_state_move;
    wire [7:0] location_move;
    // tobottom_move
    wire [199:0] blocks_exist_tobottom;
    wire [2:0] game_next_state_tobottom;
    wire [7:0] location_tobottom;
    wire done_tobottom;
    // fall_move
    wire en_fall;
    // lose move
    wire [2:0] game_next_state_lose;
    // check_fall_collision
    wire will_collide_below;
    // blocks_active_manager
    wire [7:0] active_pos0_comb, active_pos1_comb, active_pos2_comb, active_pos3_comb;
    reg [7:0] active_pos0_reg, active_pos1_reg, active_pos2_reg, active_pos3_reg;
    // flop active_position
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            active_pos0_reg <= 8'd255;
            active_pos1_reg <= 8'd255;
            active_pos2_reg <= 8'd255;
            active_pos3_reg <= 8'd255;
        end else begin
            active_pos0_reg <= active_pos0_comb;
            active_pos1_reg <= active_pos1_comb;
            active_pos2_reg <= active_pos2_comb;
            active_pos3_reg <= active_pos3_comb;
        end
    end
    // output flopped_active_position
    assign active_pos0 = active_pos0_reg;
    assign active_pos1 = active_pos1_reg;
    assign active_pos2 = active_pos2_reg;
    assign active_pos3 = active_pos3_reg;

    // generate random number
    // LFSR
    // ensure each rst have different random array
    reg [15:0] free_run_cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            free_run_cnt <= 16'd0;
        else 
            free_run_cnt <= free_run_cnt + 1'b1; 
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            lfsr1 <= 16'hABC1; 
        end
        else if (game_current_state == `INITIAL && rotate) begin 
            lfsr1 <= free_run_cnt ^ 16'hABC1; 
        end
        else begin
            lfsr1 <= {lfsr1[14:0], lfsr1[15] ^ lfsr1[13] ^ lfsr1[12] ^ lfsr1[10]};
        end
    end
    always @(posedge clk) begin
        if(!rst_n) begin
            lfsr2 <= 16'hE5F2;
        end
        else if (game_current_state == `INITIAL && rotate) begin
            lfsr2 <= {free_run_cnt[7:0], free_run_cnt[15:8]} ^ 16'hE5F2;
        end
        else begin
            lfsr2 <= {lfsr2[14:0], lfsr2[15] ^ lfsr2[14] ^ lfsr2[12] ^ lfsr2[10]};
        end
    end
    assign rand_num1 = lfsr1[2:0] % 7;
    assign rand_num2 = lfsr2[12:10] % 7;
    assign rand_num3 = lfsr1[9:8] % 4;
    assign rand_num4 = lfsr2[14:13] % 4;


    // mark each column 9
    reg [255:0] is_col_9; 
    integer i;
    initial begin
        is_col_9 = 0;
        for (i = 9; i < 200; i = i + 10) begin
            is_col_9[i] = 1'b1;
        end
        is_col_9[255] = 1'b1;  // incase location is 0
    end
    

    // score
    reg [3:0] dig_0;
    reg [3:0] dig_1;
    reg [3:0] dig_2;
    reg [3:0] dig_3;
    reg [7:0] score_to_add; 
    reg add_trig;

    // score update
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            dig_3 <= 0; dig_2 <= 0; dig_1 <= 0; dig_0 <= 0;
            score_to_add <= 0;
            add_trig <= 0;
        end
        else if (game_current_state == `LOSE && game_next_state == `INITIAL)begin
            dig_3 <= 0; dig_2 <= 0; dig_1 <= 0; dig_0 <= 0;
        end
        else begin
            if (done_clear) begin
                case (score_cnt)
                    3'd1: score_to_add <= 10;
                    3'd2: score_to_add <= 30;
                    3'd3: score_to_add <= 70;
                    3'd4: score_to_add <= 150; 
                    default: score_to_add <= 0;
                endcase
                if (score_cnt > 0) add_trig <= 1;
            end
            if (add_trig) begin
                add_trig <= 0; 
                case(score_to_add)
                    8'd10: begin // +10
                        if (dig_1 + 1 >= 10) begin 
                            dig_1 <= dig_1 + 1 - 10; 
                            if (dig_2 + 1 >= 10) begin 
                                dig_2 <= dig_2 + 1 - 10;
                                if (dig_3 + 1 >= 10) 
                                    dig_3 <= 0; 
                                else 
                                    dig_3 <= dig_3 + 1;
                            end 
                            else dig_2 <= dig_2 + 1;
                        end 
                        else dig_1 <= dig_1 + 1;
                    end
                    
                    8'd30: begin // +30
                        if (dig_1 + 3 >= 10) begin 
                            dig_1 <= dig_1 + 3 - 10; 
                            if (dig_2 + 1 >= 10) begin 
                                dig_2 <= dig_2 + 1 - 10;
                                if (dig_3 + 1 >= 10) 
                                    dig_3 <= 0; 
                                else dig_3 <= dig_3 + 1;
                            end 
                            else dig_2 <= dig_2 + 1;
                        end 
                        else dig_1 <= dig_1 + 3;
                    end
                    
                    8'd70: begin // +70
                        if (dig_1 + 7 >= 10) begin 
                            dig_1 <= dig_1 + 7 - 10; 
                            if (dig_2 + 1 >= 10) begin 
                                dig_2 <= dig_2 + 1 - 10;
                                if (dig_3 + 1 >= 10) 
                                    dig_3 <= 0; 
                                else dig_3 <= dig_3 + 1;
                            end 
                            else dig_2 <= dig_2 + 1;
                        end 
                        else dig_1 <= dig_1 + 7;
                    end
                    
                    8'd150: begin// + 50 + 100
                        if (dig_1 + 5 >= 10) begin 
                            dig_1 <= dig_1 + 5 - 10; 
                            if (dig_2 + 2 >= 10) begin
                                 dig_2 <= dig_2 + 2 - 10;
                                if (dig_3 + 1 >= 10) 
                                dig_3 <= 0; 
                                else dig_3 <= dig_3 + 1;
                            end 
                            else dig_2 <= dig_2 + 2;
                        end 
                        else begin
                            dig_1 <= dig_1 + 5;
                            if (dig_2 + 1 >= 10) begin 
                                dig_2 <= dig_2 + 1 - 10;
                                if (dig_3 + 1 >= 10) 
                                    dig_3 <= 0; 
                                else dig_3 <= dig_3 + 1;
                            end 
                            else dig_2 <= dig_2 + 1;
                        end
                    end
                endcase
            end
        end
    end

    assign score_d0 = dig_0;
    assign score_d1 = dig_1;
    assign score_d2 = dig_2;
    assign score_d3 = dig_3;

    //state controller
    state_controller u_state_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .game_next_state_initial(game_next_state_initial),
        .game_next_state_generate(game_next_state_generate),
        .game_next_state_rotate(game_next_state_rotate),
        .game_next_state_collision(game_next_state_collision),
        .game_next_state_clear(game_next_state_clear),
        .game_next_state_move(game_next_state_move),
        .game_next_state_tobottom(game_next_state_tobottom),
        .game_next_state_lose(game_next_state_lose),
        .game_next_state(game_next_state),
        .game_current_state(game_current_state)
    );


    //initial
    initial_move u_init_logic (
        .rotate(rotate),
        .clk(clk),
        .rst_n(rst_n),
        .game_current_state(game_current_state),
        .blocks_exist_initial(blocks_exist_initial),
        .game_next_state_initial(game_next_state_initial)
    );

    //generate_piece
    generate_piece_move u_gen_piece (
        .rotate(rotate),
        .clk(clk),
        .rst_n(rst_n),
        .en_fall(en_fall),
        .move_left(move_left),
        .move_right(move_right),
        .move_tobottom(move_tobottom),
        .game_current_state(game_current_state),
        .will_collide_below(will_collide_below),
        .game_next_state_generate(game_next_state_generate)
    );

    //rotate_piece
    rotate_piece_move u_rotate_logic (
        .clk(clk),
        .rst_n(rst_n),
        .game_current_state(game_current_state),
        .location(location),
        .blocks_exist(blocks_exist),
        .current_block_type(current_block_type),
        .current_block_rotation(current_block_rotation),
        .is_col_9(is_col_9),
        .current_block_rotation_rotate(current_block_rotation_rotate),
        .game_next_state_rotate(game_next_state_rotate),
        .done_rotate(done_rotate)
    );

    //collision
    collision_move u_collision_logic (
        .clk(clk),
        .rst_n(rst_n),
        .game_current_state(game_current_state),
        .blocks_exist(blocks_exist),
        .active_pos0(active_pos0),
        .active_pos1(active_pos1),
        .active_pos2(active_pos2),
        .active_pos3(active_pos3),
        .current_block_type(current_block_type),
        .current_block_rotation(current_block_rotation),
        .location_prev(location_prev),
        .blocks_exist_collision(blocks_exist_collision),
        .game_next_state_collision(game_next_state_collision),
        .start_collision(start_collision),
        .done_collision(done_collision)
    );

    //clear_row
    clear_row_move u_clear_row (
        .clk(clk),
        .rst_n(rst_n),
        .is_full_row(is_full_row),
        .game_current_state(game_current_state),
        .done_clear(done_clear),
        .blocks_exist(blocks_exist),
        .blocks_exist_clear(blocks_exist_clear),
        .game_next_state_clear(game_next_state_clear),
        .score_cnt(score_cnt),
        .twinkle_color(twinkle_color)
    );

    //move
    move_move u_move_lr (
        .clk(clk),
        .rst_n(rst_n),
        .move_left(move_left),
        .move_right(move_right),
        .game_current_state(game_current_state),
        .game_next_state(game_next_state),
        .blocks_exist(blocks_exist),
        .current_block_type(current_block_type),
        .current_block_rotation(current_block_rotation),
        .location(location),
        .is_col_9(is_col_9),
        .game_next_state_move(game_next_state_move),
        .location_move(location_move)
    );

    // tobottom
    tobottom_move u_drop_bottom (
        .clk(clk),
        .rst_n(rst_n),
        .game_current_state(game_current_state),
        .blocks_exist(blocks_exist),
        .current_block_type(current_block_type),
        .current_block_rotation(current_block_rotation),
        .location(location),
        .done_tobottom(done_tobottom),
        .game_next_state_tobottom(game_next_state_tobottom),
        .location_tobottom(location_tobottom)
    );

    //lose
    lose_move u_lose_check (
        .clk(clk),
        .rst_n(rst_n),
        .game_current_state(game_current_state),
        .rotate(rotate),
        .game_next_state_lose(game_next_state_lose)
    );

    // fall
    fall_move u_auto_fall (
        .clk(clk),
        .rst_n(rst_n),
        .game_next_state(game_next_state),
        .move_fast(move_fast),
        .en_fall(en_fall),
        .start_collision(start_collision)
    );

    // blocks_active_manager
    blocks_active_manager u_active_mgr (
        .game_current_state(game_current_state),
        .current_block_type(current_block_type),
        .current_block_rotation(current_block_rotation),
        .location(location),
        .pos0(active_pos0_comb),
        .pos1(active_pos1_comb),
        .pos2(active_pos2_comb),
        .pos3(active_pos3_comb)
    );

    // location_manager
    location_manager u_loc_mgr (
        .clk(clk),
        .rst_n(rst_n),
        .game_current_state(game_current_state),
        .game_next_state(game_next_state),
        .en_fall(en_fall),
        .location_move(location_move),
        .location_tobottom(location_tobottom),
        .done_tobottom(done_tobottom),
        .will_collide_below(will_collide_below),
        .location(location),
        .location_prev(location_prev)
    );

    // blocks_exist_manager
    blocks_exist_manager u_exist_mgr (
        .clk(clk),
        .rst_n(rst_n),
        .game_current_state(game_current_state),
        .blocks_exist_initial(blocks_exist_initial),
        .done_collision(done_collision),
        .blocks_exist_collision(blocks_exist_collision),
        .blocks_exist_clear(blocks_exist_clear),
        .done_clear(done_clear),
        .blocks_exist(blocks_exist)
    );

    // block_state_manager
    block_state_manager u_state_mgr (
        .clk(clk),
        .rst_n(rst_n),
        .done_rotate(done_rotate),
        .game_current_state(game_current_state),
        .rand_num1(rand_num1),
        .rand_num2(rand_num2),
        .rand_num3(rand_num3),
        .rand_num4(rand_num4),
        .current_block_rotation_rotate(current_block_rotation_rotate),
        .current_block_rotation(current_block_rotation),
        .current_block_type(current_block_type),
        .next_block_rotation(next_block_rotation),
        .next_block_type(next_block_type)
    );
    // blocks_color_manager
    blocks_color_manager u_color_mgr (
        .clk(clk),
        .rst_n(rst_n),
        .game_current_state(game_current_state),
        .done_collision(done_collision),   
        .done_clear(done_clear),       
        .is_full_row(is_full_row),
        .location_prev(location_prev),         
        .current_block_type(current_block_type),    
        .current_block_rotation(current_block_rotation),
        .vga_read_addr(vga_read_addr),
        .vga_read_data(vga_read_data)
    );
    // check_fall_collision
    check_fall_collision u_fall_check (
        .current_loc(location), 
        .block_type(current_block_type),
        .rotation(current_block_rotation),
        .blocks_exist(blocks_exist),
        .will_collide_below(will_collide_below)
    );
endmodule