`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`else
`include "def.vh"
`endif

module NPC(
    input logic  reset,
    input logic  [`BitsWidth] PC, pc4, csr_npc,
    input logic  [`BitsWidth] offset,         // An imm
    input logic  branch,                      // B-type instruction result, determines whether a branch occurs
    input logic  [`NPC_SEL_WIDTH-1:0] npc_op, // Determine next_pc: pc+4 / pc+offset / set to alu_c
    input logic  [`BitsWidth]  alu_c,         // Result from ALU
    output logic [`BitsWidth]  npc
    );
    
    always_comb begin
        if (reset == `RstEnable) begin
            npc = `PCINIT;
        end else begin
            case(npc_op)
                // Sequential execution: npc_op==0
                `NPC_SEL_NEXT: npc = pc4;
                // B-type instruction, need to add offset: npc_op==1
                `NPC_SEL_BRANCH: begin
                    if(branch) begin
                        npc = PC + offset;
                    end else begin
                        npc = pc4;
                    end
                end
                // jalr
                `NPC_SEL_ALU: npc = alu_c;
                // jal
                `NPC_SEL_JAL: npc = PC + offset;
                // csr_mret, csr_ecall
                `NPC_SEL_CSR: npc = csr_npc;
                default: npc = `PCINIT;
            endcase
        end
    end
endmodule
