`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module IF_ID_pipe import common::*;(
    input  logic               clk,
    input  logic               reset,
    input  logic               stall,
    input  logic               flush,
    input  logic [`BitsWidth]  if_pc,
    input  logic [`BitsWidth]  if_pc4,
    input  logic [`InstrWidth] if_instr,
    output logic [`BitsWidth]  id_pc,
    output logic [`BitsWidth]  id_pc4,
    output logic [`InstrWidth] id_instr
    );

always_ff @(posedge clk) begin
    if(reset == `RstEnable || flush) begin
        id_pc = 64'h00000000_80000000;
        id_pc4 = 64'h00000000_80000004;
        id_instr = 32'b0;
    end else if(stall) begin
        id_pc = id_pc;
        id_pc4 = id_pc4;
        id_instr = id_instr;
    end else begin
        id_pc = if_pc;
        id_pc4 = if_pc4;
        id_instr = if_instr;
    end
end

endmodule
