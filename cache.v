/* 2-way 32KB set associative cache using LRU replacment policy
logical blocks needed for this design: equality comparator, and/or gate, multiplexer
Data Cache Design: 2-way SA, Block Size: 64 bits, 2^10 sets
Data Cache 32-bit addr breakdown: Tag: 19 bits, Index/Set: 10 bits, Block Offset: 1 bit, Byte Offset: 2 bits
Data Cache size = (u(1) + v(2) + tag(38) + data(128)) * 2^10 = 2^10(169) = 173,056 Bit Area, given 262,144 bits
Inst Cache Design: 2-way SA, Block Size: 128 bits, 2^8 sets
Inst Cache 32-bit addr breakdown: Tag: 20 bits, Set: 8 bits, Block offset: 2 bits, Byte Offset: 2 bits
Inst Cache Size = (u(1) + v(2) + tag(40) + inst(256)) * 2^8 = 2^8(299) = 76,544 Bit Area, given 89,088 bits
unused bits: 12,544 / 262,144 = 4.8% unused*/
`timescale 1ps/1ps

module dCache(input wire [31:0] in,
            input wire [63:0] datain,
            input wire dready,
            input wire CLK,
            output wire [31:0] out1,
            output wire [31:0] out2,
            output             valid);

    reg [31:0] addr;
    reg [31:0] outputData1;
    reg [31:0] outputData2;
    reg [63:0] inputData;   
    reg v;
    reg [168:0] mem [1023:0]; //declaration of 2-d array 1024x169? not sure how to declare in verilog
    assign addr = in;
    assign inputData = datain;
    assign valid = v;
    always(@ posedge CLK) begin
        //check if cache has mem specified by set (addr[12:3]), to do this we check valid bits
        if(mem[addr[12:3]][167] || mem[addr[12:3]][83]) begin //again idk if this is correct syntax
            //now we need to check if the tags of each entry match addr[31:13]
            if(mem[addr[12:3]][167] && addr[31:13] == mem[addr[12:3]][166:148]) begin
                outputData1 <= mem[addr[12:3]][147:116];
                outputData2 <= mem[addr[12:3]][115:84];
                mem[addr[12:3]][168] <= 1'b0; //setting U to 0
            end else if(mem[addr[12:3]][83] && addr[31:13] == mem[addr[12:3]][82:64]) begin
                outputData1 <= mem[addr[12:3]][63:32];
                outputData2 <= mem[addr[12:3]][31:0];
                mem[addr[12:3]][168] <= 1'b1; //setting U to 1
            end //both tags don't match, time to select which block to replace
        end else begin //block isn't in cache, need to fetch and writeback
            valid <= 0;
            //need to fetch from mem first
            #20;
            if(mem[addr[12:3]][168]) begin //block 1 is LRU
                //place fetched block into block/way 1, use dready
                if(dready) begin 
                    mem[addr[12:3]][167] <= 1'b1;
                    mem[addr[12:3]][166:148] <= addr[31:13];
                    mem[addr[12:3]][147:84] <= inputData;
                    mem[addr[12:3]][168] <= 1'b0;
            end else begin //either block 0 is LRU or contains no information 
                //place fetched block into block/way 0
                if(dready) begin
                    mem[addr[12:3]][167] <= 1'b1;
                    mem[addr[12:3]][82:64] <= addr[31:13];
                    mem[addr[12:3]][63:0] <= inputData;
                    mem[addr[12:3]][168] <= 1'b1;
            end
        end
    end
endmodule

module iCache(input wire [31:0] in,
            input wire CLK,
            output wire [31:0] out1,
            output wire [31:0] out2,
            output wire [31:0] out3,
            output wire [31:0] out4);
    reg [31:0] addr;
    reg [31:0] outputData1;
    reg [31:0] outputData2;
    reg [31:0] outputData3;
    reg [31:0] outputData4;
    reg [298:0] mem [255:0];
    assign addr = in;
    always(@ posedge CLK) begin
        //check if cache has mem specified by set (addr[11:4]), to do this we check valid bits
        if(mem[addr[11:4]][297] || mem[addr[11:4]][148]) begin //again idk if this is correct syntax
            //now we need to check if the tags of each entry match addr[31:13]
            if(mem[addr[11:4]][297] && addr[31:12] == mem[addr[11:4]][296:277]) begin
                outputData1 <= mem[addr[11:4]][276:245];
                outputData2 <= mem[addr[11:4]][244:213];
                outputData3 <= mem[addr[11:4]][212:181];
                outputData4 <= mem[addr[11:4]][180:149];
                mem[addr[11:4]][298] <= 1'b0; //setting U to 0
            end else if(mem[addr[11:4]][148] && addr[31:12] == mem[addr[11:4]][147:128]) begin
                outputData1 <= mem[addr[11:4]][127:96];
                outputData2 <= mem[addr[11:4]][95:64];
                outputData2 <= mem[addr[11:4]][63:32];
                outputData2 <= mem[addr[11:4]][31:0];
                mem[addr[11:4]][298] <= 1'b1; //setting U to 1
            end //both tags don't match, time to select which block to replace
        end else begin //block isn't in cache, need to fetch and writeback
            //need to fetch from mem first
            if(mem[addr[11:4]][298]) begin //block 1 is LRU
                //place fetched block into block/way 1
            end else begin //either block 0 is LRU or contains no information 
                //place fetched block into block/way 0
            end
        end
    end
endmodule
