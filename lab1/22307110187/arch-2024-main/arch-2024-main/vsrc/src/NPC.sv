// 给出下一时钟周期PC的值。

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module NPC(
    input logic          reset,
    input logic  [63:0]  PC,
    input logic  [63:0]  offset,        // An imm
    input logic          br,            // B-type instruction result, determines whether a branch occurs
    input logic  [1:0]   npc_op,        // Determine next_pc: pc+4 / pc+offset / set to alu_c
    input logic  [63:0]  alu_c,         // Result from ALU
    output logic [63:0]  npc,
    output logic [63:0]  pc4
    );
    
    assign pc4 = PC + 4;
    
    always_comb begin
        case(npc_op)
            // Sequential execution: npc_op==0
            `NPC_SEL_NEXT: npc = pc4;
            // B-type instruction, need to add offset: npc_op==1
            `NPC_SEL_BRANCH: begin
                if(br) begin
                    npc = PC + offset;
                end else begin
                    npc = pc4;
                end
            end
            // jalr: npc_op==3
            `NPC_SEL_ALU: npc = alu_c;
            // jal: npc_op==4
            `NPC_SEL_JAL: npc = PC + offset;
            default: npc = PCINIT;
        endcase
    end
endmodule
