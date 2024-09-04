// 写回regfile的数据的多选器

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module RegFile_wD_MUX(
    input logic  [`RF_WSEL_WIDTH-1:0] rf_wsel,
    input logic  [63:0] DRAM_rdo,
    input logic  [63:0] alu_c,
    input logic  [63:0] pc4,
    input logic  [63:0] sext,
    output logic [63:0] wD
    );
    
    always_comb begin
        case (rf_wsel) 
            `RF_WSEL_ALUC: wD = alu_c;
            `RF_WSEL_DRAM: wD = DRAM_rdo;
            `RF_WSEL_PC4:  wD = pc4;
            `RF_WSEL_SEXT: wD = sext;
            default:       wD = 64'b0;
        endcase
    end
endmodule
