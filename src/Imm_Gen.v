//Immediate_Generator
module Imm_Gen (input [15:0] Instruction, output reg [7:0] Imm_Out);
    
    wire[3:0] opcode=Instruction[15:12];
    always @(*) begin
        case (opcode)
            // LI-format load imm
            4'b0010: Imm_Out= Instruction[7:0];
            // I-format
            4'b0001, 4'b0011, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100: Imm_Out= { {2{Instruction[5]}}, Instruction[5:0] };
            // S/B-format 
            4'b0100, 4'b0101, 4'b0110, 4'b0111: Imm_Out= { {2{Instruction[5]}}, Instruction[5:0] };
            default: Imm_Out=8'b0;
        endcase
    end


endmodule
