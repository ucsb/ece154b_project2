module ALU (input [31:0] InA, InB, input [2:0] ALUControl, output reg [31:0] out, output zero) ;
  wire less, greater, equal;
  wire [31:0] BB;
  wire [31:0] S;
  wire        cout;

  assign BB = (ALUControl[2]) ? ~InB : InB;
  assign {cout, S} = ALUControl[2] + InA + BB;  //two's complement addition

  //set internal flags for equal, less than, greater than, if needed later
  assign equal = (InA == InB) ? 1'b1 : 1'b0;
  assign less = (InA < InB && equal == 0) ? 1'b1 : 1'b0;
  assign greater = (InA > InB && equal == 0) ? 1'b1 : 1'b0;
  
  always @ * begin
    case (ALUControl[1:0]) 
      2'b00 : out <= InA & BB;         //AND
      2'b01 : out <= InA | BB;         //OR
      2'b10 : out <= S;                //ADD
      2'b11 : out <= {31'b0, S[31]};   //SLT
    endcase
  end 
  
  assign zero = (out == 0);
 endmodule

 