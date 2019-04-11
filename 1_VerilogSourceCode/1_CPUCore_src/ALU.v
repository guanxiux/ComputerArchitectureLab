`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB (Embeded System Lab)
// Engineer: Haojun Xia
// Create Date: 2019/02/08
// Design Name: RISCV-Pipline CPU
// Module Name: ALU
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: ALU unit of RISCV CPU
//////////////////////////////////////////////////////////////////////////////////
`include "Parameters.v"   
module ALU(
    input wire [31:0] Operand1,
    input wire [31:0] Operand2,
    input wire [3:0] AluContrl,
    output reg [31:0] AluOut
    );
    /*SLLI、SRLI、SRAI、ADD 、SUB 、SLL 、SLT 、 SLTU、XOR、SRL 、SRA、OR 、AND、ADDI、SLTI 、SLTIU、XORI 、ORI、ANDI 、LUI、 AUIPC 21
   */
    wire signed [31:0]OP1_signed;
    wire signed [31:0]OP2_signed;
    assign OP1_signed = Operand1;
    assign OP2_signed = Operand2;
    always@(*)begin
        case(AluContrl)
            SLL: AluOut <= Operand1 << Operand2;        //SLLI, SLL
            SRL: AluOut <= Operand1 >> Operand2;        //SRLI, SRL
            SRA: begin
                    AluOut[31] <= Operand1[31];
                    AluOut[30 : 30 - Operand2 + 1] <= 0;
                    AluOut[30 - Operand2 : 0] <= Operand1[30:0] >> Operand2;
                end                                     //SRAI, SRA
            ADD: AluOut <= Operand1 + Operand2;         //ADD, ADDI
            SUB: AluOut <= Operand1 - Operand2;         //SUB, SUBI
            SLT: begin 
                if (OP1_signed < OP2_signed)
                    AluOut <= 1;
                else AluOut <= 0;
            end                                         //SLT, SLTI
            SLTU: begin
                if (Operand1 < Operand2)
                    AluOut <= 1;
                else AluOut <= 0;
            end                                         //SLTU
            XOR: AluOut <= Operand1 ^ Operand2;         //XOR, XORI
            OR: AluOut <= Operand1 | Operand2;          //OR, ORI
            AND: AluOut <= Operand1 & Operand2;         //AND, ANDI
            LUI: AluOut <= {Operand1[19 : 0], 12'b0};   //LUI, AUIPC
        endcase
    end

endmodule

//功能和接口说明
	//ALU接受两个操作数，根据AluContrl的不同，进行不同的计算操作，将计算结果输出到AluOut
	//AluContrl的类型定义在Parameters.v中
//推荐格式：
    //case()
    //    `ADD:        AluOut<=Operand1 + Operand2; 
    //   	.......
    //    default:    AluOut <= 32'hxxxxxxxx;                          
    //endcase
//实验要求  
    //实现ALU模块