//Adder for PC+4
module PCplus4Adder(input [7:0] FromPC, output[7:0] NextPC);
assign NextPC= FromPC+ 8'd1;

endmodule

