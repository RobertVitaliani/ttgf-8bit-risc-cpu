//ALU 
module ALU(
    input [7:0] A, input [7:0] B, input [2:0] ALU_Op_in, output reg zero, output reg less_than, output reg [7:0] ALU_result 
);
    always @(*) begin
        case (ALU_Op_in)

            //ADD
            4'b000: begin
                ALU_result=A + B;
                zero=0;
                less_than=0; 
            end 
            //SUB
            4'b001: begin
                ALU_result=A - B;
                if(ALU_result==8'b0) zero=1;
                else zero=0;
                if(A < B) less_than=1;
                else less_than=0; 
            end 
            //AND
            4'b010: begin
                ALU_result=A & B;
                zero=0;
                less_than=0; 
            end 
            //OR
            4'b011: begin
                ALU_result=A | B;
                zero=0;
                less_than=0; 
            end
            //XOR
            4'b100: begin
                ALU_result=A ^ B;
                zero=0;
                less_than=0; 
            end 
            //SLL
            4'b101: begin
                ALU_result=A << B;
                zero=0;
                less_than=0; 
            end 
            //SLR
            4'b110: begin
                ALU_result=A >> B;
                zero=0;
                less_than=0; 
            end
            
            default: begin
                ALU_result=8'b0;
                zero=0;
                less_than=0;
            end
        endcase
    end

    
endmodule
