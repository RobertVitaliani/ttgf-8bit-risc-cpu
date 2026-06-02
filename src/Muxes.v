//Mux1
module Mux1 (
    input        sel1,
    input  [7:0] A1,
    input  [7:0] B1,
    output [7:0] mux1_out
);
    assign mux1_out = (sel1 == 1'b0) ? A1 : B1;
endmodule
