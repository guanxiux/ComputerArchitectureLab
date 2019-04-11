`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: qihao
// Create Date: 03/09/2019 09:03:05 PM
// Design Name:
// Module Name: DataExt
// Target Devices:
// Tool Versions:
// Description:
//////////////////////////////////////////////////////////////////////////////////

`include "Parameters.v"
module DataExt(
    input wire [31:0] IN,
    input wire [1:0] LoadedBytesSelect,
    input wire [2:0] RegWriteW,
    output reg [31:0] OUT
    );

    initial begin
        OUT = 0;
    end

    wire [7:0]LoadedByte1;
    wire [15:0]LoadedByte2;
    assign LoadedByte1 = (LoadedBytesSelect == 2'b0) ?  IN[7:0] :
                        (LoadedBytesSelect == 2'b01) ?  IN[15:8]:
                        (LoadedBytesSelect == 2'b10) ?  IN[23:16]:
                                                        IN[31:24];

    assign LoadedByte2 = (LoadedBytesSelect <= 2'b01) ?  IN[15:0] : IN[31:16];

    always@(*)begin
        case (RegWriteW)
            `LB  : OUT <= { {24{LoadedByte1[7]}}, LoadedByte1[7:0] };
            `LH  : OUT <= { {16{LoadedByte2[15]}}, LoadedByte2[15:0] };
            `LW  : OUT <= IN[31:0];
            `LBU : OUT <= { 24'b0, LoadedByte1[7:0] };
            `LHU : OUT <= { 16'b0, LoadedByte2[15:0] };
            default : OUT <= 32'hxxxx_xxxx;
        endcase
    end
endmodule

//功能说明
    //DataExt是用来处理非字对齐load的情形，同时根据load的不同模式对Data Mem中load的数进行符号或�?�无符号拓展，组合�?�辑电路
//输入
    //IN                    是从Data Memory中load�?32bit�?
    //LoadedBytesSelect     等价于AluOutM[1:0]，是读Data Memory地址的低两位�?
                            //因为DataMemory是按字（32bit）进行访问的，所以需要把字节地址转化为字地址传给DataMem
                            //DataMem�?次返回一个字，低两位地址用来�?32bit字中挑�?�出我们�?要的字节
    //RegWriteW             表示不同�? 寄存器写入模�? ，所有模式定义在Parameters.v�?
//输出
    //OUT表示要写入寄存器的最终�??
//实验要求
    //实现DataExt模块
