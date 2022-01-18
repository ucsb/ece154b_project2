`timescale 1ps/1ps

module mips(input         clk, rst,
            output [31:0] pcF,
            input  [31:0] instrF,
            output        memwriteM,
            output [31:0] aluoutM, writedataM,
            input         readdataM);

    wire        regwriteW, memtoregW, jalW,
    wire        regwriteM, memtoregM, jalM, memwriteM, aluormultM, lohiM,
    wire        regwriteE, memtoregE, jalE, memwriteE, aluormultE, lohiE,
    wire        multstartE, multsignE,
    wire  [3:0] alucontrolE,
    wire  [1:0] alusrcE, regdstE,
    wire        branchD, jumpD, pcsrcD); 
    
    controller c(clk, rst, opD, fnD, equalD, flushE, regwriteW, memtoregW, jalW,
                 regwriteM, memtoregM, jalM, memwriteM, aluormultM, lohiM,
                 regwriteE, memtoregE, jalE, memwriteE, aluormultE, lohiE,
                 multstartE, multsignE,
                 alucontrolE,
                 alusrcE, regdstE,
                 branchD, jumpD, pcsrcD);

    datapath dp();
endmodule