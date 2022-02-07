// External memories used by pipeline processor
`timescale 1ps/1ps
//data memory
module dmem(input             CLK, RST, WriteEnable, ReadEnable, 
            input      [31:0] Address, WriteData,
            output     [31:0] ReadData,
            output            done);

  //128 32-bit registers for RAM

  reg [31:0] data [127:0];
  reg [31:0] addr_reg, writedata_reg, readdata_reg;
  reg [4:0] counter;
  reg       wenable_reg, rst_reg, done_reg;

  assign ReadData = readdata_reg; 
  assign done = done_reg;

  always @(counter) begin
    case(counter)
      5'b10100: begin    //20
                  if(!rst_reg) begin
                    case(wenable_reg)
                      1'b1: data[addr_reg[31:2]] <= writedata_reg;
                      1'b0: data[addr_reg[31:2]] <= data[addr_reg[31:2]]; 
                    endcase
                    case(renable_reg)
                      1'b1: readdata_reg <= data[addr_reg[31:2]]; //read data is word aligned, drop last two bits
                    endcase
                  end
                  done_reg <= 1'b1;
                end
    endcase
  end

  always @(posedge CLK) begin
    if(!RST) begin
      if(WriteEnable | ReadEnable) begin
        counter <= counter + 5'b00001;
        addr_reg <= Address;
        writedata_reg <= WriteData;
        wenable_reg <= WriteEnable;
        rst_reg <= RST;
      end else begin
        counter <= 5'b00000;
      end
    end else begin
      counter <= 5'b0;
      done_reg <= 1'b0;
    end
  end         
endmodule


// Instruction memory (already implemented) in single-cycle lab 154a
// need to delay by 20
module imem(input   [5:0]  Address,
            output  [31:0] ReadData,
            output         done);

  reg [31:0] RAM[63:0];

  assign ReadData = RAM[Address]; // word aligned
endmodule