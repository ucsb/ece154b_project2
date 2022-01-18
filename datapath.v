`timescale 1ps/1ps

module datapath(input clk, rst,
                input        regwriteW, memtoregW, jalW,
                input        regwriteM, memtoregM, jalM, memwriteM, aluormultM, lohiM,
                input        regwriteE, memtoregE, jalE, memwriteE, aluormultE, lohiE,
                input        multstartE, multsignE,
                input  [3:0] alucontrolE,
                input  [1:0] alusrcE, regdstE,
                input        branchD, jumpD, pcsrcD,
                output       pcF, equalD, 
                output [5:0] opD, fnD,
                output       flushE,
                output );

    wire forwardAD, forwardBD;
    wire [1:0] forwardAE, forwardBE;

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

    mux2 #(1) jalmux(resultW, pcplus4D, jalW, wd3);
    signext se(instrD[15:0], signimmD);
    sl2 signimmsh(signimmD, signimmshD);
    sl16 lui(instr[15:0], luiD);
    adder pcplus4_2(signimmshD, pcplus4D, pcbranchD);
    mux2 #(32) FADmux(srcaD, alumultoutM, forwardAD, eq1);
    mux2 #(32) FBDmux(srcbD, alumultoutM, forwardBD, eq2);
    eqcmp eq(eq1, eq2, equalD);

    regfile rf(clk, rst, regwriteW, rsD, rtD, writeregW, wd3);
    
    //EXECUTE

    cflopr #(32) RE1(clk, rst, flushE, rfread1, rfread1E);
    cflopr #(32) RE2(clk, rst, flushE, rfread2, rfread2E);
    cflopr #(5)  RE3(clk, rst, flushE, rsD, rsE);
    cflopr #(5)  RE4(clk, rst, flushE, rtD, rtE);
    cflopr #(5)  RE5(clk, rst, flushE, rdD, rdE);
    cflopr #(32) RE6(clk, rst, flushE, signimmD, signimmE);
    cflopr #(32) RE7(clk, rst, flushE, luiD, luiE);

    mux3 #(5)  regdstmux(rtE, rdE, 5'd31, regdstE, writeregE);
    mux3 #(32) forwardAEmux(rfread1E, resultW, alumultoutM, forwardAE, srcAE);
    mux3 #(32) forwardBEmux(rfread2E, resultW, alumultoutM, forwardBE, srcBEtemp);
    mux3 #(32) alusrcmux(srcBEtemp, signimmE, luiE, alusrcE, srcBE);

    ALU alu(srcAE, srcBE, alucontrolE, aluoutE, zeroE);
    multserial mult(clk, rst, multstartE, multsignE, srcAE, srcBE, prodE, prodVE/*what is it used for?*/);
    
    //MEMORY
    flopr #(64) RM1(clk, rst, prodE, prodM);
    flopr #(32) RM2(clk, rst, aluoutE, aluoutM);
    flopr #(32) RM3(clk, rst, writedataE, writedataM);
    flopr #(32) RM4(clk, rst, writeregE, writeregM);

    mux2 #(32) multmux(prodE[63:32], prodE[31:0], lohiM, prodM);
    mux2 #(32) alumultmux(aluoutM, prodM, aluormultM, alumultoutM);

    //WRITEBACK

    flopr #(32) RW1(clk, rst, readdataM, readdataW);
    flopr #(32) RW2(clk, rst, alumultoutM, alumultoutW);
    flopr #(5)  RW3(clk, rst, writeregM, writeregW);

    mux2 #(32) memtoregmux(alumultoutW, readdataW, memtoregW, resultW);

    //hazard unit

    hazard h()
endmodule