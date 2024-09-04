`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module HAZARD import common::*;(
	input  logic clk,
	input  logic reset,
	input  logic rf1_occupied,
	input  logic rf2_occupied,
	input  logic branch,
	output logic stall_hazard,
	output logic flush1,
	output logic flush2,
	output logic [`BitsWidth] forward_A,
	output logic [`BitsWidth] forward_B,
	output logic forward_A_sig,
	output logic forward_B_sig,
	input  logic [`RF_WSEL_WIDTH-1:0] ex_rf_wsel,
	input  logic [4:0] ex_wR,
	input  logic [4:0] mem_wR,
	input  logic [4:0] wb_wR,
	input  logic [`BitsWidth] ex_wD,
	input  logic [`BitsWidth] mem_wD,
	input  logic [`BitsWidth] wb_wD,
	input  logic [4:0] id_rR1,
	input  logic [4:0] id_rR2,
	input  logic ex_rf_we,
	input  logic mem_rf_we,
	input  logic wb_rf_we
);
	
	logic  RAW_A_rD1, RAW_A_rD2, RAW_B_rD1, RAW_B_rD2, RAW_C_rD1, RAW_C_rD2;

	assign RAW_A_rD1 = (ex_wR == id_rR1) && ex_rf_we && rf1_occupied && (ex_wR != 0);
	assign RAW_A_rD2 = (ex_wR == id_rR2) && ex_rf_we && rf2_occupied && (ex_wR != 0);

	assign RAW_B_rD1 = (mem_wR == id_rR1) && mem_rf_we && rf1_occupied && (mem_wR != 0);
	assign RAW_B_rD2 = (mem_wR == id_rR2) && mem_rf_we && rf2_occupied && (mem_wR != 0);

	assign RAW_C_rD1 = (wb_wR == id_rR1) && wb_rf_we  && rf1_occupied && (wb_wR != 0);
	assign RAW_C_rD2 = (wb_wR == id_rR2) && wb_rf_we  && rf2_occupied && (wb_wR != 0);

	assign forward_A_sig = RAW_A_rD1 || RAW_B_rD1 || RAW_C_rD1;
	assign forward_B_sig = RAW_A_rD2 || RAW_B_rD2 || RAW_C_rD2;

	always_comb begin
	    if(RAW_A_rD1) begin
	    	forward_A = ex_wD;
	    end else if(RAW_B_rD1) begin
	    	forward_A = mem_wD;
	    end else if(RAW_C_rD1) begin
	    	forward_A = wb_wD;
	    end else begin
	    	forward_A = 64'b0;
	    end
	end

	always_comb begin
	    if(RAW_A_rD2) begin 
	    	forward_B = ex_wD;
	    end else if(RAW_B_rD2) begin
	    	forward_B = mem_wD;
	    end else if(RAW_C_rD2) begin
	    	forward_B = wb_wD;
	    end else begin
	    	forward_B = 64'b0;
	    end
	end


	logic load_use = (RAW_A_rD1 || RAW_A_rD2) && (ex_rf_wsel == `RF_WSEL_DBUS);

	always_comb begin
		if(load_use) stall_hazard = 1'b1;
		else        stall_hazard = 1'b0;
	end

	always_comb begin
	    if(branch) flush1 = 1'b1;
	    else       flush1 = 1'b0;
	end

	always_comb begin
	    if(load_use || branch) flush2 = 1'b1;
	    else                   flush2 = 1'b0;
	end

endmodule
