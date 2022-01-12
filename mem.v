// External memories used by pipeline processor

//data memory
module dmem(input          clk, rst, we,
            input   [31:0] a, wd,
            output  [31:0] rd);

  //64 32-bit registers for RAM

  reg [31:0] data [63:0];   
    assign rd = data[a[31:2]]; //read data is word aligned, drop last two bits

  always @(posedge clk or rst) begin
    if(!rst) begin
      case(we)
        1'b1: data[a[31:2]] <= wd;
        1'b0: data[a[31:2]] <= data[a[31:2]];
      endcase
    end
  end         
endmodule


// Instruction memory (already implemented) in single-cycle lab 154a
module imem(input   [5:0]  a,
            output  [31:0] rd);

  reg [31:0] RAM[63:0];

  initial
    begin
      $readmemh("memfile2.dat",RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
    end

  assign rd = RAM[a]; // word aligned
endmodule