`ifndef CONFIG_SV
`define CONFIG_SV

package config_pkg;
	// parameters
	localparam AREG_READ_PORTS = 1;
	localparam AREG_WRITE_PORTS = 1;
	localparam USE_CACHE = 1'b0;
	localparam USE_ICACHE = USE_CACHE;
	localparam USE_DCACHE = USE_CACHE;
	localparam ADD_LATENCY = 1'b1;
	localparam AXI_BURST_NUM = 16;
	localparam ICACHE_BITS = 3;
	localparam DCACHE_BITS = 3;
endpackage

`endif
