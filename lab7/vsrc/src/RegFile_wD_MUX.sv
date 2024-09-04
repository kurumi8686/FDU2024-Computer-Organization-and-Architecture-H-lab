// 写回regfile的数据的多�?�器

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`else
`include "def.vh"
`endif

module RegFile_wD_MUX import common::*;(
    input logic  [`RF_WSEL_WIDTH-1:0] rf_wsel,
    input logic  [`BitsWidth]         DBUS_rdo,
    input logic  [`BitsWidth]         alu_c,
    input logic  [`BitsWidth]         pc4,
    input logic  [`BitsWidth]         sext,
    output logic [`BitsWidth]         wD
    );
    
    always_comb begin
        case (rf_wsel) 
            `RF_WSEL_ALUC: wD = alu_c;
            `RF_WSEL_DBUS: wD = DBUS_rdo;
            `RF_WSEL_PC4:  wD = pc4;
            `RF_WSEL_SEXT: wD = sext;
            default:       wD = 64'b0;
        endcase
    end
endmodule
