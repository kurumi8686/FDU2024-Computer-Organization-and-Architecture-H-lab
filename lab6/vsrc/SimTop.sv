`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"

`include "src/core.sv"
`include "src/Fetch.sv"
`include "src/PC.sv"
`include "src/NPC.sv"
`include "src/Control.sv"
`include "src/RegFile.sv"
`include "src/RegFile_wD_MUX.sv"
`include "src/ALU.sv"
`include "src/ALU_input_MUX.sv"
`include "src/MEM.sv"
`include "src/SEXT.sv"
`include "src/ALU_SIGN.sv"
`include "src/ALU_DIV.sv"
`include "src/ALU_DIVW.sv"
`include "src/ALU_MUL.sv"
`include "src/ALU_output_MUX.sv"
`include "src/IF_ID_pipe.sv"
`include "src/ID_EX_pipe.sv"
`include "src/EX_MEM_pipe.sv"
`include "src/MEM_WB_pipe.sv"
`include "src/HAZARD.sv"

`include "util/IBusToCBus.sv"
`include "util/DBusToCBus.sv"
`include "util/CBusArbiter.sv"

module SimTop import common::*;(
  input         clock,
  input         reset,
  input  [63:0] io_logCtrl_log_begin,
  input  [63:0] io_logCtrl_log_end,
  input  [63:0] io_logCtrl_log_level,
  input         io_perfInfo_clean,
  input         io_perfInfo_dump,
  output        io_uart_out_valid,
  output [7:0]  io_uart_out_ch,
  output        io_uart_in_valid,
  input  [7:0]  io_uart_in_ch
);

    cbus_req_t  oreq;
    cbus_resp_t oresp;
    logic trint, swint, exint;

    ibus_req_t  ireq;
    ibus_resp_t iresp;
    dbus_req_t  dreq;
    dbus_resp_t dresp;
    cbus_req_t  icreq,  dcreq;
    cbus_resp_t icresp, dcresp;

    core core(
      .clk(clock), .reset, .ireq, .iresp, .dreq, .dresp, .trint, .swint, .exint
    );

    IBusToCBus icvt(.*);
    DBusToCBus dcvt(.*);
    CBusArbiter mux(
        .clk(clock), .reset,
        .ireqs({icreq, dcreq}),
        .iresps({icresp, dcresp}),
        .*
    );

    RAMHelper2 ram(
        .clk(clock), .reset, .oreq, .oresp, .trint, .swint, .exint
    );

    assign {io_uart_out_valid, io_uart_out_ch, io_uart_in_valid} = '0;

endmodule
`endif