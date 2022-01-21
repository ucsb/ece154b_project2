`timescale 1ps/1ps

module datapath(input        clk, rst,
                input  [31:0]instrF,
                input        regwriteW, memtoregW, jalW,
                input        regwriteM, memtoregM, jalM, memwriteM, aluormultM, lohiM,
                input        regwriteE, memtoregE, jalE, 
                input        multstartE, multsignE,
                input  [3:0] alucontrolE,
                input  [1:0] alusrcE, regdstE,
                input        branchD, jumpD, pcsrcD,
                input  [31:0]readdataM,
                output [31:0]alumultoutM, writedataM, pcF,
                output       flushE, equalD,
                output [5:0] opD, fnD);

    wire forwardAD, forwardBD;
    wire stallF, stallD, flushD, prodVE;
    wire [1:0] forwardAE, forwardBE;
    wire [4:0] rsD, rtD, rdD, rsE, rtE, rdE, writeregE, writeregM, writeregW;
    wire [31:0] wd3;
    
    wire [31:0] pcnextF, pcplus4F, pcplus4D, pcplus4E, pcplus4M, pcplus4W, 
                pctempD, pcbranchD, instrD,
                signimmD, signimmE, signimmshD, 
                luiD, luiE, srcAD, srcAE, srcBD, srcBE, writedataE,
                rfread1E, rfread2E, eq1, eq2,
                aluoutE, aluoutM, alumultoutW,
                readdataW, resultW, prodM1;
    wire [63:0] prodE, prodM;


    //FETCH
    mux2 #(32) pcbrmux(pcplus4F, pcbranchD, pcsrcD, pctempD);
    mux2 #(32) pcjmux(pctempD, {pcplus4D[31:28], instrD[25:0], 2'b00}, jumpD, pcnextF);
    eflopr #(32) pcreg(clk, rst, ~stallF, pcnextF, pcF);
    adder pcplus4_1(pcF, 32'h4, pcplus4F);

    //DECODE
    assign opD = instrD[31:26];
    assign fnD = instrD[5:0];
    assign rsD = instrD[25:21];
    assign rtD = instrD[20:16];
    assign rdD = instrD[15:11];
    assign flushD = (jumpD | pcsrcD);
    
    ecflopr #(32) RD1(clk, rst, ~stallD, flushD, instrF, instrD);
    ecflopr #(32) RD2(clk, rst, ~stallD, flushD, pcplus4F, pcplus4D);

    mux2 #(32) jalmux(resultW, pcplus4W, jalW, wd3); //need to fix pcplus4D
    signext se(instrD[15:0], signimmD);
    sl2 signimmsh(signimmD, signimmshD);
    sl16 lui(instrD[15:0], luiD);
    adder pcplus4_2(signimmshD, pcplus4D, pcbranchD);
    mux2 #(32) FADmux(srcAD, alumultoutM, forwardAD, eq1);
    mux2 #(32) FBDmux(srcBD, alumultoutM, forwardBD, eq2);
    equal eq(eq1, eq2, equalD);

    regfile rf(clk, rst, regwriteW, rsD, rtD, writeregW, wd3, srcAD, srcBD);
    
    //EXECUTE

    cflopr #(32) RE1(clk, rst, flushE, srcAD, rfread1E);
    cflopr #(32) RE2(clk, rst, flushE, srcBD, rfread2E);
    cflopr #(5)  RE3(clk, rst, flushE, rsD, rsE);
    cflopr #(5)  RE4(clk, rst, flushE, rtD, rtE);
    cflopr #(5)  RE5(clk, rst, flushE, rdD, rdE);
    cflopr #(32) RE6(clk, rst, flushE, signimmD, signimmE);
    cflopr #(32) RE7(clk, rst, flushE, luiD, luiE);
    cflopr #(32) RE8(clk, rst, flushE, pcplus4D, pcplus4E);

    mux3 #(5)  regdstmux(rtE, rdE, 5'd31, regdstE, writeregE);
    mux3 #(32) forwardAEmux(rfread1E, resultW, alumultoutM, forwardAE, srcAE);
    mux3 #(32) forwardBEmux(rfread2E, resultW, alumultoutM, forwardBE, writedataE);
    mux3 #(32) alusrcmux(writedataE, signimmE, luiE, alusrcE, srcBE);

    ALU alu(srcAE, srcBE, alucontrolE, aluoutE, zeroE);
    multserial mult(clk, rst, multstartE, multsignE, srcAE, srcBE, prodE, prodVE/*what is it used for?*/);
    
    //MEMORY
    flopr #(64) RM1(clk, rst, prodE, prodM);
    flopr #(32) RM2(clk, rst, aluoutE, aluoutM);
    flopr #(32) RM3(clk, rst, writedataE, writedataM);
    flopr #(5) RM4(clk, rst, writeregE, writeregM);
    flopr #(32) RM5(clk, rst, pcplus4E, pcplus4M);

    mux2 #(32) multmux(prodM[63:32], prodM[31:0], lohiM, prodM1);
    mux2 #(32) alumultmux(aluoutM, prodM1, aluormultM, alumultoutM);

    //WRITEBACK

    flopr #(32) RW1(clk, rst, readdataM, readdataW);
    flopr #(32) RW2(clk, rst, alumultoutM, alumultoutW);
    flopr #(5)  RW3(clk, rst, writeregM, writeregW);
    flopr #(32)  RW4(clk, rst, pcplus4M, pcplus4W);


    mux2 #(32) memtoregmux(alumultoutW, readdataW, memtoregW, resultW);

    //hazard unit

    hazard h(regwriteW, regwriteM, memtoregM,
             writeregW, writeregM, writeregE,
             regwriteE, memtoregE, branchD,
             rsE, rtE, rsD, rtD,
             forwardAE, forwardBE,
             forwardAD, forwardBD, stallD, stallF, flushE);
endmodule