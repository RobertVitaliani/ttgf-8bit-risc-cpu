//register file
module Registers (
    input        clk,
    input        rst,
    input        RegWrite,
    input  [2:0] rs1,
    input  [2:0] rs2,
    input  [2:0] rd,
    input  [7:0] write_data,
    output [7:0] reg_data_1,
    output [7:0] reg_data_2
);
    
    reg [7:0] register_0;
    reg [7:0] register_1;
    reg [7:0] register_2;
    reg [7:0] register_3;
    reg [7:0] register_4;
    reg [7:0] register_5;
    reg [7:0] register_6;
    reg [7:0] register_7;

    always @(posedge rst or posedge clk) begin
        if(rst) begin
            register_0 <= 8'b0;
            register_1 <= 8'b0;
            register_2 <= 8'b0;
            register_3 <= 8'b0;
            register_4 <= 8'b0;
            register_5 <= 8'b0;
            register_6 <= 8'b0;
            register_7 <= 8'b0;
        end
        else if(RegWrite) begin
            case (rd)
                3'd0: register_0 <= write_data;
                3'd1: register_1 <= write_data;
                3'd2: register_2 <= write_data;
                3'd3: register_3 <= write_data;
                3'd4: register_4 <= write_data;
                3'd5: register_5 <= write_data;
                3'd6: register_6 <= write_data;
                default: register_7 <= write_data;
            endcase
        end
    end

    assign reg_data_1 = (rs1 == 3'd0) ? register_0 :
                        (rs1 == 3'd1) ? register_1 :
                        (rs1 == 3'd2) ? register_2 :
                        (rs1 == 3'd3) ? register_3 :
                        (rs1 == 3'd4) ? register_4 :
                        (rs1 == 3'd5) ? register_5 :
                        (rs1 == 3'd6) ? register_6 :
                                        register_7;

    assign reg_data_2 = (rs2 == 3'd0) ? register_0 :
                        (rs2 == 3'd1) ? register_1 :
                        (rs2 == 3'd2) ? register_2 :
                        (rs2 == 3'd3) ? register_3 :
                        (rs2 == 3'd4) ? register_4 :
                        (rs2 == 3'd5) ? register_5 :
                        (rs2 == 3'd6) ? register_6 :
                                        register_7;

    //forwarding ako se u t2 koristi rezultat iz t1
    //assign readData1 = (readReg1 == writeReg && regWrite) ? writeData : registers[readReg1];
endmodule
