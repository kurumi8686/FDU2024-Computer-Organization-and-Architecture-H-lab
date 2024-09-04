// ALU_DIV module

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module ALU_DIV import common::*;(
    input logic clk, reset,
    input logic [`BitsWidth] a, b, origin_a, origin_b,
    input logic [`SEL_DIV_WIDTH-1:0] sig,
    input logic sign_signal,
    input logic sign_rem,
    input logic stall,
    output logic[`BitsWidth] div_rem_c,
    output logic stall_this_alu_div
);

    localparam logic [6:0] CYCLES = 64;
    logic [6:0] count;

    // result = {a % b, a / b}
    logic [`MUL_DIV_Width] temp1, temp2;
    logic [`MUL_DIV_Width] tempu1, tempu2;

    // still in calculation process.
    // stall cpu, we need 64 cycles to calculate.
    assign stall_this_alu_div = (sig == `SEL_DIV || sig == `SEL_DIVU || sig == `SEL_REM || sig == `SEL_REMU) && (count != CYCLES);

    always_ff @(posedge clk)
    begin
        if(count == `DIV_INIT) begin
            if(sig == 0 || reset ==`RstEnable) begin
                count <= `DIV_INIT;
            end else begin
                // start 64cycles calculation.
                count <= `DIV_START;       
                temp1 = {64'b0, a};
                temp2 = {b, 64'b0};
                tempu1 = {64'b0, origin_a};
                tempu2 = {origin_b, 64'b0};
                temp1 = temp1 << 1;
                tempu1 = tempu1 << 1;
                if(temp1 >= temp2) begin
                    temp1 = temp1 - temp2 + 1;
                end
                if(tempu1 >= tempu2) begin
                    tempu1 = tempu1 - tempu2 + 1;
                end
            end

        end else if(count < CYCLES - 1) begin
            count <= count + 1;
            temp1 = temp1 << 1;
            tempu1 = tempu1 << 1;
            if(temp1 >= temp2) begin
                temp1 = temp1 - temp2 + 1;
            end
            if(tempu1 >= tempu2) begin
                tempu1 = tempu1 - tempu2 + 1;
            end

        end else if (count == CYCLES - 1)
        begin
            temp1 = temp1 << 1;
            tempu1 = tempu1 << 1;
            if(temp1 >= temp2) begin
                temp1 = temp1 - temp2 + 1;
            end
            if(tempu1 >= tempu2) begin
                tempu1 = tempu1 - tempu2 + 1;
            end

            if(sig == `SEL_DIV) begin
                if(b == 0) begin               // 除数为0
                    div_rem_c <= `minus_one;   // 64`hf
                end else if(sign_signal) begin
                    div_rem_c <= ~temp1[63:0] + 1;
                end else begin
                    div_rem_c <= temp1[63:0];
                end
            end else if(sig == `SEL_REM) begin
                if(b == 0) begin
                    div_rem_c <= origin_a;
                end else if(sign_rem) begin
                    div_rem_c <= ~temp1[127:64] + 1;
                end else begin
                    div_rem_c <= temp1[127:64];
                end
            end else if(sig == `SEL_DIVU) begin
                div_rem_c <= tempu1[63:0];
            end else if(sig == `SEL_REMU) begin
                div_rem_c <= tempu1[127:64];
            end

            count <= `DIV_END;
        end

        // not stall, means not div_rem or has been calculated over.
        else begin if(~stall || reset == `RstEnable) begin
                count <= `DIV_INIT;
            end
        end
    end
endmodule