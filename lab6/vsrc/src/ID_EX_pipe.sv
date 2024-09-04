`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module ID_EX_pipe import common::*;(
    input  logic clk,
    input  logic reset,
    input  logic flush,
    input  logic [`BitsWidth] id_sext, output logic [`BitsWidth] ex_sext,
    input  logic [`NPC_SEL_WIDTH-1:0] id_npc_op, output logic [`NPC_SEL_WIDTH-1:0] ex_npc_op,
    input  logic [`ALU_OP_WIDTH-1:0]  id_alu_op, output logic [`ALU_OP_WIDTH-1:0]  ex_alu_op,
    input  logic [`RF_WSEL_WIDTH-1:0] id_rf_wsel, output logic [`RF_WSEL_WIDTH-1:0] ex_rf_wsel,
    input  logic [`DBUS_SEL_WIDTH-1:0] id_dbus_sel, output logic [`DBUS_SEL_WIDTH-1:0] ex_dbus_sel,
    input  logic id_rf_we, output logic ex_rf_we,
    input  logic id_dbus_wre, output logic ex_dbus_wre,
    input  logic [`BitsWidth] id_rD2, output logic [`BitsWidth] ex_rD2,
    input  logic [`BitsWidth] id_signed_A, id_signed_B, 
    input  logic [`HalfWidth] id_signed_AW, id_signed_BW,
    output logic [`BitsWidth] ex_signed_A, ex_signed_B, 
    output logic [`HalfWidth] ex_signed_AW, ex_signed_BW,
    input  logic [`BitsWidth] id_oprand_A, output logic [`BitsWidth] ex_oprand_A,
    input  logic [`BitsWidth] id_oprand_B, output logic [`BitsWidth] ex_oprand_B,
    input  logic forward_A_sig, input  logic forward_B_sig,
    input  logic [`BitsWidth] forward_A, input  logic [`BitsWidth] forward_B,
    input  logic [4:0] id_wR, output logic [4:0] ex_wR,
    input  logic [`BitsWidth] id_pc4, output logic [`BitsWidth] ex_pc4,
    input  logic [`BitsWidth] id_pc,  output logic [`BitsWidth] ex_pc,
    input  logic [`SEL_DIV_WIDTH-1:0] id_div_rem_sig,
    output logic [`SEL_DIV_WIDTH-1:0] ex_div_rem_sig,
    input  logic id_sign_signal,  output logic ex_sign_signal,
    input  logic id_sign_rem,     output logic ex_sign_rem,
    input  logic id_sign_signalw, output logic ex_sign_signalw,
    input  logic id_sign_remw,    output logic ex_sign_remw,
    input  logic [`InstrWidth] id_instr,  output logic [`InstrWidth] ex_instr
    );

    always_ff @(posedge clk) begin
        if(reset == `RstEnable) begin
            ex_oprand_A = 0;
        end else if(forward_A_sig == 1) begin
            ex_oprand_A = forward_A;
        end else begin
            ex_oprand_A = id_oprand_A;
        end
    end

    always_ff @(posedge clk) begin
        if(reset ==`RstEnable) begin
            ex_oprand_B = 0;
        end else if(forward_B_sig == 1 && !id_dbus_wre) begin
            ex_oprand_B = forward_B;
        end else begin
            ex_oprand_B = id_oprand_B;
        end
    end

    always_ff @(posedge clk) begin
        if(reset == `RstEnable || flush) begin
            ex_sext <= 0;
            ex_npc_op <= 0;
            ex_alu_op <= 0;
            ex_rf_wsel <= 0;
            ex_dbus_sel = 0;
            ex_rf_we <= 0;
            ex_dbus_wre <= 0;
            ex_wR <= 0;
            ex_div_rem_sig = 0;
            ex_sign_signal <= 0;
            ex_sign_rem <= 0;
            ex_sign_signalw <= 0;
            ex_sign_remw <= 0;
            ex_signed_A  = 0;
            ex_signed_AW = 0;
            ex_signed_B  = 0;
            ex_signed_BW = 0;
            ex_pc4 <= 64'h00000000_80000004;
            ex_pc <= 64'h00000000_80000000;
            ex_instr <= 0;
            ex_rD2 <= 0;
        end else begin
            ex_sext <= id_sext;
            ex_npc_op <= id_npc_op;
            ex_alu_op <= id_alu_op;
            ex_rf_wsel <= id_rf_wsel;
            ex_dbus_sel = id_dbus_sel;
            ex_rf_we <= id_rf_we;
            ex_dbus_wre <= id_dbus_wre;
            ex_wR <= id_wR;
            ex_div_rem_sig = id_div_rem_sig;
            ex_sign_signal <= id_sign_signal;
            ex_sign_rem <= id_sign_rem;
            ex_sign_signalw <= id_sign_signalw;
            ex_sign_remw <= id_sign_remw;
            ex_signed_A  = id_signed_A;
            ex_signed_AW = id_signed_AW;
            ex_signed_B  = id_signed_B;
            ex_signed_BW = id_signed_BW;
            ex_pc4 <= id_pc4;
            ex_pc <= id_pc;
            ex_instr <= id_instr;
            ex_rD2 <= id_rD2;
        end
    end


endmodule
