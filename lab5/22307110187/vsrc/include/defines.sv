// 我的框架下完整rv64-CPU的所有宏

// Regfile的地址线宽度
`define RegAddrBus 4:0
// Regfile的数据线宽度
`define RegBus 63:0
// 寄存器个数
`define RegNum 32
// 位宽度
`define HalfWidth 31:0
`define BitsWidth 63:0
`define MUL_DIV_Width 127:0
// 指令宽度（都是32）
`define InstrWidth 31:0
// shamt width: instr[25:20]
`define ShamtWidth 5:0

`define minus_one 64'hffffffff_ffffffff
// reset使能
`define RstEnable 1
`define RstDisable 0

// 不同类型的指令的立即数符号扩展方式
`define Sext_OP_WIDTH 3
`define Sext_I 0
`define Sext_S 1
`define Sext_B 2
`define Sext_U 3
`define Sext_J 4

// for next_pc module
`define NPC_SEL_WIDTH 2
`define NPC_SEL_NEXT 0
`define NPC_SEL_BRANCH 1
`define NPC_SEL_ALU 2
`define NPC_SEL_JAL 3

// for div module
`define SEL_DIV_WIDTH 5
`define SEL_NORMAL 0
`define SEL_DIV 1
`define SEL_REM 2
`define SEL_DIVU 3
`define SEL_REMU 4
`define SEL_MUL 5
`define SEL_DIVW 6
`define SEL_REMW 7
`define SEL_DIVUW 8
`define SEL_REMUW 9
`define SEL_MULW 10

`define DIV_INIT 0
`define DIV_START 1
`define DIV_END 64
`define MUL_INIT 0
`define MUL_START 1
`define MUL_END 64
`define DIV_ENDW 32
`define MUL_ENDW 32

// for alu module
`define ALU_OP_WIDTH 7
`define ALUA_SEL_WIDTH 2
`define ALUA_SEL_RD1 0
`define ALUA_SEL_PC 1
`define ALUB_SEL_WIDTH 3
`define ALUB_SEL_RD2 0
`define ALUB_SEL_SEXT 1
`define ALUB_SEL_SHAMT 2

`define ALU_ADD 0
`define ALU_SUB 1
`define ALU_AND 2
`define ALU_OR 3
`define ALU_XOR 4

`define ALU_SLL 5
`define ALU_SRL 6
`define ALU_SRA 7
`define ALU_SLT 8
`define ALU_SLTU 9

`define ALU_BEQ 10
`define ALU_BNE 11
`define ALU_BLT 12
`define ALU_BLTU 13
`define ALU_BGE 14
`define ALU_BGEU 15

`define ALU_SLLI 16
`define ALU_SRLI 17
`define ALU_SRAI 18
`define ALU_SLTI 19
`define ALU_SLTIU 20

`define ALU_ADDW 21
`define ALU_SUBW 22
`define ALU_SLLW 23
`define ALU_SRLW 24
`define ALU_SRAW 25
`define ALU_ADDIW 26
`define ALU_SLLIW 27
`define ALU_SRLIW 28
`define ALU_SRAIW 29

`define ALU_MUL  30
`define ALU_DIV  31
`define ALU_DIVU 32
`define ALU_REM  33
`define ALU_REMU 34
`define ALU_MULW  35
`define ALU_DIVW  36
`define ALU_DIVUW 37
`define ALU_REMW  38
`define ALU_REMUW 39


// for reg-file write
`define RF_WSEL_WIDTH 2
`define RF_WSEL_ALUC 0
`define RF_WSEL_DBUS 1
`define RF_WSEL_PC4 2
`define RF_WSEL_SEXT 3

// for Data_Bus
`define STATUS_WIDTH 1:0
`define STATUS_INIT 0
`define STATUS_WAIT 1
`define STATUS_DONE 2

`define DBUS_SEL_WIDTH 4
`define DBUS_SEL_LW 0
`define DBUS_SEL_LH 1
`define DBUS_SEL_LB 2
`define DBUS_SEL_LBU 3
`define DBUS_SEL_LHU 4
`define DBUS_SEL_SW 5
`define DBUS_SEL_SB 6
`define DBUS_SEL_SH 7
`define DBUS_SEL_LD 8
`define DBUS_SEL_SD 9
`define DBUS_SEL_LWU 10

// for all the needed ops
`define OPCODE_WIDTH 	6:0
`define FUNCT3_WIDTH 	2:0
`define FUNCT7_WIDTH 	6:0

`define OPCODE_R             7'b0110011
`define OPCODE_ADD           7'b0110011
`define OPCODE_SUB           7'b0110011
`define OPCODE_AND           7'b0110011
`define OPCODE_OR            7'b0110011
`define OPCODE_XOR           7'b0110011
`define OPCODE_SLL           7'b0110011
`define OPCODE_SRL           7'b0110011
`define OPCODE_SRA           7'b0110011
`define OPCODE_SLT           7'b0110011
`define OPCODE_SLTU          7'b0110011

`define OPCODE_MUL			 7'b0110011
`define OPCODE_DIV			 7'b0110011
`define OPCODE_DIVU          7'b0110011
`define OPCODE_REM           7'b0110011
`define OPCODE_REMU		     7'b0110011

`define OPCODE_I_REG         7'b0010011
`define OPCODE_ADDI          7'b0010011
`define OPCODE_ANDI          7'b0010011
`define OPCODE_ORI           7'b0010011
`define OPCODE_XORI          7'b0010011
`define OPCODE_SLLI          7'b0010011
`define OPCODE_SRLI          7'b0010011
`define OPCODE_SRAI          7'b0010011
`define OPCODE_SLTI          7'b0010011
`define OPCODE_SLTIU         7'b0010011

`define OPCODE_IWORD		 7'b0011011
`define OPCODE_ADDIW         7'b0011011
`define OPCODE_SLLIW         7'b0011011
`define OPCODE_SRLIW         7'b0011011
`define OPCODE_SRAIW         7'b0011011

`define OPCODE_WORD			 7'b0111011
`define OPCODE_ADDW          7'b0111011
`define OPCODE_SUBW          7'b0111011
`define OPCODE_SLLW          7'b0111011
`define OPCODE_SRLW          7'b0111011
`define OPCODE_SRAW          7'b0111011

`define OPCODE_MULW			 7'b0111011
`define OPCODE_DIVW			 7'b0111011
`define OPCODE_DIVUW	     7'b0111011
`define OPCODE_REMW			 7'b0111011
`define OPCODE_REMUW	     7'b0111011

`define OPCODE_I_LOAD        7'b0000011
`define OPCODE_LB            7'b0000011
`define OPCODE_LBU           7'b0000011
`define OPCODE_LH            7'b0000011
`define OPCODE_LHU           7'b0000011
`define OPCODE_LW            7'b0000011
`define OPCODE_LWU           7'b0000011
`define OPCODE_LD            7'b0000011

`define OPCODE_S             7'b0100011
`define OPCODE_SB            7'b0100011
`define OPCODE_SH            7'b0100011
`define OPCODE_SW            7'b0100011
`define OPCODE_SD		     7'b0100011

`define OPCODE_B             7'b1100011
`define OPCODE_BEQ           7'b1100011
`define OPCODE_BNE           7'b1100011
`define OPCODE_BLT           7'b1100011
`define OPCODE_BLTU          7'b1100011
`define OPCODE_BGE           7'b1100011
`define OPCODE_BGEU          7'b1100011

`define OPCODE_LUI           7'b0110111
`define OPCODE_AUIPC         7'b0010111
`define OPCODE_JAL           7'b1101111
`define OPCODE_JALR          7'b1100111

`define FUNCT3_ADD_SUB        3'b000
`define FUNCT3_AND 	          3'b111
`define FUNCT3_OR 	          3'b110
`define FUNCT3_XOR            3'b100
`define FUNCT3_SLL      	  3'b001
`define FUNCT3_SHIFT_RIGHT    3'b101
`define FUNCT3_SLT 	          3'b010
`define FUNCT3_SLTU	          3'b011
`define FUNCT3_ADDI	          3'b000
`define FUNCT3_ANDI	          3'b111
`define FUNCT3_ORI 	          3'b110
`define FUNCT3_XORI	          3'b100
`define FUNCT3_SLLI	          3'b001
`define FUNCT3_SLTI	          3'b010
`define FUNCT3_SLTIU	      3'b011
`define FUNCT3_LB 	          3'b000
`define FUNCT3_LBU  	      3'b100
`define FUNCT3_LH	          3'b001
`define FUNCT3_LHU  	      3'b101
`define FUNCT3_LW	          3'b010
`define FUNCT3_LWU            3'b110
`define FUNCT3_LD	          3'b011
`define FUNCT3_JALR	          3'b000
`define FUNCT3_SB	          3'b000
`define FUNCT3_SH	          3'b001
`define FUNCT3_SW	          3'b010
`define FUNCT3_SD	          3'b011
`define FUNCT3_BEQ	          3'b000
`define FUNCT3_BNE	          3'b001
`define FUNCT3_BLT	          3'b100
`define FUNCT3_BLTU	          3'b110
`define FUNCT3_BGE	          3'b101
`define FUNCT3_BGEU	          3'b111

`define FUNCT3_MUL			  3'b000
`define FUNCT3_DIV			  3'b100
`define FUNCT3_DIVU			  3'b101
`define FUNCT3_REM			  3'b110
`define FUNCT3_REMU			  3'b111

`define FUNCT3_MULW			  3'b000
`define FUNCT3_DIVW			  3'b100
`define FUNCT3_DIVUW		  3'b101
`define FUNCT3_REMW			  3'b110
`define FUNCT3_REMUW		  3'b111

`define FUNCT3_ADDW_SUBW   	  3'b000
`define FUNCT3_SLLW 	      3'b001
`define FUNCT3_SRW            3'b101
`define FUNCT3_ADDIW       	  3'b000
`define FUNCT3_SLLIW 	      3'b001
`define FUNCT3_SRAIW          3'b101
`define FUNCT3_SRLIW          3'b101
`define FUNCT3_ADDIW  		  3'b000
`define FUNCT3_SLLIW   		  3'b001
`define FUNCT3_SRIW 		  3'b101

`define FUNCT7_ADD  	      7'b0000000
`define FUNCT7_SUB 	          7'b0100000
`define FUNCT7_AND            7'b0000000
`define FUNCT7_OR 	          7'b0000000
`define FUNCT7_XOR            7'b0000000
`define FUNCT7_SLL 	          7'b0000000
`define FUNCT7_SRL       	  7'b0000000
`define FUNCT7_SRA 	          7'b0100000
`define FUNCT7_SLT 	          7'b0000000
`define FUNCT7_SLTU	          7'b0000000
`define FUNCT7_SLLI      	  7'b0000000
`define FUNCT7_SRLI	          7'b0000000
`define FUNCT7_SRAI     	  7'b0100000

`define FUNCT7_ADDW 	      7'b0000000
`define FUNCT7_SUBW  	      7'b0100000
`define FUNCT7_SLLW  	      7'b0000000
`define FUNCT7_SRAW  	      7'b0100000
`define FUNCT7_SRLW  	      7'b0000000

// special, actually just has 6 bits.
`define FUNCT7_SRAIW 		  7'b0100000
`define FUNCT7_SRLIW 		  7'b0000000

`define FUNCT7_MUL 			  7'b0000001
`define FUNCT7_DIV 			  7'b0000001
`define FUNCT7_DIVU 		  7'b0000001
`define FUNCT7_REM 			  7'b0000001
`define FUNCT7_REMU 		  7'b0000001

`define FUNCT7_MULW			  7'b0000001
`define FUNCT7_DIVW 		  7'b0000001
`define FUNCT7_DIVUW 		  7'b0000001
`define FUNCT7_REMW 		  7'b0000001
`define FUNCT7_REMUW 		  7'b0000001