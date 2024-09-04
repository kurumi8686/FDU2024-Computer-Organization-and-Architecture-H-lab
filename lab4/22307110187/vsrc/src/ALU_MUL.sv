// ALU_MUL module

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module ALU_MUL import common::*;(
    input logic clk, reset,
    input logic [`BitsWidth] a, b,
    input logic [`SEL_DIV_WIDTH-1:0] sig,
    input logic sign_signal,
    input logic stall,
    output logic[`BitsWidth] mul_c,
    output logic stall_this_alu_mul
    );
    
    localparam logic [6:0] CYCLES = 64;
    logic [6:0] count;

    assign stall_this_alu_mul = (sig == `SEL_MUL) && (count != CYCLES);

    always_ff @(posedge clk)
    begin
        if(count == `MUL_INIT) begin
            if(sig == 0 || reset ==`RstEnable) begin
                count <= `MUL_INIT;
            end else begin
                // start 64cycles calculation.
                if(b[count[5:0]] == 1) begin
                	mul_c <= a;
                end else begin
                	mul_c <= 0;
                end
                count <= `MUL_START;
            end
        end else if(count < CYCLES - 1) begin
        	if(b[count[5:0]] == 1) begin
        		mul_c <= (mul_c + (a << count));
        	end
        	count <= count + 1;
        end else if(count == CYCLES - 1) begin
        	if(b[count[5:0]] == 1) begin
        		mul_c <= (mul_c + (a << count));
        	end
        	if(sig == `SEL_MUL) begin
        		if(sign_signal) begin
        			mul_c <= ~mul_c + 1;
        		end else begin
        			mul_c <= mul_c;
        		end
        	end
        	count <= `MUL_END;
        end

        // not stall, means not div_rem or has been calculated over.
        else begin if(~stall || reset == `RstEnable) begin
                count <= `MUL_INIT;
            end
        end
    end

endmodule
