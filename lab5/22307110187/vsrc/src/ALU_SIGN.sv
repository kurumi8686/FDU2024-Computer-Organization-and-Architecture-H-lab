// SIGN module, get sign signal, transfer AB to unsigned number. 

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module ALU_SIGN import common::*;(
    input  logic [`BitsWidth] A, B,
    input  logic [`HalfWidth] AW, BW,
    output logic sign_signal,
    output logic sign_rem,
    output logic [`BitsWidth] signed_A, signed_B,
    output logic [`HalfWidth] signed_AW, signed_BW,
    output logic sign_signalw,
    output logic sign_remw
    );

    always_latch
    begin
        if(A[63] == 1 && B[63] == 1) begin
            sign_signal = 0;
            sign_rem = 1;
            signed_A = ~A + 1;
            signed_B = ~B + 1;
        end 
        if(A[63] == 0 && B[63] == 0) begin
            sign_signal = 0;
            sign_rem = 0;
            signed_A = A;
            signed_B = B;
        end 
        if(A[63] == 1 && B[63] == 0) begin
            sign_signal = 1;
            sign_rem = 1;
            signed_A = ~A + 1;
            signed_B = B;
        end 
        if(A[63] == 0 && B[63] == 1) begin
            sign_signal = 1;
            sign_rem = 0;
            signed_A = A;
            signed_B = ~B + 1;
        end
        if(A[31] == 1 && B[31] == 1) begin
            sign_signalw = 0;
            sign_remw = 1;
            signed_AW = ~AW + 1;
            signed_BW = ~BW + 1;
        end 
        if(A[31] == 0 && B[31] == 0) begin
            sign_signalw = 0;
            sign_remw = 0;
            signed_AW = AW;
            signed_BW = BW;
        end 
        if(A[31] == 1 && B[31] == 0) begin
            sign_signalw = 1;
            sign_remw = 1;
            signed_AW = ~AW + 1;
            signed_BW = BW;
        end 
        if(A[31] == 0 && B[31] == 1) begin
            sign_signalw = 1;
            sign_remw = 0;
            signed_AW = AW;
            signed_BW = ~BW + 1;
        end
    end

endmodule