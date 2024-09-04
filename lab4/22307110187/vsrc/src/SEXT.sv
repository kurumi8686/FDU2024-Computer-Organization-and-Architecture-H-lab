// 立即数扩展

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module SEXT(
    input logic  [24:0] din,
    input logic  [`Sext_OP_WIDTH-1:0] sext_op,
    output logic [`BitsWidth] sext
    );
    
    always_comb begin
        case(sext_op)
            `Sext_I: sext = {{52{din[24]}}, din[24:13]};
            `Sext_S: sext = {{52{din[24]}}, din[24:18], din[4:0]};
            `Sext_B: sext = {{52{din[24]}}, din[0], din[23:18], din[4:1], {1'b0}};
            `Sext_U: sext = {{32{din[24]}}, din[24:5], 12'b0};
            `Sext_J: sext = {{44{din[24]}}, din[12:5], din[13], din[23:14], {1'b0}};
            default: sext = 64'b0;
        endcase
    end
endmodule
