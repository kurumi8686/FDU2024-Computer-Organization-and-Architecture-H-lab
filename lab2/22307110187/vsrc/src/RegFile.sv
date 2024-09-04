// Reg-file initialize

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module RegFile import common::*;(
    input  logic reset,
    input  logic clk,
    input  logic [`RegAddrBus] rR1, rR2, // [4:0]

    // reg-file write enable: if valid, write wD to reg[wR] in next clk
    input  logic we,  
    input  logic [`RegAddrBus] wR,
    input  logic [`BitsWidth]  wD,

    input  logic stall,
    output logic [`BitsWidth]  rD1, rD2,
    output logic [`BitsWidth]  nregs [0:`RegNum-1]
    );
    
    logic [`RegBus] regs [0:`RegNum-1];
    
    always_comb begin
        if (reset == `RstEnable) begin
            rD1 = 64'b0;
            rD2 = 64'b0;
        end else begin
            rD1 = regs[rR1];
            rD2 = regs[rR2];
        end
    end

    always_comb begin
        for (int i = 0; i < 64; i++) begin
            if (we && wR == i[`RegAddrBus]) begin
                nregs[i] = wD;
            end else begin
                nregs[i] = regs[i];
            end
        end
        // if change reg[0], reset it to zero.
        nregs[0] = 64'b0;  
    end
     
    always_ff @(posedge clk) begin
        // If there is a write enable and the write register is not x0(zero)
        if (reset == `RstDisable) begin
            if(wR != 5'b0 && we) begin
                if (~stall) begin     // 阻塞，若stall==1则不执行写入，保持regs的值
                    regs[wR] <= wD; 
                end
            end
        end else begin   // reset
            foreach (regs[i]) begin
                regs[i] <= 64'b0;
            end
        end
     end
endmodule
