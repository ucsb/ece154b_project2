//serialmult testbench

`timescale 1ps/1ps

module serialmult_tb();
    reg clk = 0;
    initial begin 
        forever begin
            clk <= ~clk;
          	#1;
        end
    end
    reg rst, mst, msgn;
  	reg [31:0] a, b;
    wire [63:0] prod;
    wire prodv;
    multserial mult(clk, rst, mst, msgn, a, b, prod, prodv);

    initial begin
      $dumpfile("multserial_dump.vcd");
        $dumpvars;
        a = 32'b0111111111111111111111111111111;
        b = 32'b1000000000000000000000000000000;
        mst = 1'b1;
        msgn = 1'b1;
        #1;
        mst = 1'b0;
        #70;

        a = 32'b0111111111111111111111111111111;
        b = 32'b0111111111111111111111111111111;
        mst = 1'b1;
        msgn = 1'b1;
        #1;
        mst = 1'b0;
        #70;

        a = 32'b0000000000000000000000000000001;
        b = 32'b0100000000000000000000000000000;
        mst = 1'b1;
        msgn = 1'b0;
        #1;
        mst = 1'b0;
        #70;

        a = 32'b0000000000000000000000000000001;
        b = 32'b0100000000000000000000000000000;
        mst = 1'b1;
        msgn = 1'b1;
        #1;
        mst = 1'b0;
        #70;

    end
endmodule
