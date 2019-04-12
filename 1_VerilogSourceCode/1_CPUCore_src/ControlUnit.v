`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB (Embeded System Lab)
// Engineer: Haojun Xia
// Create Date: 2019/02/08
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
`include "Parameters.v"
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,
    output wire JalD,
    output wire JalrD,
    output reg [2:0] RegWriteD,
    output wire MemToRegD,
    output reg [3:0] MemWriteD,
    output wire LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    output reg [1:0] AluSrc2D,
    output wire AluSrc1D,
    output reg [2:0] ImmType
    );
    /*SLLI、SRLI、SRAI、ADD 、SUB 、SLL 、SLT ? SLTU、XOR、SRL 、SRA、OR 、AND、ADDI、SLTI 、SLTIU、XORI 、ORI、ANDI 、LUI? AUIPC 21*/
    wire [16:0] Instr;

    initial begin
        RegWriteD = 0;
        MemWriteD = 0;
        RegReadD = 0;
        BranchTypeD = 0;
        AluContrlD = 0;
        AluSrc2D = 0;
        ImmType = 0;
    end

    assign Instr = {Fn7[6:0], Fn3[2:0], Op[6:0]};
    parameter I_S_type     =    7'b0010011;
    parameter R_type       =    7'b0110011;
    parameter LUI_instr    =    17'bxxxxxxx_xxx_0110111;
    parameter AUIPC_instr  =    17'bxxxxxxx_xxx_0010111;
    parameter ADDI_instr   =    17'bxxxxxxx_000_0010011;
    parameter SLTI_instr   =    17'bxxxxxxx_010_0010011;
    parameter SLTIU_instr  =    17'bxxxxxxx_011_0010011;
    parameter XORI_instr   =    17'bxxxxxxx_100_0010011;
    parameter ORI_instr    =    17'bxxxxxxx_110_0010011;
    parameter ANDI_instr   =    17'bxxxxxxx_111_0010011;
    parameter SLLI_instr   =    17'b0000000_001_0010011;
    parameter SRLI_instr   =    17'b0000000_101_0010011;
    parameter SRAI_instr   =    17'b0100000_101_0010011;
    parameter ADD_instr    =    17'b0000000_000_0110011;
    parameter SUB_instr    =    17'b0100000_000_0110011;
    parameter SLL_instr    =    17'b0000000_001_0110011;
    parameter SLT_instr    =    17'b0000000_010_0110011;
    parameter SLTU_instr   =    17'b0000000_011_0110011;
    parameter XOR_instr    =    17'b0000000_100_0110011;
    parameter SRL_instr    =    17'b0000000_101_0110011;
    parameter SRA_instr    =    17'b0100000_101_0110011;
    parameter OR_instr     =    17'b0000000_110_0110011;
    parameter AND_instr    =    17'b0000000_111_0110011;

assign JalD = 0;
assign JalrD = 0;

//[2:0]RegWriteD
// RegWriteD        表示ID阶段的指令对应的 寄存器写入模? ，所有模式定义在Parameters.v?
always @(*) begin
    casex (Op)
        I_S_type  : RegWriteD <= `LW;
        R_type  : RegWriteD <= `LW;
        default : begin
            casex (Instr)
                LUI_instr: RegWriteD <= `LW;
                AUIPC_instr: RegWriteD <= `LW;
                default : RegWriteD <= `NOREGWRITE;
            endcase
        end
    endcase
end

// MemToRegD==1     表示ID阶段的指令需要将data memory读取???写入寄存?,
assign MemToRegD = 0;

//[3:0]MemWriteD
// MemWriteD        ?4bit，采用独热码格式，对于data memory?32bit字按byte
//进行写入,MemWriteD=0001表示只写入最?1个byte，和xilinx bram的接口类?
always @(*) begin
    casex (Instr)
        default : MemWriteD <= 4'b0;
    endcase
end

// LoadNpcD==1      表示将NextPC输出到ResultM
assign LoadNpcD = 0;

//[1:0]RegReadD
// RegReadD[1]==1   表示A1[19:15]对应的寄存器值被使用到了，RegReadD[0]==1表示A2[24:20]对应的寄存器值被使用到了，用于forward的处?
always @(*) begin
    casex (Op)
        I_S_type    : RegReadD <= 2'b10;
        R_type      : RegReadD <= 2'b11;
        default : RegReadD <= 2'b0;
    endcase
end

//[2:0]BranchTypeD
// BranchTypeD      表示不同的分支类型，?有类型定义在Parameters.v?
always @(*) begin
    casex (Instr)
        default : BranchTypeD <= `NOBRANCH;
    endcase
end

// AluSrc2D         表示Alu输入?2????
// AluSrc1D         表示Alu输入?1????
always @(*) begin
    casex (Op)
        I_S_type    : AluSrc2D <= 2'b10;
        R_type      : AluSrc2D <= 2'b00;
        default : begin
            casex (Instr)
                LUI_instr: AluSrc2D <= 2'b10;
                AUIPC_instr: AluSrc2D <= 2'b10;
                default : AluSrc2D <= 2'bxx;
            endcase
        end
    endcase
end

assign AluSrc1D = (Instr == AUIPC_instr) ? 1 : 0;
//[3:0]AluContrlD
// AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v?
always @(*) begin
    casex (Instr)
        LUI_instr   :   AluContrlD <= `LUI;
        AUIPC_instr :   AluContrlD <= `LUI;
        SLLI_instr  :   AluContrlD <= `SLL;
        SRLI_instr  :   AluContrlD <= `SRL;
        SRAI_instr  :   AluContrlD <= `SRA;
        ADDI_instr  :   AluContrlD <= `ADD;
        XORI_instr  :   AluContrlD <= `XOR;
        ORI_instr   :   AluContrlD <= `OR;
        ANDI_instr  :   AluContrlD <= `AND;
        SLTI_instr  :   AluContrlD <= `SLT;
        SLTIU_instr :   AluContrlD <= `SLTU;

        SLL_instr   :   AluContrlD <= `SLL;
        SRL_instr   :   AluContrlD <= `SRL;
        SRA_instr   :   AluContrlD <= `SRA;
        ADD_instr   :   AluContrlD <= `ADD;
        SUB_instr   :   AluContrlD <= `SUB;
        XOR_instr   :   AluContrlD <= `XOR;
        OR_instr    :   AluContrlD <= `OR;
        AND_instr   :   AluContrlD <= `AND;
        SLT_instr   :   AluContrlD <= `SLT;
        SLTU_instr  :   AluContrlD <= `SLTU;
        default : AluContrlD <= 4'b0;
    endcase
end

//[2:0]ImmType
// ImmType          表示指令的立即数格式，所有类型定义在Parameters.v?
always @(*) begin
    casex (Instr)
        ADDI_instr  :   ImmType <= `ITYPE;
        SLTI_instr  :   ImmType <= `ITYPE;
        SLTIU_instr :   ImmType <= `ITYPE;
        XORI_instr  :   ImmType <= `ITYPE;
        ORI_instr   :   ImmType <= `ITYPE;
        ANDI_instr  :   ImmType <= `ITYPE;
        SLLI_instr  :   ImmType <= `STYPE;
        SRLI_instr  :   ImmType <= `STYPE;
        SRAI_instr  :   ImmType <= `STYPE;
        LUI_instr   :   ImmType <= `UTYPE;
        AUIPC_instr :   ImmType <= `UTYPE;
        default : ImmType <= `RTYPE;
    endcase
end


endmodule

//功能说明
    //ControlUnit       是本CPU的指令译码器，组???辑电?
//输入
    // Op               是指令的操作码部?
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的 寄存器写入模? ，所有模式定义在Parameters.v?
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取???写入寄存?,
    // MemWriteD        ?4bit，采用独热码格式，对于data memory?32bit字按byte进行写入,MemWriteD=0001表示只写入最?1个byte，和xilinx bram的接口类?
    // LoadNpcD==1      表示将NextPC输出到ResultM
    // RegReadD[1]==1   表示A1对应的寄存器值被使用到了，RegReadD[0]==1表示A2对应的寄存器值被使用到了，用于forward的处?
    // BranchTypeD      表示不同的分支类型，?有类型定义在Parameters.v?
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v?
    // AluSrc2D         表示Alu输入?2????
    // AluSrc1D         表示Alu输入?1????
    // ImmType          表示指令的立即数格式，所有类型定义在Parameters.v?
//实验要求
    //实现ControlUnit模块
