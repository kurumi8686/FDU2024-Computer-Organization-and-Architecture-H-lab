`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module EX_MEM_pipe import common::*;(
    input  logic clk,
    input  logic reset,
    input  logic flush,
    input  logic [`DBUS_SEL_WIDTH-1:0] ex_dbus_sel,
    output logic [`DBUS_SEL_WIDTH-1:0] mem_dbus_sel,
    input  logic ex_rf_we, output logic mem_rf_we,
    input  logic ex_dbus_wre, output logic mem_dbus_wre,
    input  logic [`BitsWidth] ex_rD2, output logic [`BitsWidth] mem_rD2,
    input  logic [4:0] ex_wR, output logic [4:0] mem_wR,
    input  logic [`BitsWidth] ex_wD, output logic [`BitsWidth] mem_wD,
    input  logic [`BitsWidth] ex_alu_c, output logic [`BitsWidth] mem_alu_c,
    input  logic [`RF_WSEL_WIDTH-1:0] ex_rf_wsel, output logic [`RF_WSEL_WIDTH-1:0] mem_rf_wsel,
    input  logic [`BitsWidth] ex_pc,  output logic [`BitsWidth] mem_pc,
    input  logic [`InstrWidth] ex_instr,  output logic [`InstrWidth] mem_instr,
    input  logic [`BitsWidth] ex_DBUS_rdo,  output logic [`BitsWidth] mem_DBUS_rdo
    );

    always_ff @(posedge clk) begin
        if(reset == `RstEnable || flush) begin
            mem_dbus_sel = 0;
            mem_rf_we <= 0;
            mem_dbus_wre <= 0;
            mem_rD2 <= 0;
            mem_wR <= 0;
            mem_wD <= 0;
            mem_alu_c <= 0;
            mem_rf_wsel <= 0;
            mem_pc <= 64'h00000000_80000000;
            mem_instr <= 32'b0;
            mem_DBUS_rdo <= 0;
        end else begin
            mem_dbus_sel = ex_dbus_sel;
            mem_rf_we <= ex_rf_we;
            mem_dbus_wre <= ex_dbus_wre;
            mem_rD2 <= ex_rD2;
            mem_wR <= ex_wR;
            mem_wD <= ex_wD;
            mem_alu_c <= ex_alu_c;
            mem_rf_wsel <= ex_rf_wsel;
            mem_pc <= ex_pc;
            mem_instr <= ex_instr;
            mem_DBUS_rdo <= ex_DBUS_rdo;
        end
    end

endmodule
