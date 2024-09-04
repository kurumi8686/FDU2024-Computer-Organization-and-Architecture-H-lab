// 内存操作，处理读写操�?

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`else
`include "def.vh"
`endif

module MEM import common::*;(
    input  logic clk,
    input  logic reset,
    input  logic stall,
    input  logic dbus_wre,
    input  logic [`BitsWidth] addr_in,	   // dbus的读写地�?
    input  logic [`BitsWidth] wd_in,	   // dbus的写数据
    input  logic [`DBUS_SEL_WIDTH-1:0] dbus_sel,
	input  dbus_resp_t dresp,
    output dbus_req_t  dreq,
    output logic [`BitsWidth] DBUS_rdata_out,
    output logic stall_this_dbus,
    output logic skip
    );

    logic [`STATUS_WIDTH] status_sel;
    // 0: initialize
    // 1: wait for rw
    // 2: rw done

    assign dreq.addr  = addr_in;
    assign dreq.valid = dbus_wre && (status_sel != `STATUS_DONE);
    assign stall_this_dbus = dreq.valid;
    assign skip = dbus_wre && ~addr_in[31];

    always_comb begin
        dreq.strobe = 8'b0000_0000;
        dreq.data = 64'b0;
        dreq.size = MSIZE8;
        
        unique case(dbus_sel)
            `DBUS_SEL_SB: begin
                dreq.size = MSIZE1;
                unique case(addr_in[2:0])
                    3'b000: begin
                        dreq.data[7:0] = wd_in[7:0];
                        dreq.strobe = 8'b0000_0001;
                    end
                    3'b001: begin
                        dreq.data[15:8] = wd_in[7:0];
                        dreq.strobe = 8'b0000_0010;
                    end
                    3'b010: begin
                        dreq.data[23:16] = wd_in[7:0];
                        dreq.strobe = 8'b0000_0100;
                    end
                    3'b011: begin
                        dreq.data[31:24] = wd_in[7:0];
                        dreq.strobe = 8'b0000_1000;                    
                    end
                    3'b100: begin
                        dreq.data[39:32] = wd_in[7:0];
                        dreq.strobe = 8'b0001_0000;
                    end
                    3'b101: begin
                        dreq.data[47:40] = wd_in[7:0];
                        dreq.strobe = 8'b0010_0000;
                    end
                    3'b110: begin
                        dreq.data[55:48] = wd_in[7:0];
                        dreq.strobe = 8'b0100_0000;
                    end
                    3'b111: begin
                        dreq.data[63:56] = wd_in[7:0];
                        dreq.strobe = 8'b1000_0000;
                    end
                    default: begin
                    end
                endcase
            end
            `DBUS_SEL_SH: begin
                dreq.size = MSIZE2;
                unique case(addr_in[2:1])
                    2'b00: begin
                        dreq.data[15:0] = wd_in[15:0];
                        dreq.strobe = 8'b0000_0011;
                    end
                    2'b01: begin
                        dreq.data[31:16] = wd_in[15:0];
                        dreq.strobe = 8'b0000_1100;
                    end
                    2'b10: begin
                        dreq.data[47:32] = wd_in[15:0];
                        dreq.strobe = 8'b0011_0000;
                    end
                    2'b11: begin
                        dreq.data[63:48] = wd_in[15:0];
                        dreq.strobe = 8'b1100_0000;
                    end
                    default: begin
                    end
                endcase
            end
            `DBUS_SEL_SW: begin
                dreq.size = MSIZE4;
                unique case(addr_in[2])
                    1'b0: begin
                        dreq.data[31:0] = wd_in[31:0];
                        dreq.strobe = 8'b0000_1111;
                    end
                    1'b1: begin
                        dreq.data[63:32] = wd_in[31:0];
                        dreq.strobe = 8'b1111_0000;
                    end
                    default: begin
                    end
                endcase
                
            end
            `DBUS_SEL_SD: begin
                dreq.size = MSIZE8;
                dreq.data = wd_in;
                dreq.strobe = 8'b1111_1111;
            end


            // load data
            `DBUS_SEL_LB: begin
                dreq.strobe = 8'b0000_0000;
                dreq.size = MSIZE1;
            end
            `DBUS_SEL_LBU: begin
                dreq.strobe = 8'b0000_0000;
                dreq.size = MSIZE1;
            end

            `DBUS_SEL_LH: begin
                dreq.strobe = 8'b0000_0000;
                dreq.size = MSIZE2;
            end
            `DBUS_SEL_LHU: begin
                dreq.strobe = 8'b0000_0000;
                dreq.size = MSIZE2;
            end

            `DBUS_SEL_LW: begin
                dreq.strobe = 8'b0000_0000;
                dreq.size = MSIZE4;
            end
            `DBUS_SEL_LWU: begin
                dreq.strobe = 8'b0000_0000;
                dreq.size = MSIZE4;
            end

            `DBUS_SEL_LD: begin
                dreq.strobe = 8'b0000_0000;
                dreq.size = MSIZE8;
            end

            default: begin
            end
        endcase
    end


    always_ff @(posedge clk) begin
        if (reset == `RstEnable) begin
            status_sel <= `STATUS_INIT;
        end else if (status_sel == `STATUS_INIT) begin
            if (dbus_wre) begin
                status_sel <= `STATUS_WAIT;
            end
        end else if (status_sel == `STATUS_WAIT) begin
            if (dresp.data_ok) begin
                if (dreq.strobe == 8'b0000_0000) begin        // "set strobe to zero for read request."
                    if(dbus_sel == `DBUS_SEL_LB) begin
                        unique case(addr_in[2:0])
                            3'b000: begin DBUS_rdata_out <= {{56{dresp.data[7]}}, dresp.data[7:0]}; end
                            3'b001: begin DBUS_rdata_out <= {{56{dresp.data[15]}}, dresp.data[15:8]}; end
                            3'b010: begin DBUS_rdata_out <= {{56{dresp.data[23]}}, dresp.data[23:16]}; end
                            3'b011: begin DBUS_rdata_out <= {{56{dresp.data[31]}}, dresp.data[31:24]}; end
                            3'b100: begin DBUS_rdata_out <= {{56{dresp.data[39]}}, dresp.data[39:32]}; end
                            3'b101: begin DBUS_rdata_out <= {{56{dresp.data[47]}}, dresp.data[47:40]}; end
                            3'b110: begin DBUS_rdata_out <= {{56{dresp.data[55]}}, dresp.data[55:48]}; end
                            3'b111: begin DBUS_rdata_out <= {{56{dresp.data[63]}}, dresp.data[63:56]}; end
                            default: begin end
                        endcase
                    end else if(dbus_sel == `DBUS_SEL_LBU) begin
                        unique case(addr_in[2:0])
                            3'b000: begin DBUS_rdata_out <= {{56'b0}, dresp.data[7:0]}; end
                            3'b001: begin DBUS_rdata_out <= {{56'b0}, dresp.data[15:8]}; end
                            3'b010: begin DBUS_rdata_out <= {{56'b0}, dresp.data[23:16]}; end
                            3'b011: begin DBUS_rdata_out <= {{56'b0}, dresp.data[31:24]}; end
                            3'b100: begin DBUS_rdata_out <= {{56'b0}, dresp.data[39:32]}; end
                            3'b101: begin DBUS_rdata_out <= {{56'b0}, dresp.data[47:40]}; end
                            3'b110: begin DBUS_rdata_out <= {{56'b0}, dresp.data[55:48]}; end
                            3'b111: begin DBUS_rdata_out <= {{56'b0}, dresp.data[63:56]}; end
                            default: begin end
                        endcase 
                    end else if(dbus_sel == `DBUS_SEL_LH) begin
                        unique case(addr_in[2:1])
                            2'b00: DBUS_rdata_out <= {{48{dresp.data[15]}}, dresp.data[15:0]};
                            2'b01: DBUS_rdata_out <= {{48{dresp.data[31]}}, dresp.data[31:16]};
                            2'b10: DBUS_rdata_out <= {{48{dresp.data[47]}}, dresp.data[47:32]};
                            2'b11: DBUS_rdata_out <= {{48{dresp.data[63]}}, dresp.data[63:48]};
                            default: begin end
                        endcase
                    end else if(dbus_sel == `DBUS_SEL_LHU) begin
                        unique case(addr_in[2:1])
                            2'b00: DBUS_rdata_out <= {{48'b0}, dresp.data[15:0]};
                            2'b01: DBUS_rdata_out <= {{48'b0}, dresp.data[31:16]};
                            2'b10: DBUS_rdata_out <= {{48'b0}, dresp.data[47:32]};
                            2'b11: DBUS_rdata_out <= {{48'b0}, dresp.data[63:48]};
                            default: begin end
                        endcase
                    end else if(dbus_sel == `DBUS_SEL_LW) begin
                        unique case(addr_in[2])
                            1'b0: DBUS_rdata_out <= {{32{dresp.data[31]}}, dresp.data[31:0]};
                            1'b1: DBUS_rdata_out <= {{32{dresp.data[63]}}, dresp.data[63:32]};
                            default: begin end
                        endcase
                    end else if(dbus_sel == `DBUS_SEL_LWU) begin
                        unique case(addr_in[2])
                            1'b0: DBUS_rdata_out <= {{32'b0}, dresp.data[31:0]};
                            1'b1: DBUS_rdata_out <= {{32'b0}, dresp.data[63:32]};
                            default: begin end
                        endcase
                    end else if(dbus_sel == `DBUS_SEL_LD) begin
                        DBUS_rdata_out <= dresp.data;
                    end
                end

                status_sel <= `STATUS_DONE;
            end
            
        end else begin
            if(~stall || reset == `RstEnable) begin
                status_sel <= `STATUS_INIT;
            end
        end
    end

endmodule
