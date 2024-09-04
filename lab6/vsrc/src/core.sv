`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module core import common::*;(
    input  logic       clk, reset,
    output ibus_req_t  ireq,
    // iresp.data 相当于从irom中读取指令  指令响应
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp,
    input  logic       trint, swint, exint
);

    /* TODO: Add your CPU-Core here. */
    logic [`SEL_CSR_WIDTH-1:0]  csr_sig;
    // regs to be written in next clock
    logic [`RegBus] nregs [0:`RegNum-1];

    // stall PC until dbus op done and have got the next instr
    logic stall, stall_next_ibus, stall_this_dbus;
    logic stall_this_alu_div,  stall_this_alu_mul;
    logic stall_this_alu_divw, stall_this_alu_mulw;
    logic stall_hazard;

    // instr and data, either been stalled, PC should be stalled
    assign stall = stall_next_ibus || stall_this_dbus || stall_this_alu_div || stall_this_alu_mul 
    || stall_this_alu_divw || stall_hazard;
    

    // pipeline
    logic HD_br;   // hazard-detection_branch
    logic id_rf1_occupied, id_rf2_occupied;
    logic if_id_flush, id_ex_flush, ex_mem_flush, mem_wb_flush;
    logic next_first_flush, next_second_flush;
    logic [`BitsWidth] if_pc, id_pc, ex_pc, mem_pc, wb_pc;
    logic [`BitsWidth] if_pc4, id_pc4, ex_pc4;
    logic [`BitsWidth] if_npc;
    logic [`InstrWidth] if_instr, id_instr, ex_instr, mem_instr, wb_instr;
    assign if_pc4 = if_pc + 4;

    logic [`ALUA_SEL_WIDTH-1:0] id_alua_sel;
    logic [`ALUB_SEL_WIDTH-1:0] id_alub_sel;
    logic [`BitsWidth] id_sext, ex_sext;
    logic ex_alu_f;
    logic [`NPC_SEL_WIDTH-1:0]  id_npc_op, ex_npc_op;
    logic [`ALU_OP_WIDTH-1:0]   id_alu_op, ex_alu_op;
    logic [`RF_WSEL_WIDTH-1:0]  id_rf_wsel, ex_rf_wsel, mem_rf_wsel;
    // lw，lb，lh，lwu, lbu，lhu，sb，sh，sw用到的信号，决定dbus是读/写字节还是半字还是字
    logic [`DBUS_SEL_WIDTH-1:0] id_dbus_sel, ex_dbus_sel, mem_dbus_sel;
    logic id_rf_we, ex_rf_we, mem_rf_we, wb_rf_we;
    logic id_dbus_wre, ex_dbus_wre, mem_dbus_wre;
    logic [`BitsWidth]  id_rD1, id_rD2, ex_rD2, mem_rD2;
    logic [`BitsWidth]  id_oprand_A, id_oprand_B, ex_oprand_A, ex_oprand_B;
    logic forward_A_sig, forward_B_sig;
    logic [`BitsWidth]  forward_A, forward_B;
    logic [`BitsWidth]  id_signed_A,  id_signed_B;
    logic [`HalfWidth]  id_signed_AW, id_signed_BW;
    logic [`BitsWidth]  ex_signed_A,  ex_signed_B;
    logic [`HalfWidth]  ex_signed_AW, ex_signed_BW;
    logic [4:0] ex_wR, mem_wR, wb_wR;
    logic [`BitsWidth]  ex_wD, mem_wD, wb_wD;
    logic [`BitsWidth]  ex_alu_c, mem_alu_c;
    // 0:not div_rem, 1:div, 2:rem
    logic [`SEL_DIV_WIDTH-1:0] id_div_rem_sig, ex_div_rem_sig;
    logic [`Sext_OP_WIDTH-1:0] id_sext_op;
    logic id_sign_signal, id_sign_rem, id_sign_signalw, id_sign_remw;
    logic ex_sign_signal, ex_sign_rem, ex_sign_signalw, ex_sign_remw;
    logic [`BitsWidth] ex_div_rem_c, ex_div_rem_w_c, ex_normal_alu_c, ex_mul_c;
    // data to be read from DBUS and to be written to regs
    logic [`BitsWidth] ex_DBUS_rdo, mem_DBUS_rdo;

    IF_ID_pipe my_pipe1(
        .clk(clk),
        .reset(reset),
        .stall(stall_hazard),
        .flush(if_id_flush),
        .if_pc(if_pc),       .id_pc(id_pc),
        .if_pc4(if_pc4),     .id_pc4(id_pc4),
        .if_instr(if_instr), .id_instr(id_instr)
    );

    ID_EX_pipe my_pipe2(
        .clk(clk),
        .reset(reset),
        .flush(id_ex_flush),
        .forward_A_sig(forward_A_sig),     .forward_B_sig(forward_B_sig),
        .forward_A(forward_A),             .forward_B(forward_B),
        .id_sext(id_sext),                 .ex_sext(ex_sext),
        .id_npc_op(id_npc_op),             .ex_npc_op(ex_npc_op),
        .id_alu_op(id_alu_op),             .ex_alu_op(ex_alu_op),
        .id_rf_wsel(id_rf_wsel),           .ex_rf_wsel(ex_rf_wsel),
        .id_dbus_sel(id_dbus_sel),         .ex_dbus_sel(ex_dbus_sel),
        .id_rf_we(id_rf_we),               .ex_rf_we(ex_rf_we),
        .id_pc4(id_pc4),                   .ex_pc4(ex_pc4), 
        .id_pc(id_pc),                     .ex_pc(ex_pc),
        .id_dbus_wre(id_dbus_wre),         .ex_dbus_wre(ex_dbus_wre),
        .id_rD2(id_rD2),                   .ex_rD2(ex_rD2),
        .id_oprand_A(id_oprand_A),         .ex_oprand_A(ex_oprand_A), 
        .id_oprand_B(id_oprand_B),         .ex_oprand_B(ex_oprand_B),
        .id_signed_A(id_signed_A),         .ex_signed_A(ex_signed_A),
        .id_signed_B(id_signed_B),         .ex_signed_B(ex_signed_B),
        .id_signed_AW(id_signed_AW),       .ex_signed_AW(ex_signed_AW),
        .id_signed_BW(id_signed_BW),       .ex_signed_BW(ex_signed_BW),
        .id_wR(id_instr[11:7]),            .ex_wR(ex_wR),
        .id_div_rem_sig(id_div_rem_sig),   .ex_div_rem_sig(ex_div_rem_sig),
        .id_sign_signal(id_sign_signal),   .ex_sign_signal(ex_sign_signal),
        .id_sign_rem(id_sign_rem),         .ex_sign_rem(ex_sign_rem), 
        .id_sign_signalw(id_sign_signalw), .ex_sign_signalw(ex_sign_signalw),
        .id_sign_remw(id_sign_remw),       .ex_sign_remw(ex_sign_remw),
        .id_instr(id_instr),               .ex_instr(ex_instr)
    );

    EX_MEM_pipe my_pipe3(
        .clk(clk),
        .reset(reset),
        .flush(ex_mem_flush),
        .ex_dbus_sel(ex_dbus_sel), .mem_dbus_sel(mem_dbus_sel),
        .ex_rf_we(ex_rf_we),       .mem_rf_we(mem_rf_we),
        .ex_dbus_wre(ex_dbus_wre), .mem_dbus_wre(mem_dbus_wre),
        .ex_rD2(ex_rD2),           .mem_rD2(mem_rD2),
        .ex_wR(ex_wR),             .mem_wR(mem_wR),
        .ex_wD(ex_wD),             .mem_wD(mem_wD),
        .ex_alu_c(ex_alu_c),       .mem_alu_c(mem_alu_c),
        .ex_rf_wsel(ex_rf_wsel),   .mem_rf_wsel(mem_rf_wsel),
        .ex_pc(ex_pc),             .mem_pc(mem_pc),
        .ex_instr(ex_instr),       .mem_instr(mem_instr),
        .ex_DBUS_rdo(ex_DBUS_rdo), .mem_DBUS_rdo(mem_DBUS_rdo)
    );

    MEM_WB_pipe my_pipe4(
        .clk(clk),
        .reset(reset),
        .flush(mem_wb_flush),
        .mem_rf_we(mem_rf_we), .wb_rf_we(wb_rf_we),
        .mem_wR(mem_wR),       .wb_wR(wb_wR),
        .mem_wD(mem_wD),       .wb_wD(wb_wD),
        .mem_pc(mem_pc),       .wb_pc(wb_pc),
        .mem_instr(mem_instr), .wb_instr(wb_instr)
    );

    HAZARD my_hazard(
        .clk(clk),
        .reset(reset),
        .branch(HD_br),
        .stall_hazard(stall_hazard),
        .rf1_occupied(id_rf1_occupied),
        .rf2_occupied(id_rf2_occupied),
        .forward_A_sig(forward_A_sig),
        .forward_B_sig(forward_B_sig),
        .forward_A(forward_A),
        .forward_B(forward_B),
        .flush1( next_first_flush), 
        .flush2(next_second_flush),
        .ex_rf_wsel(ex_rf_wsel),
        .id_rR1(id_instr[19:15]),
        .id_rR2(id_instr[24:20]),
        .ex_rf_we(ex_rf_we),
        .mem_rf_we(mem_rf_we),
        .wb_rf_we(wb_rf_we),
        .ex_wR(ex_wR), .mem_wR(mem_wR), .wb_wR(wb_wR),
        .ex_wD(ex_wD), .mem_wD(mem_wD), .wb_wD(wb_wD)
    );


    // procedure initialization
    Fetch my_Fetch(
        .clk(clk),
        .reset(reset),
        .npc(if_npc),
        .instr(if_instr),
        .instr1(id_instr),
        .iresp(iresp),
        .ireq(ireq),
        .stall(stall),
        .stall_this_dbus(stall_this_dbus),
        .stall_next_ibus(stall_next_ibus)
    );

    NPC my_NPC(
        .reset(reset),
        .PC(if_pc),
        .pc4(if_pc4),
        .npc(if_npc),
        .offset(ex_sext),
        .branch(ex_alu_f),
        .npc_op(ex_npc_op),
        .alu_c(ex_alu_c),
        .HD_br(HD_br)
    );

    PC my_PC(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .din(if_npc),
        .pc(if_pc)
    );

    SEXT my_SEXT(
        .din(id_instr[31:7]),
        .sext_op(id_sext_op),
        .sext(id_sext)
    );

    Control my_Control(
        .opcode(id_instr[6:0]),
        .funct3(id_instr[14:12]),
        .funct7(id_instr[31:25]),
        .sext_op(id_sext_op),
        .npc_op(id_npc_op),
        .alu_op(id_alu_op),
        .div_rem_sig(id_div_rem_sig),
        .alua_sel(id_alua_sel),
        .alub_sel(id_alub_sel),
        .rf_wsel(id_rf_wsel),
        .dbus_sel(id_dbus_sel),
        .rf_we(id_rf_we),
        .dbus_wre(id_dbus_wre),
        .rf1_occupied(id_rf1_occupied),
        .rf2_occupied(id_rf2_occupied),
        .csr_sig(csr_sig)
    );

    RegFile my_RegFile(
        .clk(clk),
        .reset(reset),
        .rR1(id_instr[19:15]),
        .rR2(id_instr[24:20]),
        .wR(wb_wR),
        .we(wb_rf_we),
        .wD(wb_wD),
        .stall(stall),
        .rD1(id_rD1),
        .rD2(id_rD2),
        .nregs(nregs)
    );

    RegFile_wD_MUX my_RegFile_wD_MUX(
        .rf_wsel(ex_rf_wsel),
        .DBUS_rdo(ex_DBUS_rdo),
        .alu_c(ex_alu_c),
        .pc4(ex_pc4),
        .sext(ex_sext),
        .wD(wb_wD)
    );

    ALU_input_MUX my_ALU_input_MUX(
        .rD1(id_rD1),
        .rD2(id_rD2),
        .shamt(id_instr[25:20]),
        .pc(id_pc),
        .sext(id_sext),
        .alua_sel(id_alua_sel),
        .alub_sel(id_alub_sel),
        .A(id_oprand_A), .A1(ex_oprand_A),
        .B(id_oprand_B), .B1(ex_oprand_B)
    );

    ALU_SIGN my_sign(
        .A(id_oprand_A),
        .B(id_oprand_B),
        .AW(id_oprand_A[31:0]),
        .BW(id_oprand_B[31:0]),
        .sign_signal(id_sign_signal),
        .sign_rem(id_sign_rem),
        .sign_signalw(id_sign_signalw),
        .sign_remw(id_sign_remw),
        .signed_A(id_signed_A),
        .signed_B(id_signed_B),
        .signed_AW(id_signed_AW),
        .signed_BW(id_signed_BW)
    );

    ALU my_ALU(
        .A(ex_oprand_A),
        .B(ex_oprand_B),
        .alu_op(ex_alu_op),
        .normal_alu_c(ex_normal_alu_c),
        .alu_f(ex_alu_f)
    );

    ALU_DIV my_alu_div(
        .clk(clk),
        .reset(reset),
        .origin_a(ex_oprand_A),
        .origin_b(ex_oprand_B),
        .a(ex_signed_A),
        .b(ex_signed_B),
        .sign_signal(ex_sign_signal),
        .sign_rem(ex_sign_rem),
        .sig(ex_div_rem_sig),
        .div_rem_c(ex_div_rem_c),
        .stall(stall),
        .stall_this_alu_div(stall_this_alu_div)
    );

    ALU_DIVW my_alu_divw(
        .clk(clk),
        .reset(reset),
        .origin_a(ex_oprand_A[31:0]),
        .origin_b(ex_oprand_B[31:0]),
        .a(ex_signed_AW),
        .b(ex_signed_BW),
        .sign_signalw(ex_sign_signalw),
        .sign_remw(ex_sign_remw),
        .sig(ex_div_rem_sig),
        .div_rem_w_c(ex_div_rem_w_c),
        .stall(stall),
        .stall_this_alu_divw(stall_this_alu_divw)
    );
    
    ALU_MUL my_alu_mul(
        .clk(clk),
        .reset(reset),
        .a(ex_signed_A),
        .b(ex_signed_B),
        .sign_signal(ex_sign_signal),
        .sig(ex_div_rem_sig),
        .mul_c(ex_mul_c),
        .stall(stall),
        .stall_this_alu_mul(stall_this_alu_mul)
    );

    ALU_output_MUX my_ALU_output_MUX(
        .normal_alu_c(ex_normal_alu_c),
        .div_rem_c(ex_div_rem_c),
        .div_rem_w_c(ex_div_rem_w_c),
        .mul_c(ex_mul_c),
        .alu_c(ex_alu_c),
        .div_rem_sig(ex_div_rem_sig)
    );

    MEM my_MEM(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .dbus_wre(id_dbus_wre),
        .addr_in(mem_alu_c),
        .wd_in(mem_rD2),
        .dbus_sel(mem_dbus_sel),
        .DBUS_rdata_out(ex_DBUS_rdo),
        .dresp(dresp),
        .dreq(dreq),
        .stall_this_dbus(stall_this_dbus)
    );


`ifdef VERILATOR
    DifftestInstrCommit DifftestInstrCommit(
        .clock              (clk),
        .coreid             (0),
        .index              (0),
        .valid              (~reset && ~stall),
        .pc                 (wb_pc),
        .instr              (wb_instr),
        .skip               (0),
        .isRVC              (0),
        .scFailed           (0),
        .wen                (wb_rf_we),
        .wdest              ({3'b0, wb_instr[11:7]}),
        .wdata              (wb_wD)
    );

    DifftestArchIntRegState DifftestArchIntRegState (
        .clock              (clk),
        .coreid             (0),
        .gpr_0              (nregs[0]),
        .gpr_1              (nregs[1]),
        .gpr_2              (nregs[2]),
        .gpr_3              (nregs[3]),
        .gpr_4              (nregs[4]),
        .gpr_5              (nregs[5]),
        .gpr_6              (nregs[6]),
        .gpr_7              (nregs[7]),
        .gpr_8              (nregs[8]),
        .gpr_9              (nregs[9]),
        .gpr_10             (nregs[10]),
        .gpr_11             (nregs[11]),
        .gpr_12             (nregs[12]),
        .gpr_13             (nregs[13]),
        .gpr_14             (nregs[14]),
        .gpr_15             (nregs[15]),
        .gpr_16             (nregs[16]),
        .gpr_17             (nregs[17]),
        .gpr_18             (nregs[18]),
        .gpr_19             (nregs[19]),
        .gpr_20             (nregs[20]),
        .gpr_21             (nregs[21]),
        .gpr_22             (nregs[22]),
        .gpr_23             (nregs[23]),
        .gpr_24             (nregs[24]),
        .gpr_25             (nregs[25]),
        .gpr_26             (nregs[26]),
        .gpr_27             (nregs[27]),
        .gpr_28             (nregs[28]),
        .gpr_29             (nregs[29]),
        .gpr_30             (nregs[30]),
        .gpr_31             (nregs[31])
    );

    DifftestTrapEvent DifftestTrapEvent(
        .clock              (clk),
        .coreid             (0),
        .valid              (0),
        .code               (0),
        .pc                 (wb_pc),
        .cycleCnt           (0),
        .instrCnt           (0)
    );

    DifftestCSRState DifftestCSRState(
        .clock              (clk),
        .coreid             (0),
        .priviledgeMode     (3),
        .mstatus            (0),
        .sstatus            (0),   /* mstatus & 64'h800000030001e000 */
        .mepc               (0),
        .sepc               (0),
        .mtval              (0),
        .stval              (0),
        .mtvec              (0),
        .stvec              (0),
        .mcause             (0),
        .scause             (0),
        .satp               (0),
        .mip                (0),
        .mie                (0),
        .mscratch           (0),
        .sscratch           (0),
        .mideleg            (0),
        .medeleg            (0)
    );
`endif
endmodule
`endif