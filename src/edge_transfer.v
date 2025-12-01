`timescale 1ns / 1ps

module edge_transfer(
    input clk, 
    input rst_n,     
    input signal_in,    
    output wire pulse   
);

    parameter CNT_MAX = 21'd200000; 
    
    reg [20:0] cnt;
    reg key_sync0;
    reg key_sync1;
    //input debounce and edge detection
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_sync0 <= 1'b0;
            key_sync1 <= 1'b0;
        end
        else begin
            key_sync0 <= signal_in; 
            key_sync1 <= key_sync0; 
        end
    end

    reg key_stable;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 20'd0;
            key_stable <= 1'b0;
        end
        else begin
            if (key_sync1 != key_stable) begin
                if (cnt < CNT_MAX) begin
                    cnt <= cnt + 1'b1;
                end
                else begin
                    key_stable <= key_sync1;
                    cnt <= 20'd0;
                end
            end
            else begin
                cnt <= 20'd0;
            end
        end
    end
    reg key_stable_d1; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            key_stable_d1 <= 1'b0;
        else 
            key_stable_d1 <= key_stable;
    end

    assign pulse = key_stable & (~key_stable_d1);

endmodule