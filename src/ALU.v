//ALU 
module ALU (
    input signed      [7:0] A,
    input signed      [7:0] B,
    input             [2:0] ALU_Op_in,
    output reg              zero,
    output reg              less_than,
    output reg signed [7:0] ALU_result
);
    always @(*) begin
        ALU_result = 8'b0;
        less_than = 0;

        case (ALU_Op_in)
            //ADD
            3'b000: begin
                ALU_result = A + B;
            end 

            //SUB
            3'b001: begin
                ALU_result = A - B;
                if(A < B) less_than = 1;
                else less_than = 0;
            end 

            //AND
            3'b010: begin
                ALU_result = A & B;
            end 

            //OR
            3'b011: begin
                ALU_result = A | B;
            end

            //XOR
            3'b100: begin
                ALU_result = A ^ B;
            end 

            //SLL
            3'b101: begin
                ALU_result = A << B[2:0];
            end 

            //SRL
            3'b110: begin
                ALU_result = A >> B[2:0];
            end

            default: ALU_result = 8'b0;
        endcase

        zero = (ALU_result == 8'b0);
    end
endmodule
