`timescale 1ps/1ps

module ALU_TEST();
    reg clk = 0;
    reg reset = 0;

    initial begin
        forever begin
            clk <= ~clk;
            #5;
        end
    end
    reg [31:0] A, B;
    reg [2:0]  ctrl;
    wire       zero;
    wire[31:0] out;
    ALU DUT(A, B, ctrl, out, zero);

    initial begin
        $dumpfile("alu_test_dump.vcd");
        $dumpvars;
        //add all 0 and 1 
        A = 32'b0;
        B = 32'b1;
        ctrl = 3'b010;
        #10;
        $finish;
    end
endmodule