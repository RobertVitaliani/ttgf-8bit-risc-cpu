//Adder for PC+1. The module name is kept from the original design.
module PCplus4Adder (
    input  [7:0] FromPC,
    output [7:0] NextPC
);
    assign NextPC = FromPC + 8'd1;
endmodule
