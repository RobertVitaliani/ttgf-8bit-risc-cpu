//Instantiation and connect
module CPU_Core (
    input clk, input rst, input[15:0] instruction, output [7:0] CPU_out
);


  localparam EXECUTE_AND_RESULT = 1'b0;
  localparam SWITCH_TO_NEXTPC = 1'b1;
  

  
  reg state;
  
  
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      state<=SWITCH_TO_NEXTPC;
      
    end
    else begin
        case (state)
          EXECUTE_AND_RESULT: begin

            state<=SWITCH_TO_NEXTPC;
          end 

          SWITCH_TO_NEXTPC: begin
    
            state<=EXECUTE_AND_RESULT;
          end
         
        endcase
    end

  end
  

    //wire [7:0] CPU_out_wire;
    wire [15:0] current_instruction= (state==EXECUTE_AND_RESULT)? instruction : 16'b1111000000000000;

    wire control_Mux_out_sig, PC_enable_sig, Branch_control_top;
    wire RegWrite_wire, ALUSrc_wire, MemWrite_wire, MemRead_wire, MemToReg_wire, Is_beq_wire, Is_bne_wire, Is_blt_wire, zero_wire, less_than_wire;

    wire [7:0] PC_top_wire, CPU_result_wire, PCplus4_Top, SUM_top, PC_input_wire, Imm_Gen_out_wire;
    wire [7:0] Reg_data1_wire, Reg_data2_wire, ALU_Mux_top, ALU_Top, MemData_out_wire;
    
    wire [2:0] ALUOp_wire;

    //Instantiation


    Program_Counter PC(.clk(clk), 
                       .rst(rst), 
                       .PC_enable_sig(PC_enable_sig), 
                       .PC_in(PC_input_wire), 
                       .PC_out(PC_top_wire)
                       );


    PCplus4Adder PC_adder(.FromPC(PC_top_wire), 
                          .NextPC(PCplus4_Top)
                          );


    Adder Jump_adder( .in_1(PC_top_wire), 
                      .in_2(Imm_Gen_out_wire), 
                      .Add_out(SUM_top)
                      );



    
    Registers Registers(.clk(clk), 
                        .rst(rst),
                        .RegWrite(RegWrite_wire), 
                        .rs1(current_instruction[8:6]), 
                        .rs2(current_instruction[5:3]), 
                        .rd(current_instruction[11:9]), 
                        .write_data(CPU_result_wire), 
                        .reg_data_1(Reg_data1_wire),  
                        .reg_data_2(Reg_data2_wire)
                        );

    

    Control_Unit control_unit(.Instruction(current_instruction[15:12]), 
                              .funct3(current_instruction[2:0]),
                              .Control_Mux_out_sig(control_Mux_out_sig),
                              .PC_enable_sig(PC_enable_sig),
                              .RegWrite(RegWrite_wire),
                              .ALUSrc(ALUSrc_wire),
                              .MemRead(MemRead_wire),
                              .MemWrite(MemWrite_wire),
                              .MemToReg(MemToReg_wire),
                              .is_BEQ(Is_beq_wire),
                              .is_BLT(Is_blt_wire),
                              .is_BNE(Is_bne_wire),
                              .ALUOp(ALUOp_wire)
                              );


    Imm_Gen imm_gen(.Instruction(current_instruction), 
                    .Imm_Out(Imm_Gen_out_wire)
                    );

    ALU ALU( .A(Reg_data1_wire), 
             .B(ALU_Mux_top), 
             .ALU_Op_in(ALUOp_wire), 
             .zero(zero_wire),
             .less_than(less_than_wire), 
             .ALU_result(ALU_Top)
             ); 

    Branch_Control branch_control(.is_beq(Is_beq_wire),
                                  .is_bne(Is_bne_wire),
                                  .is_blt(Is_blt_wire),
                                  .zero(zero_wire),
                                  .less_than(less_than_wire),
                                  .branch_control_top(Branch_control_top)
                                  );


    Data_Memory data_memory(.clk(clk), 
                            .rst(rst), 
                            .Adress(ALU_Top), 
                            .PC_enable_sig(PC_enable_sig),
                            .MemWrite(MemWrite_wire), 
                            .MemRead(MemRead_wire), 
                            .WriteData(Reg_data2_wire), 
                            .MemData_Out(MemData_out_wire));

    /*ALU_Control alu_control(.ALUOp(ALUOp_wire),
                            .fun3(current_instruction[2:0]), 
                            .Control_out(ALU_Control_top));
    
    AND_logic and_logic( .branch(Branch_wire), 
                         .zero(zero_wire), 
                         .AND_out(AND_Top));
    */
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


    Mux1 Output_mux(.sel1(control_Mux_out_sig), 
                    .A1(PC_top_wire), 
                    .B1(CPU_result_wire), 
                    .mux1_out(CPU_out)
                    );


    Mux1 Adder_Mux( .sel1(Branch_control_top), 
                    .A1(PCplus4_Top), 
                    .B1(SUM_top), 
                    .mux1_out(PC_input_wire));


    Mux1 Data_memory_mux(.sel1(MemToReg_wire), 
                        .A1(ALU_Top), 
                        .B1(MemData_out_wire), 
                        .mux1_out(CPU_result_wire));

    Mux1 ALU_mux( .sel1(ALUSrc_wire), 
                  .A1(Reg_data2_wire), 
                  .B1(Imm_Gen_out_wire), 
                  .mux1_out(ALU_Mux_top));

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
    

    
endmodule
