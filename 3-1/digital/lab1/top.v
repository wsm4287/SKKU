
`timescale 1 ns / 100 ps

`include "alu_top.v"
`include "test_bench.v"


module top
    #(
        parameter WORD_SIZE    = 32
       ,parameter ALU_CON_SIZE = 4
    ) 
        (
            
        );
        
            reg                             clk;
            reg                             rstn;
                  
    integer run_time;
    real    clk_period;
    initial begin
            run_time   = 100;
            clk_period = 0.5;
            clk        <= 1'b1;
            rstn       <= 1'b0;
            #clk_period;
            #clk_period;
            rstn      <= 1'b1;
            
            #(run_time-2*clk_period);
            $finish();
    end
    always @(*) begin
        clk <=#clk_period ~clk;
    end
        
            wire        [ALU_CON_SIZE-1:0] alu_con;
            wire signed [WORD_SIZE-1   :0] data_in_1;
            wire signed [WORD_SIZE-1   :0] data_in_2;
            wire signed [WORD_SIZE-1   :0] data_out;

    alu_top
        #(
            .WORD_SIZE    (WORD_SIZE   ),
            .ALU_CON_SIZE (ALU_CON_SIZE)
            ) alu_top_0 (
                .clk      (clk      ),
                .rstn     (rstn     ),
                .alu_con  (alu_con  ),
                .data_in_1(data_in_1),
                .data_in_2(data_in_2),
                .data_out (data_out )
            );
            
    test_bench
        #(
            .WORD_SIZE    (WORD_SIZE   ),
            .ALU_CON_SIZE (ALU_CON_SIZE)
            ) test_bench_0 (
                .clk      (clk      ),
                .rstn     (rstn     ),
                .alu_con  (alu_con  ),
                .data_in_1(data_in_1),
                .data_in_2(data_in_2),
                .data_out (data_out )
            ); 
            

endmodule
