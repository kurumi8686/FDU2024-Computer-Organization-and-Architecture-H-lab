// 选择输出的ALU数

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module ALU_output_MUX(
    input  logic [`BitsWidth] normal_alu_c, div_rem_c, mul_c,
    input  logic [`SEL_DIV_WIDTH-1:0] div_rem_sig, 
    output logic [`BitsWidth] alu_c
    );
    
    always_comb begin
        case (div_rem_sig) 
            `SEL_NORMAL: alu_c = normal_alu_c;
            `SEL_REM: alu_c = div_rem_c;
            `SEL_DIV: alu_c = div_rem_c;
            `SEL_DIVU: alu_c = div_rem_c;
            `SEL_REMU: alu_c = div_rem_c;
            `SEL_MUL: alu_c = mul_c;
            default: alu_c = 64'b0;
        endcase
    end

endmodule
