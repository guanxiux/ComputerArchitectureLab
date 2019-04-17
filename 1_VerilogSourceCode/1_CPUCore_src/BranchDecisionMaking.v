`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB(Embeded System Lab）
// Engineer: Haojun Xia
// Create Date: 2019/03/14 12:03:15
// Design Name: RISCV-Pipline CPU
// Module Name: BranchDecisionMaking
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Decide whether to branch
//////////////////////////////////////////////////////////////////////////////////
`include "Parameters.v"
module BranchDecisionMaking(
    input wire [2:0] BranchTypeE,
    input wire [31:0] Operand1,Operand2,
    output reg BranchE
    );
    wire signed [31:0] Op1_signed;
    wire signed [31:0] Op2_signed;

    initial BranchE = 0;

    assign Op1_signed = Operand1;
    assign Op2_signed = Operand2;
    always@(*)begin
        case(BranchTypeE)
            `BEQ    : BranchE <= (Operand1 == Operand2) ? 1 : 0 ;
            `BNE    : BranchE <= (Operand1 != Operand2) ? 1 : 0;
            `BLT    : BranchE <= (Op1_signed < Op2_signed) ? 1 : 0;
            `BLTU   : BranchE <= (Operand1 < Operand2) ? 1 : 0;
            `BGE    : BranchE <= (Op1_signed > Op2_signed) ? 1 : 0;
            `BGEU   : BranchE <= (Operand1 == Operand2) ? 1 : 0;
            default: BranchE <= 0;
        endcase
    end
endmodule

//功能和接口说明
    //BranchDecisionMaking接受两个操作数，根据BranchTypeE的不同，进行不同的判断，当分支应该taken时，令BranchE=1'b1
    //BranchTypeE的类型定义在Parameters.v中
//推荐格式：
    //case()
    //    `BEQ: ???
    //      .......
    //    default:                            BranchE<=1'b0;  //NOBRANCH
    //endcase
//实验要求
    //实现BranchDecisionMaking模块
