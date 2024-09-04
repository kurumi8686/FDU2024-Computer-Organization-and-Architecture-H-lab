// SIGN module, get sign signal, transfer AB to unsigned number. 

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module ALU_SIGN import common::*;(
    input   logic [`BitsWidth] A, B,
    output  logic sign_signal,
    output  logic sign_rem,
    output  logic [`BitsWidth] signed_A, signed_B
    );

    always_comb
    begin
        if(A[63] == 1 && B[63] == 1) begin
            sign_signal = 0;
            sign_rem = 1;
            signed_A = ~A + 1;
            signed_B = ~B + 1;
        end else if(A[63] == 0 && B[63] == 0) begin
            sign_signal = 0;
            sign_rem = 0;
            signed_A = A;
            signed_B = B;
        end else if(A[63] == 1 && B[63] == 0) begin
            sign_signal = 1;
            sign_rem = 1;
            signed_A = ~A + 1;
            signed_B = B;
        end else begin
            sign_signal = 1;
            sign_rem = 0;
            signed_A = A;
            signed_B = ~B + 1;
        end
    end
endmodule