//Adder PC+Imm_Gen
module Adder (
    input  [7:0] in_1,
    input  [7:0] in_2,
    output [7:0] Add_out
);
    assign Add_out = in_1 + in_2;
endmodule
