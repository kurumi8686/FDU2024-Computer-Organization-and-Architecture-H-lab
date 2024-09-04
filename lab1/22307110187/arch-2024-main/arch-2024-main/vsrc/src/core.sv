`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module core import common::*;(
	input  logic       clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,    // iresp.data 相当于从irom中读取指令
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
	input  logic       trint, swint, exint
);
	/* TODO: Add your CPU-Core here. */

    logic [63:0] npc;       // the next pc
    logic [63:0] pc;        // this clock pc
    logic [63:0] pc4;       // pc+4(in order)
    logic [63:0] sext;		// extension
    logic [`Sext_OP_WIDTH-1:0]   sext_op;
    logic alu_f;
    logic [63:0] alu_c;
    logic [`NPC_SEL_WIDTH-1:0]   npc_op;
    logic [`ALU_OP_WIDTH-1:0]    alu_op;
    logic [`ALUA_SEL_WIDTH-1:0]  alua_sel;
    logic [`ALUB_SEL_WIDTH-1:0]  alub_sel;
    logic [`RF_WSEL_WIDTH-1:0]   rf_wsel;
    logic [`DRAM_SEL_WIDTH-1:0]  dram_sel;    // lw，lb，lh，lbu，lhu，sb，sh，sw等才用到的信号，决定数据存储器的是读/写字节还是半字还是字
    logic rf_we;			 // reg-file写使能
    logic ram_we;   		 // dbus写使能
    logic [63:0] rD1;
    logic [63:0] rD2;
    logic [63:0] wD;
    logic [63:0] A;
    logic [63:0] B;
    
    logic [63:0] DRAM_rdo;   // 最终写入dbus的数据
    logic [63:0] Bus_rdata;  // dbus的读取数据
    logic [63:0] Bus_addr;	 // dbus读写地址
    logic Bus_wen;    		 // dbus写使能
    logic [63:0] Bus_wdata;  // dbus的写入数据

    logic [31:0] inst;
    logic [63:0] inst_addr;
    
    // PC更新准备好后，直接令ireq有效并加载当前地址
    assign inst_addr = pc;   //i64
    assign ireq.valid = 1'b1;
    assign ireq.addr = pc;

    // 判断之前步骤完成后（addr_ok且data_ok），将inst读取出来
    always_ff @(posedge clk or negedge reset) begin
    	if(iresp.addr_ok==1'b1 && iresp.data_ok==1'b1) begin
    		inst <= iresp.data;
    	end
    end

    // procedure initialization
    NPC my_NPC(
        .reset(reset),
        .PC(pc),
        .offset(sext),
        .br(alu_f),
        .npc_op(npc_op),
        .alu_c(alu_c),
        .npc(npc),
        .pc4(pc4)
    );

    PC my_PC(
    	.clk(clk),
      	.reset(reset),
      	.din(npc),
      	.pc(pc)
    );

    SEXT my_SEXT(
        .din(inst[31:7]),
        .sext_op(sext_op),
        .sext(sext)
    );

    Control my_Control(
        .opcode(inst[6:0]),
        .funct3(inst[14:12]),
        .funct7(inst[31:25]),
        .sext_op(sext_op),
        .npc_op(npc_op),
        .alu_op(alu_op),
        .alua_sel(alua_sel),
        .alub_sel(alub_sel),
        .rf_wsel(rf_wsel),
        .dram_sel(dram_sel),
        .rf_we(rf_we),
        .ram_we(ram_we)
    );

    RegFile my_RegFile(
    	.clk(clk),
        .reset(reset),
        .rR1(inst[19:15]),
        .rR2(inst[24:20]),
        .wR(inst[11:7]),
        .we(rf_we),
        .wD(wD),
        .rD1(rD1),
        .rD2(rD2)
    );

    RegFile_wD_MUX my_RegFile_wD_MUX(
        .rf_wsel(rf_wsel),
        .DRAM_rdo(DRAM_rdo),       // 最终需要写入dbus的数据
        .alu_c(alu_c),
        .pc4(pc4),
        .sext(sext),
        .wD(wD)
    );

    ALU my_ALU(
        .A(A),
        .B(B),
        .alu_op(alu_op),
        .alu_c(alu_c),
        .alu_f(alu_f)
    );
    
    ALU_input_MUX my_ALU_input_MUX(
        .rD1(rD1),
        .rD2(rD2),
        .pc(pc),
        .sext(sext),
        .alua_sel(alua_sel),
        .alub_sel(alub_sel),
        .A(A),
        .B(B)
    );

    MEM my_MEM(
        .we_in(ram_we),
        .addr_in(alu_c),
        .wdin(rD2),
        .dram_sel(dram_sel),
        .DRAM_rdata_in(Bus_rdata),
        .addr_out(Bus_addr),
        .we_out(Bus_wen),
        .wdata_out(Bus_wdata),
        .rdo(DRAM_rdo)
    );


`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (1'b1),
		.pc                 (PCINIT),
		.instr              (0),
		.skip               (0),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (0),
		.wdest              (0),
		.wdata              (0)
	);

	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (0),
		.gpr_1              (0),
		.gpr_2              (0),
		.gpr_3              (0),
		.gpr_4              (0),
		.gpr_5              (0),
		.gpr_6              (0),
		.gpr_7              (0),
		.gpr_8              (0),
		.gpr_9              (0),
		.gpr_10             (0),
		.gpr_11             (0),
		.gpr_12             (0),
		.gpr_13             (0),
		.gpr_14             (0),
		.gpr_15             (0),
		.gpr_16             (0),
		.gpr_17             (0),
		.gpr_18             (0),
		.gpr_19             (0),
		.gpr_20             (0),
		.gpr_21             (0),
		.gpr_22             (0),
		.gpr_23             (0),
		.gpr_24             (0),
		.gpr_25             (0),
		.gpr_26             (0),
		.gpr_27             (0),
		.gpr_28             (0),
		.gpr_29             (0),
		.gpr_30             (0),
		.gpr_31             (0)
	);

    DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
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



