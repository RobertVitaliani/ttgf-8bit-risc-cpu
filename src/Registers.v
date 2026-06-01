`timescale 1ns / 1ps

//register file
module Registers (
    input clk, input rst, input RegWrite,input [2:0] rs1, input [2:0] rs2, input [2:0] rd, input [7:0] write_data, output [7:0] reg_data_1, output [7:0] reg_data_2);
    
    reg[7:0] register_file[7:0];
    

    always @(posedge rst or posedge clk)
    begin
        if(rst) begin
            /*
            for(k=0;k<31;k=k+1) begin
                Registers[k]<=32'b0;
            end*/
            register_file[0]<=1;
            register_file[1]<=4;
            register_file[2]<=2;
            register_file[3]<=24;
            register_file[4]<=0;
            register_file[5]<=4;
            register_file[6]<=2;
            register_file[7]<=24;
            
        end

        else if(RegWrite) begin
            register_file[rd]<= write_data;
        end
    end

    assign reg_data_1=register_file[rs1];
    assign reg_data_2=register_file[rs2];
    //forwarding ako se u t2 koristi rezultat iz t1
    //assign readData1 = (readReg1 == writeReg && regWrite) ? writeData : registers[readReg1];
endmodule
