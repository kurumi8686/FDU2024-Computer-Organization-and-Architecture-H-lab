`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`else
`include "def.vh"
`endif

module ALU_CSR import common::*;(
    input  clk, reset, stall,
    input  logic[11:0] rdd,
    input  logic[`BitsWidth] pc,
    input  logic csr_we,
    input  logic[4:0] rd,
    input  logic[`BitsWidth] a,
    input  logic[11:0] csr_regsel,
    input  logic[`SEL_CSR_WIDTH-1:0] csr_sig,
    output csr_regs_t csr_nregs,
    output logic[`BitsWidth] csr_c,
    output logic[`BitsWidth] csr_npc,
    output logic vir_translate
    );

    logic[`BitsWidth] nregs_rs;
    assign nregs_rs = (csr_sig == `SEL_CSRRW) ? a : (a | csr_c);
    csr_regs_t csr_regs;
    logic [1:0] mode = 3;

    always_comb begin
        csr_c = 0;
        case (csr_regsel)
            `CSR_SATP: csr_c = csr_regs.satp;
            `CSR_MSTATUS: csr_c = csr_regs.mstatus;
            `CSR_MIE: csr_c = csr_regs.mie;
            `CSR_MIP: csr_c = csr_regs.mip;
            `CSR_MTVEC: csr_c = csr_regs.mtvec;
            `CSR_MSCRATCH: csr_c = csr_regs.mscratch;
            `CSR_MEPC: csr_c = csr_regs.mepc;
            `CSR_MCAUSE: csr_c = csr_regs.mcause;
            `CSR_MTVAL: csr_c = csr_regs.mtval;
            default: csr_c = 64'b0;
        endcase
        vir_translate = (csr_nregs.mode != 3) && (csr_nregs.satp.mode == 4'b1000);
    end

    always_comb begin
        csr_nregs.mode = mode;
        csr_nregs.satp = csr_regs.satp;
        csr_nregs.mstatus = csr_regs.mstatus;
        csr_nregs.mie = csr_regs.mie;
        csr_nregs.mip = csr_regs.mip;
        csr_nregs.mtvec = csr_regs.mtvec;
        csr_nregs.mscratch = csr_regs.mscratch;
        csr_nregs.mepc = csr_regs.mepc;
        csr_nregs.mcause = csr_regs.mcause;
        csr_nregs.mtval = csr_regs.mtval;
        csr_npc = `PCINIT + 4;
        if (csr_we) begin
            case (csr_regsel)
                `CSR_SATP: csr_nregs.satp = nregs_rs;
                `CSR_MSTATUS: csr_nregs.mstatus = nregs_rs;
                `CSR_MIE: csr_nregs.mie = nregs_rs;
                `CSR_MIP: csr_nregs.mip = nregs_rs;
                `CSR_MTVEC: csr_nregs.mtvec = nregs_rs;
                `CSR_MSCRATCH: csr_nregs.mscratch = nregs_rs;
                `CSR_MEPC: csr_nregs.mepc = nregs_rs;
                `CSR_MCAUSE: csr_nregs.mcause = nregs_rs;
                `CSR_MTVAL: csr_nregs.mtval = nregs_rs;
                default: begin end
            endcase
        end else begin
            if (csr_sig == `SEL_MRET) begin
                csr_nregs.mode = csr_regs.mstatus.mpp;          // mode设置为mpp
                csr_nregs.mstatus.mie = csr_regs.mstatus.mpie;  // mie设置为mpie
                csr_nregs.mstatus.mpie = 1;                     // mpie设置为1
                csr_nregs.mstatus.mpp = 0;                      // 如果支持用户模式，将mpp设置为0
                csr_npc = csr_nregs.mepc;
            end else if (csr_sig == `SEL_ECALL || csr_sig == `SEL_CSR_INVALID) begin
                csr_nregs.mepc = pc;
                csr_npc = csr_nregs.mtvec;
                csr_nregs.mcause[63] = 0;
                csr_nregs.mcause[62:0] = {51'b0, rdd};
                csr_nregs.mstatus.mpie = csr_regs.mstatus.mie;
                csr_nregs.mstatus.mie = 0;
                csr_nregs.mstatus.mpp = mode;
                csr_nregs.mcause[62:0] = (csr_sig == `SEL_ECALL) ? 8 : 2;
                csr_nregs.mode = 3;
            end else begin end
        end
    end

    always_ff @(posedge clk) begin
        if (reset == `RstDisable && !stall && csr_we) begin
            case (csr_regsel)
                `CSR_SATP: csr_regs.satp <= nregs_rs;
                `CSR_MSTATUS: csr_regs.mstatus <= nregs_rs;
                `CSR_MIE: csr_regs.mie <= nregs_rs;
                `CSR_MIP: csr_regs.mip <= nregs_rs;
                `CSR_MTVEC: csr_regs.mtvec <= nregs_rs;
                `CSR_MSCRATCH: csr_regs.mscratch <= nregs_rs;
                `CSR_MEPC: csr_regs.mepc <= nregs_rs;
                `CSR_MCAUSE: csr_regs.mcause <= nregs_rs;
                `CSR_MTVAL: csr_regs.mtval <= nregs_rs;
                default: begin end
           endcase
        end else if (reset == `RstDisable && !stall && csr_sig == `SEL_MRET) begin
            csr_regs.mstatus <= csr_nregs.mstatus;
            mode <= csr_nregs.mode;
        end else if (reset == `RstDisable && !stall && (csr_sig == `SEL_ECALL || csr_sig == `SEL_CSR_INVALID)) begin
            csr_regs.mepc <= csr_nregs.mepc;
            csr_regs.mcause <= csr_nregs.mcause;
            csr_regs.mstatus <= csr_nregs.mstatus;  
            mode <= csr_nregs.mode;
        end else begin end
    end
endmodule