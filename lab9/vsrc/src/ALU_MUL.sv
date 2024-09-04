// ALU_MUL module

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`else
`include "def.vh"
`endif

module ALU_MUL import common::*;(
    input logic clk, reset,
    input logic [`BitsWidth] a, b,
    input logic [`SEL_DIV_WIDTH-1:0] sig,
    input logic sign_signal,
    input logic stall,
    output logic[`BitsWidth] mul_c,
    output logic stall_this_alu_mul
    );
    
    localparam logic [6:0] CYCLES = 64;
    logic [6:0] count;
    assign stall_this_alu_mul = (sig == `SEL_MUL || sig == `SEL_MULW) && (count != CYCLES);

    always_ff @(posedge clk) begin
        if(count == `MUL_INIT) begin
            if((sig != `SEL_MUL && sig != `SEL_MULW) || reset == `RstEnable) count <= `MUL_INIT;
            else begin
                if(b[count[5:0]] == 1) mul_c = a;
                count <= `MUL_START;
            end

        end else if(count <= CYCLES - 1 && count != `MUL_INIT) begin
        	if(b[count[5:0]] == 1) mul_c = (mul_c + (a << count));
        	count <= count + 1;
            if(count == CYCLES - 1) begin
                if(sign_signal) mul_c = ~mul_c + 1;
                if(sig == `SEL_MULW) mul_c = {{32{mul_c[31]}}, mul_c[31:0]};
            end

        end else begin
            if(~stall || reset == `RstEnable) begin
                count <= `MUL_INIT;
                mul_c = 0;
            end
        end
    end

endmodule
