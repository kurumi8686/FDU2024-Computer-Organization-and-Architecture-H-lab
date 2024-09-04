// 内存操作，处理读写操作

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module MEM import common::*;(
    input  logic clk,
    input  logic reset,
    input  logic stall,
    input  logic dbus_wre,
    input  logic [`BitsWidth] addr_in,	   // dbus的读写地址
    input  logic [`BitsWidth] wd_in,	   // dbus的写数据
    input  logic [`DBUS_SEL_WIDTH-1:0] dbus_sel,
	input  dbus_resp_t dresp,
    output dbus_req_t  dreq,
    output logic [`BitsWidth] DBUS_rdata_out,
    output logic stall_this_dbus
    );

    // memory r or w status
    logic [`STATUS_WIDTH] status_sel;
    // 0: initialize
    // 1: wait for rw
    // 2: rw done

    assign dreq.addr  = addr_in;
    assign dreq.data  = wd_in;
    assign dreq.valid = dbus_wre && (status_sel != `STATUS_DONE);
    assign stall_this_dbus = dreq.valid && (status_sel != `STATUS_DONE);
    
    always_ff @(posedge clk) begin
        if (reset == `RstEnable) begin
            status_sel <= `STATUS_INIT;
        end else if (status_sel == `STATUS_INIT) begin
            if (dbus_wre) begin
                status_sel <= `STATUS_WAIT;
            end
        end else if (status_sel == `STATUS_WAIT) begin
            if (dresp.data_ok) begin
                if (dreq.strobe == 0) begin       // "set strobe to zero for read request."
                    DBUS_rdata_out <= dresp.data; // read data out
                end
                status_sel <= `STATUS_DONE;       // r or w done
            end
        end else begin                            // wait_mem == 2'b10
            if(~stall) begin
                status_sel <= `STATUS_INIT;       // reset with instr, for the next cycle.
            end
        end
    end


    always_comb begin
        case (dbus_sel)
            `DBUS_SEL_LD: begin
                dreq.strobe = 8'b0000_0000;
                dreq.size = MSIZE8;
            end
            `DBUS_SEL_SD: begin
                dreq.strobe = 8'b1111_1111;
                dreq.size = MSIZE8;
            end


        /*
            `DBUS_SEL_LW: 
            	rdo = DBUS_rdata_in;
                // TODO: 32 bits
            `DBUS_SEL_LB: 
                case (addr_in[1:0]) 
                    2'b00: rdo = {{56{DBUS_rdata_in[7]}},  DBUS_rdata_in[7:0]};
                    2'b01: rdo = {{56{DBUS_rdata_in[15]}}, DBUS_rdata_in[15:8]};
                    2'b10: rdo = {{56{DBUS_rdata_in[23]}}, DBUS_rdata_in[23:16]};
                    2'b11: rdo = {{56{DBUS_rdata_in[31]}}, DBUS_rdata_in[31:24]};
                    default: rdo = 64'b0;
                endcase
            `DBUS_SEL_LBU: 
                case (addr_in[1:0]) 
                    2'b00: rdo = {{56{1'b0}}, DBUS_rdata_in[7:0]};
                    2'b01: rdo = {{56{1'b0}}, DBUS_rdata_in[15:8]};
                    2'b10: rdo = {{56{1'b0}}, DBUS_rdata_in[23:16]};
                    2'b11: rdo = {{56{1'b0}}, DBUS_rdata_in[31:24]};
                    default: rdo = 64'b0;
                endcase */
            /*  // not finish yet
            `DBUS_SEL_LH:
                case (addr_in[1:0]) 
                    2'b00: rdo = {{48{DBUS_rdata_in[15]}}, DBUS_rdata_in[15:0]};
                    2'b01: rdo = {{48{DBUS_rdata_in[23]}}, DBUS_rdata_in[23:8]};
                    2'b10: rdo = {{48{DBUS_rdata_in[31]}}, DBUS_rdata_in[31:16]};
                    default: rdo = 64'b0;
                endcase 
            `DBUS_SEL_LHU: 
                case (addr_in[1:0]) 
                    2'b00: rdo = {{48{1'b0}}, DBUS_rdata_in[15:0]};
                    2'b01: rdo = {{48{1'b0}}, DBUS_rdata_in[23:8]};
                    2'b10: rdo = {{48{1'b0}}, DBUS_rdata_in[31:16]};
                    default: rdo = 64'b0;
                endcase
            `DBUS_SEL_SW: wdata_out = wdin;
            `DBUS_SEL_SB: 
                case (addr_in[1:0]) 
                    2'b00: wdata_out = {DBUS_rdata_in[63:8],  wdin[7:0]};
                    2'b01: wdata_out = {DBUS_rdata_in[63:16], wdin[7:0], DBUS_rdata_in[15:8]};
                    2'b10: wdata_out = {DBUS_rdata_in[63:24], wdin[7:0], DBUS_rdata_in[23:16]};
                    2'b11: wdata_out = {DBUS_rdata_in[63:32], wdin[7:0], DBUS_rdata_in[31:24]};
                    default: wdata_out = 64'b0;
                endcase 
            `DBUS_SEL_SH: 
                case (addr_in[1:0]) 
                    2'b00: wdata_out = {DBUS_rdata_in[63:16], wdin[15:0]};
                    2'b01: wdata_out = {DBUS_rdata_in[63:24], wdin[15:0], DBUS_rdata_in[23:8]};
                    2'b10: wdata_out = {DBUS_rdata_in[63:32], wdin[15:0], DBUS_rdata_in[31:16]};
                    default: wdata_out = 64'b0;
                endcase 
            `DBUS_SEL_SB: 
                case (addr_in[1:0]) 
                    2'b00: wdata_out = {DBUS_rdata_in[63:8],  wdin[7:0]};
                    2'b01: wdata_out = {DBUS_rdata_in[63:16], wdin[7:0], DBUS_rdata_in[15:8]};
                    2'b10: wdata_out = {DBUS_rdata_in[63:24], wdin[7:0], DBUS_rdata_in[23:16]};
                    2'b11: wdata_out = {DBUS_rdata_in[63:32], wdin[7:0], DBUS_rdata_in[31:24]};
                    default: wdata_out = 64'b0;
                endcase 
            `DBUS_SEL_SH: 
                case (addr_in[1:0]) 
                    2'b00: wdata_out = {DBUS_rdata_in[63:16], wdin[15:0]};
                    2'b01: wdata_out = {DBUS_rdata_in[63:24], wdin[15:0], DBUS_rdata_in[23:8]};
                    2'b10: wdata_out = {DBUS_rdata_in[63:32], wdin[15:0], DBUS_rdata_in[31:16]};
                    default: wdata_out = 64'b0;
                endcase
        */

            default: begin
                dreq.strobe = 8'b0000_0000;
                dreq.size = MSIZE8;
            end
        endcase 
    end
endmodule
