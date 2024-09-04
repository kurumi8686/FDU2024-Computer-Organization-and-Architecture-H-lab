// Reg-file initialize

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module RegFile(
    input  logic reset,
    input  logic clk,
    input  logic [`RegAddrBus-1:0] rR1,  // [4:0]
    input  logic [`RegAddrBus-1:0] rR2,
    input  logic [`RegAddrBus-1:0] wR,    
    input  logic we,                     // reg-file write enable: if valid, write wD to reg[wR] in next clk
    input  logic [`RegBus-1:0] wD,       // [63:0]
    output logic [`RegBus-1:0] rD1,
    output logic [`RegBus-1:0] rD2
    );
    
    logic [`RegBus-1:0] regs [0:`RegNum];
     
    always_comb begin
        if (reset == `RstEnable) begin
            rD1 = 64'b0;
            rD2 = 64'b0;
        end else begin
            rD1 = regs[rR1];
            rD2 = regs[rR2];
        end
     end
     
     always_ff @(posedge clk) begin
         // If there is a write enable and the write register is not x0(zero)
        if (reset == `RstDisable) begin
            if (wR != 5'b0) begin
                if (we) begin
                    regs[wR] <= wD;
                end
            end
        end else begin           // Initialize or Reset
            foreach (regs[i]) begin
                regs[i] <= 64'b0;
            end
        end
     end
endmodule
