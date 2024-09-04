// 对输入的指令产生控制信号

`ifdef VERILATOR
`include "include/common.sv"
`include "include/defines.sv"
`endif

module Control(
    input  logic [`OPCODE_WIDTH] opcode,
    input  logic [`FUNCT3_WIDTH] funct3,
    input  logic [`FUNCT7_WIDTH] funct7,
    output logic [`Sext_OP_WIDTH-1:0]  sext_op,   // Sign extend immediate
    output logic [`NPC_SEL_WIDTH-1:0]  npc_op,    // Next PC control signal
    output logic [`ALU_OP_WIDTH-1:0]   alu_op,    // ALU control signal
    output logic [`ALUA_SEL_WIDTH-1:0] alua_sel,  // Operand A select
    output logic [`ALUB_SEL_WIDTH-1:0] alub_sel,  // Operand B select
    output logic [`SEL_DIV_WIDTH-1:0] div_rem_sig,  // 0: normal  1: div  2: rem
    output logic [`RF_WSEL_WIDTH-1:0]  rf_wsel,   // reg-file write select
    output logic [`DBUS_SEL_WIDTH-1:0] dbus_sel,  // Read/write byte/halfword, not request yet
    output logic rf_we,                           // reg-file write enable
    output logic dbus_wre                         // dbus read/write enable
    );
    
    always_comb begin
        alua_sel = `ALUA_SEL_RD1;
        alub_sel = `ALUB_SEL_RD2;
        sext_op  = `Sext_I;
        dbus_sel = 0;
        alu_op   = 0;
        dbus_wre = 0;
        rf_wsel  = 0;
        rf_we    = 0;
        div_rem_sig = 0;
        npc_op   = `NPC_SEL_NEXT;

        case (opcode)
            `OPCODE_R: begin
                npc_op   = `NPC_SEL_NEXT;
                alua_sel = `ALUA_SEL_RD1;
                alub_sel = `ALUB_SEL_RD2;
                rf_wsel  = `RF_WSEL_ALUC;
                rf_we    = 1;
                dbus_wre = 0;
                case (funct3)
                    `FUNCT3_ADD_SUB:     
                        begin 
                            if(funct7[0]==1'b0) begin alu_op = (funct7[5] == 1'b0) ? `ALU_ADD : `ALU_SUB; end
                            else begin alu_op = `ALU_MUL; div_rem_sig = `SEL_MUL; end
                        end
                    `FUNCT3_AND:         
                        begin
                            if(funct7[0]==1'b0) begin alu_op = `ALU_AND; end
                            else begin alu_op = `ALU_REMU; div_rem_sig = `SEL_REMU; end
                        end
                    `FUNCT3_OR:          
                        begin
                            if(funct7[0]==1'b0) begin alu_op = `ALU_OR; end
                            else begin alu_op = `ALU_REM; div_rem_sig = `SEL_REM; end
                        end
                    `FUNCT3_XOR:         
                        begin
                            if(funct7[0]==1'b0) begin alu_op = `ALU_XOR; end
                            else begin alu_op = `ALU_DIV; div_rem_sig = `SEL_DIV; end
                        end
                    `FUNCT3_SHIFT_RIGHT: 
                        begin
                            if(funct7[0]==1'b0) begin alu_op = (funct7[5] == 1'b0) ? `ALU_SRL : `ALU_SRA; end
                            else begin alu_op = `ALU_DIVU; div_rem_sig = `SEL_DIVU; end
                        end
                    `FUNCT3_SLL:         alu_op = `ALU_SLL;
                    `FUNCT3_SLT:         alu_op = `ALU_SLT;
                    `FUNCT3_SLTU:        alu_op = `ALU_SLTU;

                    default:             alu_op = 0;
                endcase 
            end

            `OPCODE_I_REG: begin
                sext_op  = `Sext_I;
                npc_op   = `NPC_SEL_NEXT;
                alua_sel = `ALUA_SEL_RD1;
                alub_sel = `ALUB_SEL_SEXT;
                rf_wsel  = `RF_WSEL_ALUC;
                rf_we    = 1;
                dbus_wre = 0;
                case (funct3)
                    `FUNCT3_ADDI:        alu_op = `ALU_ADD;
                    `FUNCT3_ANDI:        alu_op = `ALU_AND;
                    `FUNCT3_ORI:         alu_op = `ALU_OR;
                    `FUNCT3_XORI:        alu_op = `ALU_XOR;
                    `FUNCT3_SLLI:        alu_op = `ALU_SLLI;
                    `FUNCT3_SHIFT_RIGHT: alu_op = (funct7[5] == 1'b0) ? `ALU_SRLI : `ALU_SRAI;
                    `FUNCT3_SLTI:        alu_op = `ALU_SLTI;
                    `FUNCT3_SLTIU:       alu_op = `ALU_SLTIU;
                    default:             alu_op = 0;
                endcase
            end

            // LOAD
            `OPCODE_I_LOAD: begin 
                sext_op  = `Sext_I;
                npc_op   = `NPC_SEL_NEXT;
                alua_sel = `ALUA_SEL_RD1;
                alub_sel = `ALUB_SEL_SEXT;
                rf_wsel  = `RF_WSEL_DBUS;
                rf_we    = 1;
                dbus_wre = 1;
                alu_op   = `ALU_ADD;
                case (funct3)
                    `FUNCT3_LB:  dbus_sel = `DBUS_SEL_LB;
                    `FUNCT3_LBU: dbus_sel = `DBUS_SEL_LBU;
                    `FUNCT3_LH:  dbus_sel = `DBUS_SEL_LH;
                    `FUNCT3_LHU: dbus_sel = `DBUS_SEL_LHU;
                    `FUNCT3_LW:  dbus_sel = `DBUS_SEL_LW;
                    `FUNCT3_LD:  dbus_sel = `DBUS_SEL_LD;   // lab2 add this
                    default:     dbus_sel = 0;
                endcase
            end

            // STORE    
            `OPCODE_S: begin 
                sext_op  = `Sext_S;
                npc_op   = `NPC_SEL_NEXT;
                alua_sel = `ALUA_SEL_RD1;
                alub_sel = `ALUB_SEL_SEXT;
                rf_wsel  = 0;
                rf_we    = 0;
                dbus_wre = 1;
                alu_op   = `ALU_ADD;
                case (funct3)
                    `FUNCT3_SB: dbus_sel = `DBUS_SEL_SB;
                    `FUNCT3_SH: dbus_sel = `DBUS_SEL_SH;
                    `FUNCT3_SW: dbus_sel = `DBUS_SEL_SW;
                    `FUNCT3_SD: dbus_sel = `DBUS_SEL_SD;  // lab2 add this
                    default:    dbus_sel = 0;
                endcase
            end

            `OPCODE_B: begin
                sext_op  = `Sext_B;
                alua_sel = `ALUA_SEL_RD1;
                alub_sel = `ALUB_SEL_RD2;
                npc_op   = `NPC_SEL_BRANCH;
                rf_wsel  = 0;
                rf_we    = 0;
                dbus_wre = 0;
                case (funct3)
                    `FUNCT3_BEQ:  alu_op = `ALU_BEQ;
                    `FUNCT3_BNE:  alu_op = `ALU_BNE;
                    `FUNCT3_BLT:  alu_op = `ALU_BLT;
                    `FUNCT3_BLTU: alu_op = `ALU_BLTU;
                    `FUNCT3_BGE:  alu_op = `ALU_BGE;
                    `FUNCT3_BGEU: alu_op = `ALU_BGEU;
                    default:      alu_op = 0;
                endcase
            end

            `OPCODE_LUI: begin
                sext_op = `Sext_U;
                npc_op  = `NPC_SEL_NEXT;
                rf_wsel = `RF_WSEL_SEXT;
                rf_we   = 1;
                dbus_wre= 0;
                alu_op  = 0;
            end

            `OPCODE_AUIPC: begin
                sext_op  = `Sext_U;
                npc_op   = `NPC_SEL_NEXT;
                alua_sel = `ALUA_SEL_PC;
                alub_sel = `ALUB_SEL_SEXT;
                rf_wsel  = `RF_WSEL_ALUC;
                rf_we    = 1;
                dbus_wre = 0;
                alu_op   = `ALU_ADD;
            end

            `OPCODE_JAL: begin
                sext_op = `Sext_J;
                npc_op  = `NPC_SEL_JAL;
                rf_wsel = `RF_WSEL_PC4;
                rf_we   = 1;
                dbus_wre= 0;
                alu_op  = 0;
            end

            `OPCODE_JALR: begin
                sext_op  = `Sext_I;
                npc_op   = `NPC_SEL_ALU;
                alua_sel = `ALUA_SEL_RD1;
                alub_sel = `ALUB_SEL_SEXT;
                rf_wsel  = `RF_WSEL_PC4;
                rf_we    = 1;
                dbus_wre = 0;
                alu_op   = `ALU_ADD;
            end

            `OPCODE_WORD: begin
                npc_op   = `NPC_SEL_NEXT;
                alua_sel = `ALUA_SEL_RD1;
                alub_sel = `ALUB_SEL_RD2;
                rf_wsel  = `RF_WSEL_ALUC;
                rf_we    = 1;
                dbus_wre = 0;
                case (funct3)
                    `FUNCT3_ADDW_SUBW:   alu_op = (funct7[5] == 1'b0) ? `ALU_ADDW : `ALU_SUBW;
                    `FUNCT3_SLLW:        alu_op = `ALU_SLLW;
                    `FUNCT3_SRW:         alu_op = (funct7[5] == 1'b0) ? `ALU_SRLW : `ALU_SRAW;
                    default:             alu_op = 0;
                endcase 
            end

            `OPCODE_IWORD: begin
                npc_op   = `NPC_SEL_NEXT;
                alua_sel = `ALUA_SEL_RD1;
                rf_wsel  = `RF_WSEL_ALUC;
                rf_we    = 1;
                dbus_wre = 0;
                case (funct3)
                    `FUNCT3_ADDIW: 
                        begin
                            alub_sel = `ALUB_SEL_SEXT; sext_op = `Sext_I; alu_op = `ALU_ADDIW;
                        end
                    `FUNCT3_SLLIW: 
                        begin
                        if(funct7[0]==1'b0) begin   // that is shamt[5]==0. valid
                            alub_sel = `ALUB_SEL_SHAMT; alu_op = `ALU_SLLIW;
                        end else begin
                            rf_wsel = 0;
                            rf_we = 0;
                            alu_op = 0; end
                        end
                    `FUNCT3_SRIW:  
                        begin
                        if(funct7[0]==1'b0) begin 
                            alub_sel = `ALUB_SEL_SHAMT; alu_op = (funct7[5] == 1'b0) ? `ALU_SRLIW : `ALU_SRAIW;
                        end else begin
                            rf_wsel = 0;
                            rf_we = 0;
                            alu_op = 0; end
                        end
                    default: alu_op = 0;
                endcase 
            end



            default: begin
            end
        endcase
    end

endmodule
