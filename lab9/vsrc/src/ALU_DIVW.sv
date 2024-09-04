// ALU_DIVW module

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`else
`include "def.vh"
`endif

module ALU_DIVW import common::*;(
    input logic clk, reset,
    input logic [`HalfWidth] a, b, origin_a, origin_b,
    input logic [`SEL_DIV_WIDTH-1:0] sig,
    input logic sign_signalw,
    input logic sign_remw,
    input logic stall,
    output logic[`BitsWidth] div_rem_w_c,
    output logic stall_this_alu_divw
);

    localparam logic [5:0] CYCLES = 32;
    logic [5:0] count;

    // result = {a % b, a / b}
    logic [`BitsWidth] temp1, temp2;
    logic [`BitsWidth] tempu1, tempu2;
    logic [`HalfWidth] temp;

    // stall cpu, we need 32 cycles to calculate.
    assign stall_this_alu_divw = (sig == `SEL_DIVW || sig == `SEL_DIVUW || sig == `SEL_REMW || sig == `SEL_REMUW) 
        && (count != CYCLES);

    always_ff @(posedge clk)
    begin
        if(count == `DIV_INIT) begin
            if((sig != `SEL_DIVW && sig != `SEL_DIVUW && sig != `SEL_REMW && sig != `SEL_REMUW) || reset ==`RstEnable) begin
                count = `DIV_INIT;
            end else begin
                count = `DIV_START; 
                temp1 = {32'b0, a};
                temp2 = {b, 32'b0};
                tempu1 = {32'b0, origin_a};
                tempu2 = {origin_b, 32'b0};
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
            count = count + 1;
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

            if(sig == `SEL_DIVW) begin
                if(a < b) begin
                    div_rem_w_c = 64'b0;
                end else begin
                    if(a == 0 && b != 0) begin
                        div_rem_w_c = 64'b0;
                    end else if(a != 0 && b == 0) begin
                        div_rem_w_c = `minus_one;
                    end else if(a == 0 && b == 0) begin
                        div_rem_w_c = `minus_one;
                    end else begin
                        if(sign_signalw) begin
                            temp = ~temp1[31:0] + 1;
                            div_rem_w_c = {{32{temp[31]}}, temp[31:0]};
                        end else begin
                            div_rem_w_c = {{32{temp1[31]}}, temp1[31:0]};
                        end
                    end
                end
            end else if(sig == `SEL_REMW) begin
                if(b == 0) begin
                    div_rem_w_c = {{32{origin_a[31]}}, origin_a};
                end else if(sign_remw) begin
                    temp = ~temp1[63:32] + 1;
                    div_rem_w_c = {{32{temp[31]}}, temp[31:0]};
                end else begin
                    div_rem_w_c = {{32{temp1[63]}}, temp1[63:32]};
                end

            end else if(sig == `SEL_DIVUW) begin
                div_rem_w_c = {{32{tempu1[31]}}, tempu1[31:0]};

            end else if(sig == `SEL_REMUW) begin
                if(b == 0) begin
                    div_rem_w_c = {{32{origin_a[31]}}, origin_a};
                end else begin
                    div_rem_w_c = {{32{tempu1[63]}}, tempu1[63:32]};
                end
            end

            count = `DIV_ENDW;
        end

        // not stall, means not div_rem or has been calculated over.
        else begin if(~stall || reset == `RstEnable) begin
                count = `DIV_INIT;
            end
        end
    end
endmodule