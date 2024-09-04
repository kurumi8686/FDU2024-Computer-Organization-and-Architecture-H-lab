`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module MEM_WB_pipe import common::*;(
    input  logic clk,
    input  logic reset,
    input  logic flush,
    input  logic mem_rf_we, output logic wb_rf_we,
    input  logic [4:0] mem_wR, output logic [4:0] wb_wR,
    input  logic [`BitsWidth] mem_wD,  output logic [`BitsWidth] wb_wD,
    input  logic [`BitsWidth] mem_pc,  output logic [`BitsWidth] wb_pc,
    input  logic [`InstrWidth] mem_instr,  output logic [`InstrWidth] wb_instr
    );

    always_ff @(posedge clk) begin
        if(reset == `RstEnable || flush) begin
            wb_rf_we <= 0;
            wb_wR <= 0;
            wb_pc <= 64'h00000000_80000000;
            wb_instr <= 32'b0;
        end else begin
            wb_rf_we <= mem_rf_we;
            wb_wR <= mem_wR;
            wb_pc <= mem_pc;
            wb_instr <= mem_instr;
        end
    end

endmodule
