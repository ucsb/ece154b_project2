`timescale 1ps/1ps

module MIPS_TEST();
    reg clk = 0;
    reg rst = 0;
    initial begin
        forever begin
            clk <= ~clk;
            #5;
        end
    end

    wire [31:0] writedata, dataadr, readdata, instr;
    wire        memwrite;

    top DUT(clk, rst, writedata, readdata, dataadr, memwrite, instr);

    initial begin
        $dumpfile("top_test_dump.vcd");
        $dumpvars;
        rst = 1;
        #20;
        rst = 0;
        #50;
        $finish;
    end
endmodule