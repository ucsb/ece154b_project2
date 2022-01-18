`timescale 1ps/1ps

module multserial(input wire CLK,
                  input wire RST,
                  input wire MST,
                  input wire MSGN,
                  input wire [31:0] SRCA,
                  input wire [31:0] SRCB,
                  output wire [63:0] PROD,
                  output wire PRODV);
    reg [2:0] state; //3 will be our default state of no change
    reg msgn; //used to store signed or unsigned, as we need it for the last bit of calculation
  	reg [31:0] A, B;
    reg [63:0] P, T; //product and tempororary registers
    reg [31:0] temp_b; //used to hold B, we will shift right by 1 each multiplication cycle
    reg prodv;
  	assign PRODV = prodv;
  	assign PROD = P;
  	assign A = SRCA;
  	assign B = SRCB;
    always @(posedge CLK) begin
        case (state)
            0: begin //MST was received previous cycle, load registers and go to multiply state (1)
                P <= 0;
                prodv <= 1'b0;
                temp_b <= B;
              	T[31:0] <= A;
                T[63:32] <= 32'b0; //each iteration we shift to the right, so that each row of multiplication is calculated correctly
                state <=1;
            end
            1: begin //calculating product
                if(RST) begin //go to reset state
                    state <= 4;
                end else begin
                    if(temp_b[0] == 1'b1) begin
                        if(temp_b == 1 && msgn) begin //last bit of B is sign bit so must subtract to ensure correct calculation
                            P <= P - T;
                            state <= 2; 
                        end else begin //either unsigned or not last bit so add to product
                            P <= P + T;
                        end
                    end else begin //value of temp_b[0] is 0 so no multiplication for this "level"
                        P <= P;
                    end
                    if(temp_b == 0) begin //finished shifting through B, i.e. our product is finished being calculated
                        state <= 2;
                    end else begin //not done multiplying
                        temp_b <= temp_b>>1; //shift right by 1 to use next b[0] in next multiplicative cycle 
                        T <= T<<1; //shift left by 1 so that when adding to P, we accout for our b[0] shift
                        state <= 1;
                    end
                end
            end
            2: begin //output state
                prodv <= 1'b1;
                if(RST) begin //reset signal
                    state <= 4;
                end else if (MST) begin //next cycle begin multiply (load regs)
                    state <= 1; 
                end else begin //default state
                    state <= 3;
                end
            end
            3: begin //default, do nothing state
                if(RST) begin  //reset state sends us to 4
                    state <= 4;
                end else if(MST) begin //next cycle begin multiply
                    state <= 1;
                end else begin 
                    state <= 3;
                end
            end
            4: begin //reset state
                temp_b <= 0;
                msgn <= 0;
                P <= 0;
                T <= 0;
                prodv <= 0;
                if(MST) begin
                    state <= 0;
                end
                else begin
                    state <= 4;
                end
            end
            default: begin
            end
        endcase
    end
endmodule