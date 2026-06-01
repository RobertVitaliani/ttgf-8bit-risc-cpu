module Branch_Control (
    input is_beq, input is_bne, input is_blt, input zero, input less_than, output branch_control_top
);

    assign branch_control_top = (is_beq && zero) || 
                                (is_bne && !zero) || 
                                (is_blt && less_than); 


endmodule
