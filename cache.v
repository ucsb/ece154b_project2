/* 2-way 32KB set associative cache using LRU replacment policy
logical blocks needed for this design: equality comparator, and/or gate, multiplexer
32-bit addr breakdown: Tag: 19 bits, Index/Set: 11 bits, Byte Offset: 2 bits
size = (u(1) + v(2) + tag(38) + data(64)) * 2^11 = 2^11(105) = 219,136 Bit Area, given 262,144 bits
this is also given block size of 32 bits, after implementing base level we can expand to whichever block size is most optimal
maybe 2-level cache if we have time to optimize on unused space?*/

module cache(input wire [31:0] in,
            input wire CLK,
            output wire [31:0] out);

reg [31:0] addr;
reg [31:0] outputData;
reg [2047:0] mem [104:0]; //declaration of 2-d array 2048x105? not sure how to declare in verilog
assign addr = in;
always(@ posedge CLK) begin
    //check if cache has mem specified by set (addr[12:2]), to do this we check valid bits
    if([addr[12:2]]mem[103] || addr[12:2]mem[51]) begin //again idk if this is correct syntax
        //now we need to check if the tags of each entry match addr[31:13]
        if([addr[12:2]]mem[103] && addr[31:13] == [addr[12:2]]mem[102:84]) begin
            outputData == [addr[12:2]]mem[83:52];
        end else if([addr[12:2]]mem[51] && addr[31:13] == [addr[12:2]]mem[50:32]) begin
            outputData == [addr[12:2]]mem[31:0];
        end //both tags don't match, time to select which block to replace
    end else begin //block isn't in cache, need to fetch and writeback
        //need to fetch from mem first
        if([addr[12:2]mem[104]) begin //block 1 is LRU
            //place fetched block into block/way 1
        end else begin //either block 0 is LRU or contains no information 
            //place fetched block into block/way 0
        end
    end
endmodule


