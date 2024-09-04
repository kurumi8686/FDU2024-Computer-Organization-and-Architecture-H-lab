// 内存操作，处理读写(字、半字等)--(not request)

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module MEM(
    input  logic clk,
    input  logic we_in,
    input  logic [63:0] addr_in,	   // dbus的读写地址 
    input  logic [63:0] wdin,
    input  logic [`DRAM_SEL_WIDTH-1:0] dram_sel,
    input  logic [63:0] DRAM_rdata_in,
    output logic [63:0] addr_out,      // dbus的读写地址
    output logic we_out,			   // 读写使能
    output logic [63:0] wdata_out,	   // dbus写数据
    output logic [63:0] rdo			   // 最终从dbus读写的数据
    );
    
    assign we_out = we_in;
    assign addr_out = addr_in;
    
    always_comb begin
        case (dram_sel) 
            `DRAM_SEL_LW: 
            	rdo = DRAM_rdata_in;
            `DRAM_SEL_LB: 
                case (addr_in[1:0]) 
                    2'b00: rdo = {{56{DRAM_rdata_in[7]}},  DRAM_rdata_in[7:0]};
                    2'b01: rdo = {{56{DRAM_rdata_in[15]}}, DRAM_rdata_in[15:8]};
                    2'b10: rdo = {{56{DRAM_rdata_in[23]}}, DRAM_rdata_in[23:16]};
                    2'b11: rdo = {{56{DRAM_rdata_in[31]}}, DRAM_rdata_in[31:24]};
                    default: rdo = 64'b0;
                endcase
            `DRAM_SEL_LBU: 
                case (addr_in[1:0]) 
                    2'b00: rdo = {{56{1'b0}}, DRAM_rdata_in[7:0]};
                    2'b01: rdo = {{56{1'b0}}, DRAM_rdata_in[15:8]};
                    2'b10: rdo = {{56{1'b0}}, DRAM_rdata_in[23:16]};
                    2'b11: rdo = {{56{1'b0}}, DRAM_rdata_in[31:24]};
                    default: rdo = 64'b0;
                endcase 

            /*  // not finish yet
            `DRAM_SEL_LH:
                case (addr_in[1:0]) 
                    2'b00: rdo = {{48{DRAM_rdata_in[15]}}, DRAM_rdata_in[15:0]};
                    2'b01: rdo = {{48{DRAM_rdata_in[23]}}, DRAM_rdata_in[23:8]};
                    2'b10: rdo = {{48{DRAM_rdata_in[31]}}, DRAM_rdata_in[31:16]};
                    default: rdo = 64'b0;
                endcase 
            `DRAM_SEL_LHU: 
                case (addr_in[1:0]) 
                    2'b00: rdo = {{48{1'b0}}, DRAM_rdata_in[15:0]};
                    2'b01: rdo = {{48{1'b0}}, DRAM_rdata_in[23:8]};
                    2'b10: rdo = {{48{1'b0}}, DRAM_rdata_in[31:16]};
                    default: rdo = 64'b0;
                endcase
            
            `DRAM_SEL_SW: wdata_out = wdin;
            `DRAM_SEL_SB: 
                case (addr_in[1:0]) 
                    2'b00: wdata_out = {DRAM_rdata_in[63:8],  wdin[7:0]};
                    2'b01: wdata_out = {DRAM_rdata_in[63:16], wdin[7:0], DRAM_rdata_in[15:8]};
                    2'b10: wdata_out = {DRAM_rdata_in[63:24], wdin[7:0], DRAM_rdata_in[23:16]};
                    2'b11: wdata_out = {DRAM_rdata_in[63:32], wdin[7:0], DRAM_rdata_in[31:24]};
                    default: wdata_out = 64'b0;
                endcase 
            `DRAM_SEL_SH: 
                case (addr_in[1:0]) 
                    2'b00: wdata_out = {DRAM_rdata_in[63:16], wdin[15:0]};
                    2'b01: wdata_out = {DRAM_rdata_in[63:24], wdin[15:0], DRAM_rdata_in[23:8]};
                    2'b10: wdata_out = {DRAM_rdata_in[63:32], wdin[15:0], DRAM_rdata_in[31:16]};
                    default: wdata_out = 64'b0;
                endcase 
            */

            default: begin
                wdata_out = wdin;
                rdo = 64'b0;
            end
        endcase 
    end
endmodule
