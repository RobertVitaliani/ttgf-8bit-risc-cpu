//Control module
module Control_Unit (
    input [3:0] Instruction, input [2:0] funct3, output reg PC_enable_sig, output reg Control_Mux_out_sig, output reg is_BEQ ,output reg is_BNE, output reg is_BLT ,output reg MemRead, output reg MemToReg, output reg [2:0] ALUOp, output reg MemWrite, output reg ALUSrc, output reg RegWrite
);
    localparam OP_R_TYPE = 4'b0000;
    localparam OP_ADDI = 4'b0001;
    localparam OP_LI = 4'b0010;
    localparam OP_LW = 4'b0011;

    localparam OP_SW = 4'b0100;
    localparam OP_BEQ = 4'b0101;
    localparam OP_BNE = 4'b0110;
    localparam OP_BLT = 4'b0111;

    localparam OP_ANDI = 4'b1000;
    localparam OP_ORI = 4'b1001;
    localparam OP_XORI = 4'b1010;
    localparam OP_SLLI = 4'b1011;

    localparam OP_SLRI = 4'b1100;
    //localparam OP_BEQ = 4'b1101;
    //localparam OP_BNE = 4'b1110;
    localparam NOP = 4'b1111;
    //ALUOP [00 za L/S], [01 za BRANCH], [10 za r-type - gledaj funct3]
    
    always @(*) begin

        PC_enable_sig=0;
        Control_Mux_out_sig=0;
        ALUSrc=0;
        MemToReg=0;
        RegWrite=0;
        MemRead=0;
        MemWrite=0;
        is_BEQ=0;
        is_BNE=0;
        is_BLT=0;
        ALUOp=3'b000;


        case (Instruction)
            // 0. R_Format
            OP_R_TYPE : begin
                PC_enable_sig=1;
                Control_Mux_out_sig=1;
                ALUSrc=0;
                MemToReg=0;
                RegWrite=1;
                MemRead=0;
                MemWrite=0;
                is_BEQ=0;
                is_BNE=0;
                is_BLT=0;

                //provjera funct3
                case (funct3) 
                    3'b000: ALUOp= 3'b000; //add
                    3'b001: ALUOp= 3'b001; //sub
                    3'b010: ALUOp= 3'b010; //and
                    3'b011: ALUOp= 3'b011; //or
                    3'b100: ALUOp= 3'b100; //xor
                    3'b101: ALUOp= 3'b101; //sll
                    3'b110: ALUOp= 3'b110; //slr

                endcase

            end
            //I_FORMAT 1.ADDI 2.LI 8.ANDI 9.ORI 10.XORI 11.SLLI 12.SLRI
            OP_ADDI, OP_LI, OP_ANDI, OP_ORI, OP_XORI, OP_SLLI, OP_SLRI: begin
                PC_enable_sig=1;
                Control_Mux_out_sig=1;
                ALUSrc=1;
                MemToReg=0;
                RegWrite=1;
                MemRead=0;
                MemWrite=0;
                is_BEQ=0;
                is_BNE=0;
                is_BLT=0;
                if(Instruction==OP_ADDI || Instruction==OP_LI) ALUOp=3'b000;
                if(Instruction==OP_ANDI) ALUOp=3'b010;
                if(Instruction==OP_ORI) ALUOp=3'b011;
                if(Instruction==OP_XORI) ALUOp=3'b100;
                if(Instruction==OP_SLLI) ALUOp=3'b101;
                if(Instruction==OP_SLRI) ALUOp=3'b110;
                
            end 


            //3. I_format lw   
            OP_LW : begin
                PC_enable_sig=1;
                Control_Mux_out_sig=1;
                ALUSrc=1;
                MemToReg=1;
                RegWrite=1;
                MemRead=1;
                MemWrite=0;
                is_BEQ=0;
                is_BNE=0;
                is_BLT=0;
                ALUOp=3'b000; //ADD
            end

            //4. S/B_format sw   
            OP_SW : begin
                PC_enable_sig=1;
                Control_Mux_out_sig=1;
                ALUSrc=1;
                MemToReg=1;
                RegWrite=0;
                MemRead=0;
                MemWrite=1;
                is_BEQ=0;
                is_BNE=0;
                is_BLT=0;
                ALUOp=3'b000; //ADD
            end

            //5. 6. 7. S/B_format BEQ, BNE, BLT   
            OP_BEQ, OP_BNE, OP_BLT : begin
                PC_enable_sig=1;
                Control_Mux_out_sig=1;
                ALUSrc=1;
                MemToReg=1;
                RegWrite=0;
                MemRead=0;
                MemWrite=1;
                
                ALUOp=3'b001; //SUB

                if(Instruction==OP_BEQ) is_BEQ=1;
                if(Instruction==OP_BNE) is_BNE=1;
                if(Instruction==OP_BLT) is_BLT=1;
            end  

            //NOP
            NOP : {PC_enable_sig, Control_Mux_out_sig, is_BEQ, is_BNE, is_BLT, MemToReg, MemRead, MemWrite, ALUSrc, ALUOp, RegWrite} = 13'b00_000_000_0_000_0;

            default: {PC_enable_sig, Control_Mux_out_sig, is_BEQ, is_BNE, is_BLT, MemToReg, MemRead, MemWrite, ALUSrc, ALUOp, RegWrite} = 13'b00_000_000_0_000_0;
        endcase
    end


endmodule
