// ALU module

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module ALU(
    input  logic [`BitsWidth] A, B,
    input  logic [`ALU_OP_WIDTH-1:0] alu_op,
    output logic [`BitsWidth] alu_c,
    // Flag that shows whether it's a branch instruction
    output logic alu_f  
    );
    
    always_comb begin
        case (alu_op)
            `ALU_ADD:  begin alu_c = A + B; alu_f = 1'b0; end
            `ALU_SUB:  begin alu_c = A - B; alu_f = 1'b0; end
            `ALU_AND:  begin alu_c = A & B; alu_f = 1'b0; end
            `ALU_OR:   begin alu_c = A | B; alu_f = 1'b0; end
            `ALU_XOR:  begin alu_c = A ^ B; alu_f = 1'b0; end

            `ALU_SLL:  begin alu_c = A << B[4:0]; alu_f = 1'b0; end
            `ALU_SRL:  begin alu_c = A >> B[4:0]; alu_f = 1'b0; end
            `ALU_SRA:  begin alu_c = ($signed(A)) >>> B[4:0]; alu_f = 1'b0; end
            `ALU_SLT:  begin alu_c = ($signed(A) < $signed(B)) ? 1 : 0; alu_f = 1'b0; end
            `ALU_SLTU: begin alu_c = (A < B) ? 1 : 0; alu_f = 1'b0; end
 
            `ALU_BEQ:  alu_f = (A == B) ? 1 : 0;
            `ALU_BNE:  alu_f = (A != B) ? 1 : 0;
            `ALU_BLT:  alu_f = ($signed(A) < $signed(B)) ? 1 : 0;
            `ALU_BLTU: alu_f = (A < B) ? 1 : 0;
            `ALU_BGE:  alu_f = ($signed(A) >= $signed(B)) ? 1 : 0;
            `ALU_BGEU: alu_f = (A >= B) ? 1 : 0;

            default:   begin alu_c = 64'b0; alu_f = 0; end
        endcase
    end
endmodule
