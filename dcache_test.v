`timescale 1ps/1ps

module DCACHE_TEST();
    reg clk = 0;
    reg rst = 0;
    initial begin
        forever begin
            clk <= ~clk;
            #5;
        end
    end
endmodule