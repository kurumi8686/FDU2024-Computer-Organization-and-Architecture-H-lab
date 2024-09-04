// 控制ALU的输入：选出源操作数a和b

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module ALU_input_MUX(
    input  logic [63:0] rD1,
    input  logic [63:0] rD2,
    input  logic [63:0] pc,      // instr_addr in this clock
    input  logic [63:0] sext,
    input  logic [`ALUA_SEL_WIDTH-1:0] alua_sel,     // source op a
    input  logic [`ALUB_SEL_WIDTH-1:0] alub_sel,	 // source op b
    output logic [63:0] A,
    output logic [63:0] B
    );
    
    always_comb begin
        case (alua_sel) 
            `ALUA_SEL_RD1: A = rD1;
            `ALUA_SEL_PC:  A = pc;
            default: A = 64'b0;     // Default assignment if no case matches
        endcase
    end
    
    always_comb begin
        case (alub_sel) 
            `ALUB_SEL_RD2:  B = rD2;
            `ALUB_SEL_SEXT: B = sext;
            default: B = 64'b0;     // Default assignment if no case matches
        endcase
    end
endmodule
