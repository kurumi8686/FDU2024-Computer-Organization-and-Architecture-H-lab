`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module core import common::*;(
	input  logic       clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,    // iresp.data 相当于从irom中读取指令   指令响应
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
	input  logic       trint, swint, exint
);
	/* TODO: Add your CPU-Core here. */

    logic [`BitsWidth] npc;       // the next pc
    logic [`BitsWidth] pc;        // the pc in this clock
    logic [`BitsWidth] pc4;       // pc + 4(in order)
    logic [`BitsWidth] sext;      // extension
    logic [`Sext_OP_WIDTH-1:0] sext_op;
    logic alu_f;
    logic sign_signal, sign_rem;
    logic [`SEL_DIV_WIDTH-1:0] div_rem_sig;  // 0:not div_rem, 1:div, 2:rem
    logic [`BitsWidth] alu_c, div_rem_c, normal_alu_c, mul_c;
    logic [`NPC_SEL_WIDTH-1:0]  npc_op;
    logic [`ALU_OP_WIDTH-1:0]   alu_op;
    logic [`ALUA_SEL_WIDTH-1:0] alua_sel;
    logic [`ALUB_SEL_WIDTH-1:0] alub_sel;
    logic [`RF_WSEL_WIDTH-1:0]  rf_wsel;

    // lw，lb，lh，lbu，lhu，sb，sh，sw等才用到的信号，决定数据存储器是读/写字节还是半字还是字
    logic [`DBUS_SEL_WIDTH-1:0]  dbus_sel;

    logic rf_we;			 // reg-file write enable
    logic dbus_wre;   		 // dbus write and read enable
    logic [`BitsWidth]  rD1, rD2;
    logic [`BitsWidth]  wD;
    logic [`BitsWidth]  oprand_A, oprand_B;
    logic [`BitsWidth]  signed_A, signed_B;
    logic [`InstrWidth] instr;

    // data to be read from DBUS and to be written to regs
    logic [`BitsWidth] DBUS_rdo;

    // regs to be written in next clock
    logic [`RegBus] nregs [0:`RegNum-1];

    // stall PC until dbus op done and have got the next instr
    logic stall, stall_next_ibus, stall_this_dbus, stall_this_alu_div, stall_this_alu_mul;
    
    // instr and data, either been stalled, PC should be stalled
    assign stall = stall_next_ibus || stall_this_dbus || stall_this_alu_div || stall_this_alu_mul;
    assign pc4 = pc + 4;


    // procedure initialization
    Fetch my_Fetch(
        .clk(clk),
        .reset(reset),
        .npc(npc),
        .iresp(iresp),
        .ireq(ireq),
        .instr(instr),
        .stall(stall),
        .stall_this_dbus(stall_this_dbus),
        .stall_next_ibus(stall_next_ibus)
    );
    
    NPC my_NPC(
        .reset(reset),
        .PC(pc),
        .pc4(pc4),
        .offset(sext),
        .branch(alu_f),
        .npc_op(npc_op),
        .alu_c(alu_c),
        .npc(npc)
    );

    PC my_PC(
    	.clk(clk),
      	.reset(reset),
        .stall(stall),
      	.din(npc),
      	.pc(pc)
    );

    SEXT my_SEXT(
        .din(instr[31:7]),
        .sext_op(sext_op),
        .sext(sext)
    );

    Control my_Control(
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .sext_op(sext_op),
        .npc_op(npc_op),
        .alu_op(alu_op),
        .div_rem_sig(div_rem_sig),
        .alua_sel(alua_sel),
        .alub_sel(alub_sel),
        .rf_wsel(rf_wsel),
        .dbus_sel(dbus_sel),
        .rf_we(rf_we),
        .dbus_wre(dbus_wre)
    );

    RegFile my_RegFile(
    	.clk(clk),
        .reset(reset),
        .rR1(instr[19:15]),
        .rR2(instr[24:20]),
        .wR(instr[11:7]),
        .we(rf_we),
        .wD(wD),
        .stall(stall),
        .rD1(rD1),
        .rD2(rD2),
        .nregs(nregs)
    );

    RegFile_wD_MUX my_RegFile_wD_MUX(
        .rf_wsel(rf_wsel),
        .DBUS_rdo(DBUS_rdo),
        .alu_c(alu_c),
        .pc4(pc4),
        .sext(sext),
        .wD(wD)
    );

    ALU my_ALU(
        .A(oprand_A),
        .B(oprand_B),
        .alu_op(alu_op),
        .normal_alu_c(normal_alu_c),
        .alu_f(alu_f)
    );

    ALU_SIGN my_sign(
        .A(oprand_A),
        .B(oprand_B),
        .sign_signal(sign_signal),
        .sign_rem(sign_rem),
        .signed_A(signed_A),
        .signed_B(signed_B)
    );

    ALU_DIV my_alu_div(
        .clk(clk),
        .reset(reset),
        .origin_a(oprand_A),
        .origin_b(oprand_B),
        .a(signed_A),
        .b(signed_B),
        .sign_signal(sign_signal),
        .sign_rem(sign_rem),
        .sig(div_rem_sig),
        .div_rem_c(div_rem_c),
        .stall(stall),
        .stall_this_alu_div(stall_this_alu_div)
    );
    
    ALU_MUL my_alu_mul(
        .clk(clk),
        .reset(reset),
        .a(signed_A),
        .b(signed_B),
        .sign_signal(sign_signal),
        .sig(div_rem_sig),    //`SIG_MUL
        .mul_c(mul_c),
        .stall(stall),
        .stall_this_alu_mul(stall_this_alu_mul)
    );

    ALU_output_MUX my_ALU_output_MUX(
        .normal_alu_c(normal_alu_c), 
        .div_rem_c(div_rem_c),
        .mul_c(mul_c),
        .alu_c(alu_c),
        .div_rem_sig(div_rem_sig)
    );

    ALU_input_MUX my_ALU_input_MUX(
        .rD1(rD1),
        .rD2(rD2),
        .shamt(instr[25:20]),
        .pc(pc),
        .sext(sext),
        .alua_sel(alua_sel),
        .alub_sel(alub_sel),
        .A(oprand_A),
        .B(oprand_B)
    );

    MEM my_MEM(
    	.clk(clk),
        .reset(reset),
        .stall(stall),
        .dbus_wre(dbus_wre),
        .addr_in(alu_c),
        .wd_in(rD2),
        .dbus_sel(dbus_sel),
        .dresp(dresp),
        .dreq(dreq),
        .DBUS_rdata_out(DBUS_rdo),
        .stall_this_dbus(stall_this_dbus)
    );



`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (~reset && ~stall),
		.pc                 (pc),
		.instr              (instr),
		.skip               (0),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (rf_we),
		.wdest              ({3'b0, instr[11:7]}),
		.wdata              (wD)
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
		.pc                 (pc),
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