// 给出下一时钟周期PC的值。

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module NPC(
    input logic  reset,
    input logic  [`BitsWidth] PC,
    input logic  [`BitsWidth] pc4,
    input logic  [`BitsWidth] offset,         // An imm
    input logic  branch,                      // B-type instruction result, determines whether a branch occurs
    input logic  [`NPC_SEL_WIDTH-1:0] npc_op, // Determine next_pc: pc+4 / pc+offset / set to alu_c
    input logic  [`BitsWidth]  alu_c,         // Result from ALU
    output logic [`BitsWidth]  npc,
    output logic HD_br
    );
    
    always_comb begin
        if (reset == `RstEnable) begin
            npc = 64'h00000000_80000000;  //PCINIT
            HD_br = 0;
        end else begin
            case(npc_op)
                // Sequential execution: npc_op==0
                `NPC_SEL_NEXT: begin
                    npc = pc4;
                    HD_br = 0;
                end
                // B-type instruction, need to add offset: npc_op==1
                `NPC_SEL_BRANCH: begin
                    if(branch) begin
                        npc = PC + offset;
                        HD_br = 1;
                    end else begin
                        npc = pc4;
                        HD_br = 0;
                    end
                end
                // jalr: npc_op==2
                `NPC_SEL_ALU: begin
                    npc = alu_c;
                    HD_br = 1;
                end
                // jal:  npc_op==3
                `NPC_SEL_JAL: begin
                    npc = PC + offset;
                    HD_br = 1;
                end
                default: begin
                    npc = 64'h00000000_80000000;
                    HD_br = 0;
                end
            endcase
        end
    end
endmodule
