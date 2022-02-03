/* 2-way 32KB set associative cache using LRU replacment policy
logical blocks needed for this design: equality comparator, and/or gate, multiplexer
32-bit addr breakdown: Tag: 19 bits, Index/Set: 11 bits, Byte Offset: 2 bits
size = (u(1) + v(2) + tag(38) + data(64)) * 2^11 = 2^11(107) = 219,136 Bit Area, given 262,144 bits
maybe 2-level cache if we have time ?*/

module cache(input wire [31:0] in,
            input wire CLK,
            output wire [31:0] out);

reg [31:0] addr;
reg [31:0] outputData;
always(@ posedge CLK) begin

    end
endmodule


