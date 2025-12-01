`timescale 1ns / 1ps
`include "tetris_states.vh"  // include the game state definition
module clear_row_move(
    input clk,
    input rst_n,
    input [19:0] is_full_row,
    input [2:0] game_current_state,
    input [199:0] blocks_exist,
    output reg [199:0] blocks_exist_clear,
    output reg [2:0] game_next_state_clear,
    output reg [2:0] score_cnt,
    output reg twinkle_color,
    output reg done_clear
);
    reg [1:0] start_clear;
    reg [31:0] clear_cnt;
    reg [199:0] blocks_temp;

    // check if there is a full row
    always@(posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            clear_cnt <= {32{1'b0}};
            start_clear <= 1'b0;
            blocks_exist_clear <= {200{1'b0}};
            score_cnt <= 3'b000;
            twinkle_color <= 1'b0;
            done_clear <= 1'b0;
            blocks_temp <= {200{1'b0}};
            game_next_state_clear <= `CLEAR_ROW;
        end
        else begin
            if (game_current_state == `CLEAR_ROW)begin
                if (start_clear == 2'b00)begin
                    if (! done_clear)begin //when start clear
                        start_clear <= 2'b01;
                        blocks_temp <= blocks_exist;
                    end
                    else begin // when finish clear
                        done_clear <= 1'b0;
                    end
                    clear_cnt <= 0;
                    score_cnt <= 3'b000;
                    game_next_state_clear <= `CLEAR_ROW;
                end
                else begin
                    if (| is_full_row)begin
                        score_cnt <= is_full_row[0] + is_full_row[1] + is_full_row[2] + is_full_row[3] + is_full_row[4] 
                        + is_full_row[5] + is_full_row[6] + is_full_row[7] + is_full_row[8] + is_full_row[9] 
                        + is_full_row[10] + is_full_row[11] + is_full_row[12] + is_full_row[13] + is_full_row[14] 
                        + is_full_row[15] + is_full_row[16] + is_full_row[17] + is_full_row[18] + is_full_row[19];
                        clear_cnt <= clear_cnt + 1;
                        // clear logic  row 19 is top, row 0 is bottom
                        // for test later change to normal time
                        case (clear_cnt)
                            32'd10: begin
                                twinkle_color <= 1'b1; 
                                if (is_full_row[19]) blocks_temp <= {{10{1'b0}}, blocks_temp[189:0]};
                            end
                            32'd20:begin if (is_full_row[18]) 
                                    blocks_temp <= {{10{1'b0}}, blocks_temp[199:190], blocks_temp[179:0]};
                            end
                            32'd30:begin if (is_full_row[17]) 
                                    blocks_temp <= {{10{1'b0}}, blocks_temp[199:180], blocks_temp[169:0]};
                            end
                            32'd40:begin if (is_full_row[16]) 
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:170], blocks_temp[159:0]};
                            end
                            32'd50:begin if (is_full_row[15]) 
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:160], blocks_temp[149:0]};
                            end
                            32'd60:begin if (is_full_row[14]) 
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:150], blocks_temp[139:0]};
                            end
                            32'd70:begin if (is_full_row[13]) 
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:140], blocks_temp[129:0]};
                            end
                            32'd80:begin if (is_full_row[12]) 
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:130], blocks_temp[119:0]};
                            end
                            32'd90:begin if (is_full_row[11]) 
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:120], blocks_temp[109:0]};
                            end
                            32'd100:begin if (is_full_row[10]) 
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:110], blocks_temp[99:0]};
                            end
                            32'd110:begin if (is_full_row[9])  
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:100], blocks_temp[89:0]};
                            end
                            32'd120:begin if (is_full_row[8])  
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:90], blocks_temp[79:0]};
                            end
                            32'd130:begin if (is_full_row[7])  
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:80], blocks_temp[69:0]};
                            end
                            32'd140:begin if (is_full_row[6])  
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:70], blocks_temp[59:0]};
                            end
                            32'd150:begin if (is_full_row[5])  
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:60], blocks_temp[49:0]};
                            end
                            32'd160:begin if (is_full_row[4])  
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:50], blocks_temp[39:0]};
                            end
                            32'd170:begin if (is_full_row[3])  
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:40], blocks_temp[29:0]};
                            end
                            32'd180:begin if (is_full_row[2])  
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:30], blocks_temp[19:0]};
                            end
                            32'd190:begin if (is_full_row[1])  
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:20], blocks_temp[9:0]};
                            end
                            32'd200:begin if (is_full_row[0])  
                                blocks_temp <= {{10{1'b0}}, blocks_temp[199:10]};
                            end
                            32'd10000000: twinkle_color <= 1'b0; 
                            32'd20000000: twinkle_color <= 1'b1; 
                            32'd30000000: twinkle_color <= 1'b0; 
                            32'd40000000: twinkle_color <= 1'b1; 
                            32'd50000000: begin 
                                blocks_exist_clear <= blocks_temp; 
                                twinkle_color <= 1'b0;             
                                start_clear <= 2'b00; 
                                done_clear <= 1'b1;
                                game_next_state_clear <= `GENERATE_PIECE;
                            end
                            default: ;
                        endcase
                    end
                    else begin
                        game_next_state_clear <= `GENERATE_PIECE;
                        blocks_exist_clear <= blocks_exist;
                        start_clear <= 2'b10;
                    end
                end   
                if (start_clear == 2'b10 && !(| is_full_row))begin
                    start_clear <= 2'b00;
                    game_next_state_clear <= `CLEAR_ROW; //ensure the default next_state is clear_row
                end
            end
            else;
        end
    end
endmodule