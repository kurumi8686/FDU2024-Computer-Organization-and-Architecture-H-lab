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
    input  logic [`BitsWidth]  npc,
    input  ibus_resp_t         iresp,
    output ibus_req_t          ireq,
    output logic [`InstrWidth] instr,

    input  logic stall,
    input  logic stall_this_dbus,
    output logic stall_next_ibus
    );

    // 准备下一个需要取的指令地�?
    assign ireq.addr = npc;
    // 当前周期访存操作未完成，valid=0
    assign ireq.valid = ~stall_this_dbus;
    // 若data未准备好或addr未准备好，则肯定无法从内存中取出下一个指令，stall
    assign stall_next_ibus = ~(iresp.data_ok && iresp.addr_ok);

    // 之前的流程已经执行完，addr_ok && data_ok，读取instr
    always_ff @(posedge clk) begin
        if(~stall) begin
            instr <= iresp.data;
        end
    end
    
endmodule
