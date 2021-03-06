
`timescale 1 ns / 100 ps


module logic_and
        (
            input  data_in_1
           ,input  data_in_2
           
           ,output data_out
        );
    
    assign  data_out = data_in_1 & data_in_2;    

endmodule


module logic_orS
        (
            input  data_in_1
           ,input  data_in_2
           
           ,output data_out
        );
    
    assign  data_out = data_in_1 | data_in_2;    

endmodule


module logic_xor
        (
            input  data_in_1
           ,input  data_in_2
           
           ,output data_out
        );
    
    assign  data_out = data_in_1 ^ data_in_2;    

endmodule
