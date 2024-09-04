// 控制ALU的输入：选出源操作数A和B

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module ALU_input_MUX(
    input  logic [`BitsWidth] rD1, rD2,
    input  logic [`BitsWidth] pc,      // instr_addr in this clock
    input  logic [`ShamtWidth] shamt,
    input  logic [`BitsWidth] sext,
    input  logic [`ALUA_SEL_WIDTH-1:0] alua_sel,     // source op a
    input  logic [`ALUB_SEL_WIDTH-1:0] alub_sel,	 // source op b
    output logic [`BitsWidth] A, B
    );
    
    always_comb begin
        case (alua_sel) 
            `ALUA_SEL_RD1: A = rD1;
            `ALUA_SEL_PC:  A = pc;
            default: A = 64'b0;
        endcase
    end
    
    always_comb begin
        case (alub_sel)
            `ALUB_SEL_RD2:  B = rD2;
            `ALUB_SEL_SEXT: B = sext;
            `ALUB_SEL_SHAMT: B = {58'b0, shamt[5:0]};
            default: B = 64'b0;
        endcase
    end
endmodule
