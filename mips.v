`timescale 1ps/1ps

module mips(input         clk, rst,
            input  [31:0] instrF, readdataM,
            output [31:0] pcF,
            output        memwriteM,
            output [31:0] alumultoutM, writedataM);

    wire [5:0] opD, fnD;
    wire equalD, flushE, regwriteW, memtoregW, jalW,
         regwriteM, memtoregM, jalM, lohiM,
         regwriteE, memtoregE, jalE, multstartE, multsignE,
         branchD, jumpD, pcsrcD;
    wire [1:0] alusrcE, regdstE;
    wire [3:0] alucontrolE;
    
    controller c(clk, rst, opD, fnD, equalD, flushE,
                  regwriteW, memtoregW, jalW,
                  regwriteM, memtoregM, jalM, memwriteM, aluormultM, lohiM,
                  regwriteE, memtoregE, jalE, 
                  aluormultE, jalD, 
                  multstartE, multsignE,
                  alucontrolE, alusrcE, regdstE,
                  branchD, jumpD, pcsrcD);


    datapath dp(clk, rst, instrF,
                regwriteW, memtoregW, jalW,
                regwriteM, memtoregM, jalM, memwriteM, aluormultM, lohiM,
                regwriteE, memtoregE, jalE, multstartE, multsignE, aluormultE,
                alucontrolE, alusrcE, regdstE,
                branchD, jumpD, pcsrcD, jalD,
                readdataM, alumultoutM, writedataM,
                pcF, flushE, equalD,
                opD, fnD);
endmodule