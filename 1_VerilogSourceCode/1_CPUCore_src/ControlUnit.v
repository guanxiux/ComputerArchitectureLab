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
    /*SLLI、SRLI、SRAI、ADD 、SUB 、SLL 、SLT 、 SLTU、XOR、SRL 、SRA、OR 、AND、ADDI、SLTI 、SLTIU、XORI 、ORI、ANDI 、LUI、 AUIPC 21*/
    wire [16:0] Instr;

    initial begin
        RegWriteD = 0;
        MemWriteD = 0;
        RegReadD = 0;
        BranchTypeD = 0;
        AluControlD = 0;
        AluSrc2D = 0;
        ImmType = 0;
    end

    assign Instr = {Fn7[6:0], Fn3[2:0], Op[6:0]};
    localparam I_S_type       = 7'b0010011;
    localparam R_type       = 7'b0110011;

    localparam LUI_instr    = 17'bxxxxxxx_xxx_0110111;
    localparam AUIPC_instr  = 17'bxxxxxxx_xxx_0010111;
    localparam ADDI_instr   = 17'bxxxxxxx_000_0010011;
    localparam SLTI_instr   = 17'bxxxxxxx_010_0010011;
    localparam SLTIU_instr  = 17'bxxxxxxx_011_0010011;
    localparam XORI_instr   = 17'bxxxxxxx_100_0010011;
    localparam ORI_instr    = 17'bxxxxxxx_110_0010011;
    localparam ANDI_instr   = 17'bxxxxxxx_111_0010011;
    localparam SLLI_instr   = 17'b0000000_001_0010011;
    localparam SRLI_instr   = 17'b0000000_101_0010011;
    localparam SRAI_instr   = 17'b0100000_101_0010011;
    localparam ADD_instr    = 17'b0000000_000_0110011;
    localparam SUB_instr    = 17'b0100000_000_0110011;
    localparam SLL_instr    = 17'b0000000_001_0110011;
    localparam SLT_instr    = 17'b0000000_010_0110011;
    localparam SLTU_instr   = 17'b0000000_011_0110011;
    localparam XOR_instr    = 17'b0000000_100_0110011;
    localparam SRL_instr    = 17'b0000000_101_0110011;
    localparam SRA_instr    = 17'b0100000_101_0110011;
    localparam OR_instr     = 17'b0000000_110_0110011;
    localparam AND_instr    = 17'b0000000_111_0110011;

assign JalD = 0;
assign JalrD = 0;

//[2:0]RegWriteD
// RegWriteD        表示ID阶段的指令对应的 寄存器写入模式 ，所有模式定义在Parameters.v中
always @(*) begin
    case (Op)
        I_S_type  : RegWriteD <= `LW;
        R_type  : RegWriteD <= `LW;
        default : RegWriteD <= `NOREGWRITE;
    endcase
end

// MemToRegD==1     表示ID阶段的指令需要将data memory读取的值写入寄存器,
assign MemToRegD = 0;

//[3:0]MemWriteD
// MemWriteD        共4bit，采用独热码格式，对于data memory的32bit字按byte
//进行写入,MemWriteD=0001表示只写入最低1个byte，和xilinx bram的接口类似
always @(*) begin
    case (Instr)
        default : MemWriteD <= 4'b0;
    endcase
end

// LoadNpcD==1      表示将NextPC输出到ResultM
assign LoadNpcD = 0;

//[1:0]RegReadD
// RegReadD[1]==1   表示A1[19:15]对应的寄存器值被使用到了，RegReadD[0]==1表示A2[24:20]对应的寄存器值被使用到了，用于forward的处理
always @(*) begin
    case (Op)
        I_S_type    : RegReadD <= 2'b10;
        R_type      : RegReadD <= 2'b11;
        default : RegReadD <= 2'b0;
    endcase
end

//[2:0]BranchTypeD
// BranchTypeD      表示不同的分支类型，所有类型定义在Parameters.v中
always @(*) begin
    case (Instr)
        default : BranchTypeD <= `NOBRANCH;
    endcase
end

// AluSrc2D         表示Alu输入源2的选择
// AluSrc1D         表示Alu输入源1的选择
always @(*) begin
    case (Op)
        I_S_type    : AluSrc2D <= 2'b10;
        R_type      : AluSrc2D <= 2'b00;
        default : AluSrc2D <= 2'b0;
    endcase
    end
end
assign AluSrc1D = (Instr == AUIPC_instr) ? 1 : 0;
//[3:0]AluControlD
// AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v中
always @(*) begin
    case (Instr)
        SLLI_instr  :   AluControlD <= `SLL;
        SRLI_instr  :   AluControlD <= `SRL;
        SRAI_instr  :   AluControlD <= `SRA;
        ADDI_instr  :   AluControlD <= `ADD;
        XORI_instr  :   AluControlD <= `XOR;
        ORI_instr   :   AluControlD <= `OR;
        ANDI_instr  :   AluControlD <= `AND;
        SLTI_instr  :   AluControlD <= `SLT;
        SLTIU_instr :   AluControlD <= `SLTU;

        SLL_instr   :   AluControlD <= `SLL;
        SRL_instr   :   AluControlD <= `SRL;
        SRA_instr   :   AluControlD <= `SRA;
        ADD_instr   :   AluControlD <= `ADD;
        SUB_instr   :   AluControlD <= `SUB;
        XOR_instr   :   AluControlD <= `XOR;
        OR_instr    :   AluControlD <= `OR;
        AND_instr   :   AluControlD <= `AND;
        SLT_instr   :   AluControlD <= `SLT;
        SLTU_instr  :   AluControlD <= `SLTU;
        LUI_instr   :   AluControlD <= `LUI;
        default : AluControlD <= 4'b0;
    endcase
end

//[2:0]ImmType
// ImmType          表示指令的立即数格式，所有类型定义在Parameters.v中
always @(*) begin
    case (Instr)
        ADDI_instr  :   ImmType <= `ITYPE;
        SLTI_instr  :   ImmType <= `ITYPE;
        SLTIU_instr :   ImmType <= `ITYPE;
        XORI_instr  :   ImmType <= `ITYPE;
        ORI_instr   :   ImmType <= `ITYPE;
        ANDI_instr  :   ImmType <= `ITYPE;
        SLLI_instr  :   ImmType <= `STYPE;
        SRLI_instr  :   ImmType <= `STYPE;
        SRAI_instr  :   ImmType <= `STYPE;
        default : ImmType <= `RTYPE;
    endcase
end


endmodule

//功能说明
    //ControlUnit       是本CPU的指令译码器，组合逻辑电路
//输入
    // Op               是指令的操作码部分
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的 寄存器写入模式 ，所有模式定义在Parameters.v中
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的值写入寄存器,
    // MemWriteD        共4bit，采用独热码格式，对于data memory的32bit字按byte进行写入,MemWriteD=0001表示只写入最低1个byte，和xilinx bram的接口类似
    // LoadNpcD==1      表示将NextPC输出到ResultM
    // RegReadD[1]==1   表示A1对应的寄存器值被使用到了，RegReadD[0]==1表示A2对应的寄存器值被使用到了，用于forward的处理
    // BranchTypeD      表示不同的分支类型，所有类型定义在Parameters.v中
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v中
    // AluSrc2D         表示Alu输入源2的选择
    // AluSrc1D         表示Alu输入源1的选择
    // ImmType          表示指令的立即数格式，所有类型定义在Parameters.v中
//实验要求
    //实现ControlUnit模块
