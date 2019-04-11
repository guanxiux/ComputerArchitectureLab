`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB锛圗mbeded System Lab锛?
// Engineer: Haojun Xia & Xuan Wang
// Create Date: 2019/02/08
// Design Name: RISCV-Pipline CPU
// Module Name: WBSegReg
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Write Back Segment Register
//////////////////////////////////////////////////////////////////////////////////
module WBSegReg(
    input wire clk,
    input wire en,
    input wire clear,
    //Data Memory Access
    input wire [31:0] A,
    input wire [31:0] WD,
    input wire [3:0] WE,
    output wire [31:0] RD,
    output reg [1:0] LoadedBytesSelect,
    //Data Memory Debug
    input wire [31:0] A2,
    input wire [31:0] WD2,
    input wire [3:0] WE2,
    output wire [31:0] RD2,
    //input control signals
    input wire [31:0] ResultM,
    output reg [31:0] ResultW,
    input wire [4:0] RdM,
    output reg [4:0] RdW,
    //output constrol signals
    input wire [2:0] RegWriteM,
    output reg [2:0] RegWriteW,
    input wire MemToRegM,
    output reg MemToRegW
    );

    //
    initial begin
        LoadedBytesSelect = 2'b00;
        RegWriteW         =  1'b0;
        MemToRegW         =  1'b0;
        ResultW           =     0;
        RdW               =  5'b0;
    end
    //
    always@(posedge clk)
        if(en) begin
            LoadedBytesSelect <= clear ? 2'b00 : A[1:0];
            RegWriteW         <= clear ?  1'b0 : RegWriteM;
            MemToRegW         <= clear ?  1'b0 : MemToRegM;
            ResultW           <= clear ?     0 : ResultM;
            RdW               <= clear ?  5'b0 : RdM;
        end

    wire [31:0] RD_raw;
    DataRam DataRamInst (
        .clk    ( !clk ),                      //璇疯ˉ鍏?
        .wea    ( WE ),                      //璇疯ˉ鍏?
        .addra  ( A[31:2] ),                      //璇疯ˉ鍏?
        .dina   ( WD ),                      //璇疯ˉ鍏?
        .douta  ( RD_raw         ),
        .web    ( WE2            ),
        .addrb  ( A2[31:2]       ),
        .dinb   ( WD2            ),
        .doutb  ( RD2            )
    );
    // Add clear and stall support
    // if chip not enabled, output output last read result
    // else if chip clear, output 0
    // else output values from bram
    reg stall_ff= 1'b0;
    reg clear_ff= 1'b0;
    reg [31:0] RD_old=32'b0;
    always @ (posedge clk)
    begin
        stall_ff<=~en;
        clear_ff<=clear;
        RD_old<=RD_raw;
    end
    assign RD = stall_ff ? RD_old : (clear_ff ? 32'b0 : RD_raw );

endmodule

//鍔熻兘璇存槑
    //WBSegReg鏄疻rite Back娈靛瘎瀛樺櫒锛?
    //绫讳技浜嶪DSegReg.V涓Bram鐨勮皟鐢ㄥ拰鎷撳睍锛屽畠鍚屾椂鍖呭惈浜嗕竴涓悓姝ヨ鍐欑殑Bram
    //锛堟澶勪綘鍙互璋冪敤鎴戜滑鎻愪緵鐨処nstructionRam锛屽畠灏嗕細鑷姩缁煎悎涓篵lock memory锛屼綘涔熷彲浠ユ浛浠ｆ?х殑璋冪敤xilinx鐨刡ram ip鏍革級銆?
    //鍚屾璇籱emory 鐩稿綋浜? 寮傛璇籱emory 鐨勮緭鍑哄鎺瑙﹀彂鍣紝闇?瑕佹椂閽熶笂鍗囨部鎵嶈兘璇诲彇鏁版嵁銆?
    //姝ゆ椂濡傛灉鍐嶉?氳繃娈靛瘎瀛樺櫒缂撳瓨锛岄偅涔堥渶瑕佷袱涓椂閽熶笂鍗囨部鎵嶈兘灏嗘暟鎹紶閫掑埌Ex娈?
    //鍥犳鍦ㄦ瀵勫瓨鍣ㄦā鍧椾腑璋冪敤璇ュ悓姝emory锛岀洿鎺ュ皢杈撳嚭浼犻?掑埌WB娈电粍鍚堥?昏緫
    //璋冪敤mem妯″潡鍚庤緭鍑轰负RD_raw锛岄?氳繃assign RD = stall_ff ? RD_old : (clear_ff ? 32'b0 : RD_raw );
    //浠庤?屽疄鐜癛D娈靛瘎瀛樺櫒stall鍜宑lear鍔熻兘
//瀹為獙瑕佹眰
    //浣犻渶瑕佽ˉ鍏ㄤ笂鏂逛唬鐮侊紝闇?琛ュ叏鐨勭墖娈垫埅鍙栧涓?
    //DataRam DataRamInst (
    //    .clk    (???),                      //璇疯ˉ鍏?
    //    .wea    (???),                      //璇疯ˉ鍏?
    //    .addra  (???),                      //璇疯ˉ鍏?
    //    .dina   (???),                      //璇疯ˉ鍏?
    //    .douta  ( RD_raw         ),
    //    .web    ( WE2            ),
    //    .addrb  ( A2[31:2]       ),
    //    .dinb   ( WD2            ),
    //    .doutb  ( RD2            )
    //);
//娉ㄦ剰浜嬮」
    //杈撳叆鍒癉ataRam鐨刟ddra鏄瓧鍦板潃锛屼竴涓瓧32bit
    //璇烽厤鍚圖ataExt妯″潡瀹炵幇闈炲瓧瀵归綈瀛楄妭load
    //璇烽?氳繃琛ュ叏浠ｇ爜瀹炵幇闈炲瓧瀵归綈store
