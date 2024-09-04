// ALU module

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`else
`include "def.vh"
`endif

module ALU(
    input  logic [`BitsWidth] A, B,
    input  logic [`ALU_OP_WIDTH-1:0] alu_op,
    output logic [`BitsWidth] normal_alu_c,
    // Flag that shows whether it's a branch instruction
    output logic alu_f
    );
    
    logic [`BitsWidth] alu_c;
    logic [`BitsWidth] TEMP;
    logic [31:0] T_SRAW = A[31:0];
    logic [31:0] T_SRAW_RES;

    always_comb begin
    alu_c = 0;
    alu_f = 0;
        case (alu_op)
            `ALU_ADD:  begin alu_c = A + B; alu_f = 1'b0; end
            `ALU_SUB:  begin alu_c = A - B; alu_f = 1'b0; end
            `ALU_AND:  begin alu_c = A & B; alu_f = 1'b0; end
            `ALU_OR:   begin alu_c = A | B; alu_f = 1'b0; end
            `ALU_XOR:  begin alu_c = A ^ B; alu_f = 1'b0; end

            // lab3 add
            `ALU_SLL:  begin alu_c = A << B[5:0]; alu_f = 1'b0; end                      
            `ALU_SRL:  begin alu_c = A >> B[5:0]; alu_f = 1'b0; end
            `ALU_SRA:  begin alu_c = ($signed(A)) >>> B[5:0]; alu_f = 1'b0; end
            `ALU_SLT:  begin alu_c = ($signed(A) < $signed(B)) ? 1 : 0; alu_f = 1'b0; end
            `ALU_SLTU: begin alu_c = (A < B) ? 1 : 0; alu_f = 1'b0; end

            `ALU_BEQ:  alu_f = (A == B) ? 1 : 0;
            `ALU_BNE:  alu_f = (A != B) ? 1 : 0;  
            `ALU_BLT:  alu_f = ($signed(A) < $signed(B)) ? 1 : 0;   
            `ALU_BLTU: alu_f = (A < B) ? 1 : 0;                        
            `ALU_BGE:  alu_f = ($signed(A) >= $signed(B)) ? 1 : 0;     
            `ALU_BGEU: alu_f = (A >= B) ? 1 : 0;

            `ALU_SLLI:  begin alu_c = A << B[5:0]; alu_f = 1'b0; end                   
            `ALU_SRLI:  begin alu_c = A >> B[5:0]; alu_f = 1'b0; end
            `ALU_SRAI:  begin alu_c = ($signed(A)) >>> B[5:0]; alu_f = 1'b0; end
            `ALU_SLTI:  begin alu_c = ($signed(A) < $signed(B)) ? 1 : 0; alu_f = 1'b0; end
            `ALU_SLTIU: begin alu_c = (A < B) ? 1 : 0; alu_f = 1'b0; end


            // lab4 add
            `ALU_ADDW:  begin TEMP = A + B; alu_c = {{32{TEMP[31]}}, TEMP[31:0]}; alu_f = 1'b0; end
            `ALU_SUBW:  begin TEMP = A - B; alu_c = {{32{TEMP[31]}}, TEMP[31:0]}; alu_f = 1'b0; end
            `ALU_SLLW:  begin TEMP = A << B[4:0]; alu_c = {{32{TEMP[31]}}, TEMP[31:0]}; alu_f = 1'b0; end
            `ALU_SRLW:  begin 
                            TEMP = {{32'b0}, A[31:0]} >> B[4:0]; 
                            alu_c = {{32{TEMP[31]}}, TEMP[31:0]}; 
                            alu_f = 1'b0; 
                        end
            `ALU_SRAW:  begin 
                            T_SRAW_RES = ($signed(T_SRAW)) >>> B[4:0];
                            alu_c = {{32{A[31]}}, T_SRAW_RES[31:0]};
                            alu_f = 1'b0;
                        end

            `ALU_ADDIW: begin TEMP = A + B; alu_c = {{32{TEMP[31]}}, TEMP[31:0]}; alu_f = 1'b0; end

            // B[5:0] is shamt.
            `ALU_SLLIW: begin TEMP = A << B[5:0]; alu_c = {{32{TEMP[31]}}, TEMP[31:0]}; alu_f = 1'b0; end
            `ALU_SRLIW: begin
                            TEMP = {{32'b0}, A[31:0]} >> B[5:0]; 
                            alu_c = {{32{TEMP[31]}}, TEMP[31:0]}; 
                            alu_f = 1'b0;
                        end
            `ALU_SRAIW: begin
                            T_SRAW_RES = ($signed(T_SRAW)) >>> B[5:0];
                            alu_c = {{32{A[31]}}, T_SRAW_RES[31:0]};
                            alu_f = 1'b0;
                        end

            default:   begin alu_c = 64'b0; alu_f = 0; end
        endcase
    end
    assign normal_alu_c = alu_c;

endmodule
