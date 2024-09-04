// 当前时钟周期的PC�?

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`else
`include "def.vh"
`endif

module PC(
    input logic  clk,
    input logic  reset,
    input logic  stall,
    input logic  [`BitsWidth] din,
    output logic [`BitsWidth] pc
    );

    always_ff @(posedge clk) begin
        if (reset == `RstEnable) begin
            pc <= 64'h00000000_80000000;      // PCINIT
        end else if (stall) begin
            pc <= pc;
        end else begin
            pc <= din;
        end
    end
endmodule
