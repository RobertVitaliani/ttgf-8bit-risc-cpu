//Data memory
module Data_Memory (
    input        clk,
    input        rst,
    input  [7:0] Adress,
    input        PC_enable_sig,
    input        MemWrite,
    input        MemRead,
    input  [7:0] WriteData,
    output [7:0] MemData_Out
);
    wire [3:0] address_index = Adress[3:0];
    reg [7:0] read_data;
    
    reg [7:0] memory_0;
    reg [7:0] memory_1;
    reg [7:0] memory_2;
    reg [7:0] memory_3;
    reg [7:0] memory_4;
    reg [7:0] memory_5;
    reg [7:0] memory_6;
    reg [7:0] memory_7;
    reg [7:0] memory_8;
    reg [7:0] memory_9;
    reg [7:0] memory_10;
    reg [7:0] memory_11;
    reg [7:0] memory_12;
    reg [7:0] memory_13;
    reg [7:0] memory_14;
    reg [7:0] memory_15;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            memory_0 <= 8'b0;
            memory_1 <= 8'b0;
            memory_2 <= 8'b0;
            memory_3 <= 8'b0;
            memory_4 <= 8'b0;
            memory_5 <= 8'b0;
            memory_6 <= 8'b0;
            memory_7 <= 8'b0;
            memory_8 <= 8'b0;
            memory_9 <= 8'b0;
            memory_10 <= 8'b0;
            memory_11 <= 8'b0;
            memory_12 <= 8'b0;
            memory_13 <= 8'b0;
            memory_14 <= 8'b0;
            memory_15 <= 8'b0;
        end
        else if(MemWrite && PC_enable_sig) begin
            case (address_index)
                4'd0: memory_0 <= WriteData;
                4'd1: memory_1 <= WriteData;
                4'd2: memory_2 <= WriteData;
                4'd3: memory_3 <= WriteData;
                4'd4: memory_4 <= WriteData;
                4'd5: memory_5 <= WriteData;
                4'd6: memory_6 <= WriteData;
                4'd7: memory_7 <= WriteData;
                4'd8: memory_8 <= WriteData;
                4'd9: memory_9 <= WriteData;
                4'd10: memory_10 <= WriteData;
                4'd11: memory_11 <= WriteData;
                4'd12: memory_12 <= WriteData;
                4'd13: memory_13 <= WriteData;
                4'd14: memory_14 <= WriteData;
                default: memory_15 <= WriteData;
            endcase
        end
    end

    always @(*) begin
        case (address_index)
            4'd0: read_data = memory_0;
            4'd1: read_data = memory_1;
            4'd2: read_data = memory_2;
            4'd3: read_data = memory_3;
            4'd4: read_data = memory_4;
            4'd5: read_data = memory_5;
            4'd6: read_data = memory_6;
            4'd7: read_data = memory_7;
            4'd8: read_data = memory_8;
            4'd9: read_data = memory_9;
            4'd10: read_data = memory_10;
            4'd11: read_data = memory_11;
            4'd12: read_data = memory_12;
            4'd13: read_data = memory_13;
            4'd14: read_data = memory_14;
            default: read_data = memory_15;
        endcase
    end

    assign MemData_Out = (MemRead) ? read_data : 8'b0;

    wire _unused = &{Adress[7:4], 1'b0};
endmodule
