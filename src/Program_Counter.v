//Program Counter
module Program_Counter(input clk, input rst, input PC_enable_sig, input [7:0] PC_in, output [7:0] PC_out);

    reg[7:0] temp;
    always @(posedge rst or posedge clk )
    begin
        if(rst==1'b1)
            temp<= 8'b0;
        else if(PC_enable_sig)
            temp<=PC_in;
    end
    
    assign PC_out=temp;
endmodule
