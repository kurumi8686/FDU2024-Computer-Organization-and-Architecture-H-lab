`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"

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
            pc <= `PCINIT;
        end else if (stall) begin
            pc <= pc;
        end else begin
            pc <= din;
        end
    end
endmodule
