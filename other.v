module controller(input   [5:0] op, fn,
                  output        MultStart, MultSgn,
                  output        RegWrite, MemWrite,
                  output        Branch, ALUSrc,
                  output        RegDst, Jump,
                  output  [2:0] WBSrc, ALUControl);

// **PUT YOUR CODE HERE**

    //defining internal signals aluop and branch (gets AND'd with zero from alu)
    wire [1:0] aluop;
    wire       branch;
    wire       bne;

    //declare main decoder and alu decoder modules
    maindec md(op, memtoreg, memwrite, branch, alusrc, 
                regdst, regwrite, jump, bne, aluop);
    aludec ad(funct, aluop, alucontrol);

endmodule

module maindec(input  [5:0] op,
               output       MultStart, MultSgn,
               output       RegWrite, MemWrite,
               output       Branch, ALUSrc,
               output       RegDst, Jump,
               output [2:0] WBSrc);
///////////////MODIFIED CODE IN HERE///////////////
    reg [9:0] controls;
    //controls concatenates all the output signals so this assign reassigns them
    assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, bne, aluop} = controls;
    //add, addi, sub, and, or, xor, xnor, andi, ori, xori, slt, slti, lw, sw, lui, jal, bne, beq, mult, multu, mflo, mfhi
    //implementation of the main decoders truth table
    always @(op) begin
        case(op)
            6'b000000: controls <= 10'b1100000010; //R type instructions
            6'b100011: controls <= 10'b1010010000; //lw
            6'b101011: controls <= 10'b0010100000; //sw
            6'b000100: controls <= 10'b0001000001; //beq
            6'b001000: controls <= 10'b1010000000; //addi
            6'b000010: controls <= 10'b0000001000; //j
            6'b001101: controls <= 10'b1010000011; //ORI
            6'b000101: controls <= 10'b0001000101; //BNE
            default:   controls <= 10'bxxxxxxxxxx; //illegal instruction
        endcase
    end
endmodule

module aludec(input     [5:0]   funct,
              input     [1:0]   aluop,
              output    [2:0]   alucontrol);

    reg [2:0] internal_ctrl;
    //when either input 
    always @(funct or aluop) begin
        //look at aluop first
        case(aluop)
            2'b00: internal_ctrl <= 3'b010; //add for lw, sw, or addi
            2'b01: internal_ctrl <= 3'b110; //sub for beq
            2'b10: case(funct)
                        6'b100000: internal_ctrl <= 3'b010; //add
                        6'b100010: internal_ctrl <= 3'b110; //sub
                        6'b100100: internal_ctrl <= 3'b000; //and
                        6'b100101: internal_ctrl <= 3'b001; //or
                        6'b101010: internal_ctrl <= 3'b111; //slt
                        default:   internal_ctrl <= 3'bxxx; //illegal
                    endcase
            //default: internal_ctrl <= 3'bxxx; //n/a when aluop is 2'b11
///////////////MODIFIED CODE IN HERE///////////////
            2'b11: internal_ctrl <= 3'b001; //CHANGED THIS LINE TO ALLOW FOR ORI
        endcase
    end

    assign alucontrol = internal_ctrl;
endmodule

module regfile(input  wire         CLK,
               input  wire         RST,
               input  wire         WE3,
               input  wire  [4:0]  A1, A2, A3,
               input  wire  [31:0] WD3,
               output wire  [31:0] RD1,RD2);

    //31 32-bit registers in register file, $0 doesn't count
    reg [31:0] rf [31:1];
    integer i;
    //assigns data in registers A1,A2 to output RD1, RD2
    assign RD1 = (A1 != 0) ? rf[A1] : 32'b0;
    assign RD2 = (A2 != 0) ? rf[A2] : 32'b0;

    always @(posedge CLK or posedge RST)begin
        if(RST) begin
            for(i = 1; i < 32; i = i + 1)begin
                rf[i] = 32'b0;
            end
        end else begin
            if(WE3) rf[A3] <= WD3;
        end
    end
endmodule

module adder(input  wire [31:0] a,b,
             output wire [31:0] y);
    assign y = a+b; //self-explanatory
endmodule

module sl2(input  wire [31:0] a,
           output wire [31:0] y);
    assign y = {a[29:0], 2'b00};  //y is a shifted by 2 to the left, effectively multiply by 4
endmodule

module immgen(input  wire [31:0] inst, pc,
              output wire [31:0] imm);
    assign imm = {{16{inst[15]}}, inst[15:0]}; //extends 16th bit of a all the way to 32 bits
endmodule

module flopr #(parameter WIDTH=8)
              (input  wire             clk, reset,
               input  wire [WIDTH-1:0] d,
               output reg [WIDTH-1:0] q);
    
    always @(posedge clk or posedge reset) begin //asynchronous reset flip-flop
        // case(reset)
        //     1'b1: ff <= 0;
        //     1'b0: ff <= d;
        // endcase
        if(reset) q <= 0;
        else      q <= d;
    end
endmodule

module mux2 #(parameter WIDTH=8)
             (input  wire [WIDTH-1:0] d0,d1,
              input  wire             s,
              output wire [WIDTH-1:0] y);
    
    assign y = s ? d1 : d0;  //if s == 1 then assign d1 to y, else y = d0
endmodule

