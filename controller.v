`timescale 1ps/1ps

module controller(input         clk, rst,
                  input   [5:0] opD, fnD,
                  input         equalD, flushE,
                  output        regwriteW, memtoregW, jalW,
                  output        regwriteM, memtoregM, jalM, memwriteM, aluormultM, lohiM,
                  output        regwriteE, memtoregE, jalE, 
                  output        aluormultE, jalD, 
                  output        multstartE, multsignE,
                  output  [3:0] alucontrolE,
                  output  [1:0] alusrcE, regdstE,
                  output        branchD, jumpD, pcsrcD);


    //defining internal control signal
    //decode signals
    wire       regwriteD, memwriteD, memtoregD, multstartD, multsignD, aluormultD, lohiD;
    wire [1:0] alusrcD, regdstD;
    wire       bneD;
    wire [2:0] aluopD;
    wire [3:0] alucontrolD;
    wire       lohiE, memwriteE;

    //declare main decoder and alu decoder modules
    maindec md(opD, regwriteD, memwriteD, branchD, memtoregD, alusrcD, regdstD, jumpD, jalD, bneD, aluopD);
    aludec ad(fnD, aluopD, alucontrolD, multstartD, multsignD, aluormultD, lohiD);

    assign pcsrcD = branchD & (bneD ^ equalD);

    //registers for control signals
    cflopr #(16) regE(clk, rst, flushE,
                    {multstartD, multsignD, regwriteD, 
                    memtoregD, memwriteD, alucontrolD, 
                    alusrcD, regdstD, jalD, aluormultD, lohiD},
                    {multstartE, multsignE, regwriteE, 
                    memtoregE, memwriteE, alucontrolE, 
                    alusrcE, regdstE, jalE, aluormultE, lohiE});
    flopr #(6) regM(clk, rst,
                   {regwriteE, memtoregE, memwriteE, jalE, aluormultE, lohiE},
                   {regwriteM, memtoregM, memwriteM, jalM, aluormultM, lohiM});
    flopr #(3) regW(clk, rst,
                   {regwriteM, memtoregM, jalM},
                   {regwriteW, memtoregW, jalW});
endmodule

module maindec(input  [5:0] op,
               output       regwrite, memwrite,
               output       branch, memtoreg,
               output [1:0] alusrc, regdst,
               output       jump, jal, bne,
               output [2:0] aluop);

    reg [13:0] controls;
    //controls concatenates all the output signals so this assign reassigns them
    assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, jal, bne, aluop} = controls;
    //addi, andi, ori, xori, slti, lw, sw, lui, jal, bne, beq
    
    //had to change regdst to 2 bits to allow jal to work, need to write to $31
    //implementation of the main decoders truth table
    always @(op) begin
        case(op)
            6'b000000: controls <= 14'b10100000000010; //R type instructions
            6'b100011: controls <= 14'b10001001000000; //lw
            6'b101011: controls <= 14'b00001010000000; //sw
            6'b000100: controls <= 14'b00000100000001; //beq
            6'b001000: controls <= 14'b10001000000000; //addi
            6'b000010: controls <= 14'b00000000100000; //j
            6'b001101: controls <= 14'b10001000000011; //ori
            6'b000101: controls <= 14'b00000100001001; //bne
            6'b000011: controls <= 14'b11000000110000; //jal
            6'b001100: controls <= 14'b10001000000100; //andi
            6'b001110: controls <= 14'b10001000000101; //xori    got xor and xori from https://www.cs.cmu.edu/afs/cs/academic/class/15740-f97/public/doc/mips-isa.pdf
            6'b001010: controls <= 14'b10001000000111; //slti
            6'b001111: controls <= 14'b10010000000000; //lui
            default:   controls <= 14'bxxxxxxxxxxxxxx; //illegal instruction
        endcase
    end
endmodule

module aludec(input     [5:0]   funct,
              input     [2:0]   aluop,
              output    [3:0]   alucontrol,
              output            multstart,
              output            multsign,
              output            aluormult,
              output            lohi);

    reg [3:0] internal_ctrl;
    reg       int_multstart, int_multsign, int_aluormult, int_lohi;
    //when either input 
    //add, sub, and, or, xor, xnor, slt, mult, multu, mflo, mfhi are the R type instructions
    always @(funct or aluop) begin
        //look at aluop first
        case(aluop)
            3'b000: begin internal_ctrl <= 3'b010; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //add for lw, sw, or addi
            3'b001: begin internal_ctrl <= 3'b110; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //sub for beq/bne
            3'b010: case(funct)
                        6'b100000: begin internal_ctrl <= 4'b0010; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //add
                        6'b100010: begin internal_ctrl <= 4'b1010; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //sub
                        6'b100100: begin internal_ctrl <= 4'b0000; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //and
                        6'b100101: begin internal_ctrl <= 4'b0001; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //or
                        6'b100110: begin internal_ctrl <= 4'b0100; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //xor
                        6'b101000: begin internal_ctrl <= 4'b0101; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //xnor defined own funct code
                        6'b101010: begin internal_ctrl <= 4'b1011; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //slt
                        6'b011000: begin internal_ctrl <= 4'b0000; int_multstart <= 1; int_multsign <= 1; int_aluormult <= 0; int_lohi <= 0; end //mult
                        6'b011001: begin internal_ctrl <= 4'b0000; int_multstart <= 1; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //multu
                        6'b010010: begin internal_ctrl <= 4'b0000; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 1; int_lohi <= 0; end//mflo
                        6'b010000: begin internal_ctrl <= 4'b0000; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 1; int_lohi <= 1; end//mfhi
                        default:   internal_ctrl <= 4'bxxxx; //illegal
                    endcase
            3'b011: begin internal_ctrl <= 4'b0001; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //ORI
            3'b100: begin internal_ctrl <= 4'b0000; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //ANDI
            3'b101: begin internal_ctrl <= 4'b0100; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //XORI
            3'b111: begin internal_ctrl <= 4'b1011; int_multstart <= 0; int_multsign <= 0; int_aluormult <= 0; int_lohi <= 0; end //SLTI
        endcase
    end

    assign alucontrol = internal_ctrl;
    assign multstart = int_multstart;
    assign multsign = int_multsign; 
    assign aluormult = int_aluormult; 
    assign lohi = int_lohi;
endmodule