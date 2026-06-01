`timescale 1ns / 1ps

//Data memory
module Data_Memory (
    input clk, input rst, input [7:0] Adress, input PC_enable_sig, input MemWrite, input MemRead, input [7:0] WriteData, output [7:0] MemData_Out
);
    integer i;
    wire [3:0] address_index = Adress[3:0];
    
    reg[7:0] memory[15:0];
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for (i=0; i<16; i=i+1 ) begin
                memory[i]<=8'b0;
            end
        end
        else if(MemWrite && PC_enable_sig) begin
            memory[address_index]<=WriteData;
        end
    end 
    assign MemData_Out= (MemRead)? memory[address_index]: 8'b0;

    wire _unused = &{Adress[7:4], 1'b0};
endmodule
