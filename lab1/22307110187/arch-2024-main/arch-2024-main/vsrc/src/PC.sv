// 当前时钟周期的PC值

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module PC(
    input logic         clk,
    input logic         reset,
    input logic  [63:0] din,
    output logic [63:0] pc
    );

    logic flag;     // reset flag

    always_ff @(posedge clk, posedge reset) begin
        if (reset == `RstEnable) begin
            pc <= PCINIT;
            flag <= 1'b1;
        end else if (flag == 1'b1) begin
            pc <= PCINIT;
            flag <= 1'b0;
        end else begin
            pc <= din;
            flag <= flag;
        end
    end
endmodule
