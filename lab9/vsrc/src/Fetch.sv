// To fetch the next instr

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`else
`include "def.vh"
`endif

module Fetch import common::*;(
    input  logic               clk,
    input  logic               reset,
    input  logic [`BitsWidth]  iaddr,
    input  ibus_resp_t         iresp,
    output ibus_req_t          ireq,
    output logic [`InstrWidth] instr,
    input  logic stall,
    input  logic stall_this_dbus,
    output logic stall_next_ibus
    );

    assign ireq.addr = iaddr;
    assign ireq.valid = ~stall_this_dbus;
    assign stall_next_ibus = ~(iresp.data_ok && iresp.addr_ok);

    always_ff @(posedge clk) begin
        if(~stall) begin
            instr <= iresp.data;
        end
    end
endmodule
