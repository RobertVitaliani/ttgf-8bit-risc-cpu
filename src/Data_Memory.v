//Data memory
module Data_Memory (
    input clk, input rst, input [7:0] Adress, input PC_enable_sig, input MemWrite, input MemRead, input [7:0] WriteData, output [7:0] MemData_Out
);
    integer i;
    
    reg[7:0] memory[15:0];
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for (i=0; i<16; i=i+1 ) begin
                memory[i]<=8'b0;
            end
        end
        else if(MemWrite && PC_enable_sig) begin
            memory[Adress[3:0]]<=WriteData;
        end
    end 
    assign MemData_Out= (MemRead)? memory[Adress]: 8'b0;
endmodule
