`timescale 1ps/1ps

module CONTROL_TEST();
    reg clk = 0;
    initial begin
        forever begin
            clk <= ~clk;
            #5;
        end
    end

    reg [5:0] op, fn;
    wire        multstart, multsgn;
    wire        aluormult, lohi;
    wire        regwrite, memwrite, memtoreg;
    wire  [1:0] alusrc, regdst;
    wire        jump, jal;
    wire        bne, branch; 
    wire  [3:0] alucontrol;

    controller DUT(op, fn, multstart, multsgn, aluormult, lohi, regwrite, memwrite, memtoreg,  alusrc, regdst,
                jump, jal, bne, branch, alucontrol);

    initial begin
        $dumpfile("controller_test_dump.vcd");
        $dumpvars;
        op = 6'b000000;
        fn = 6'b000000;
        #5;
        //beq
        op = 6'b000100;
        fn = 6'b000000;
        #5;
        //lui
        op = 6'b001111;
        fn = 6'b000000;
        #5;
        //xori
        op = 6'b001110;
        fn = 6'b000000;
        #5;
        //xnor
        op = 6'b000000;
        fn = 6'b101000;
        #5;
        //mult
        op = 6'b000000;
        fn = 6'b011000;
        #5;
        //mfhi
        op = 6'b000000;
        fn = 6'b001010;
        #5;
        //bne
        op = 6'b000101;
        fn = 6'b000000;
        #5;
        //jal
        op = 6'b000011;
        fn = 6'b000000;
        #5;
        op = 6'b000000;
        fn = 6'b001010;
        #5;
        $finish;
    end
endmodule