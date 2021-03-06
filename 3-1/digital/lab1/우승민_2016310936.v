
`timescale 1 ns / 100 ps

`include "logic_gate.v"

module alu
    #(
        parameter WORD_SIZE    = 8
       ,parameter ALU_CON_SIZE = 4
    )
        (
            input             [ALU_CON_SIZE-1:0]  alu_con
           ,input      signed [WORD_SIZE-1   :0]  data_in_1
           ,input      signed [WORD_SIZE-1   :0]  data_in_2
           
           ,output     signed [WORD_SIZE-1   :0]  data_out
        );
    
    
    localparam ADD = 4'b0010,
               SUB = 4'b0110,
               AND = 4'b0000,
               OR  = 4'b0001,
               NOR = 4'b1111;
			
    
    ////////////////////////////////////////////////////////
    /////////////write your code here///////////////////////
    wire [WORD_SIZE-1   :0] A0, A1, S0, S1, N0, N1, M0, M1, C0, C1, k, A2;

    assign k = ~data_in_2;


    genvar idx;
    for (idx = 0; idx <WORD_SIZE; idx = idx + 1) 
           begin 
           logic_and x0(.data_in_1(data_in_1[idx]), .data_in_2(data_in_2[idx]), .data_out(A0[idx]));
           end

    for (idx = 0; idx <WORD_SIZE; idx = idx + 1) 
           begin 
           logic_or y0(.data_in_1(data_in_1[idx]), .data_in_2(data_in_2[idx]), .data_out(A1[idx]));
           end

    for (idx = 0; idx <WORD_SIZE; idx = idx + 1) 
           begin 
           logic_xor a0(.data_in_1(data_in_1[idx]), .data_in_2(data_in_2[idx]), .data_out(N0[idx]));
           end

    for (idx = 0; idx <WORD_SIZE; idx = idx + 1) 
           begin 
           if(idx ==0)
                begin
                logic_and b0(.data_in_1(N0[idx]), .data_in_2(0), .data_out(M0[idx]));
                logic_xor c0(.data_in_1(N0[idx]), .data_in_2(0), .data_out(S0[idx]));
                logic_or d0(.data_in_1(A0[idx]), .data_in_2(M0[idx]), .data_out(C0[idx+1]));
                end
           else if(idx == WORD_SIZE-1)
                begin
                logic_and b0(.data_in_1(N0[idx]), .data_in_2(C0[idx]), .data_out(M0[idx]));
                logic_xor c0(.data_in_1(N0[idx]), .data_in_2(C0[idx]), .data_out(S0[idx]));
                end
           else
                begin
                logic_and b0(.data_in_1(N0[idx]), .data_in_2(C0[idx]), .data_out(M0[idx]));
                logic_xor c0(.data_in_1(N0[idx]), .data_in_2(C0[idx]), .data_out(S0[idx]));
                logic_or d0(.data_in_1(A0[idx]), .data_in_2(M0[idx]), .data_out(C0[idx+1]));
                end
           end

    for (idx = 0; idx <WORD_SIZE; idx = idx + 1) 
           begin 
           logic_xor aa0(.data_in_1(data_in_1[idx]),.data_in_2(k[idx]),.data_out(N1[idx])); 
           logic_and e0(.data_in_1(data_in_1[idx]), .data_in_2(k[idx]), .data_out(A2[idx]));
           end

    for (idx = 0; idx <WORD_SIZE; idx = idx + 1) 
           begin 
           if(idx ==0)
                begin
                logic_and f0(.data_in_1(N1[idx]), .data_in_2(1), .data_out(M1[idx]));
                logic_xor g0(.data_in_1(N1[idx]), .data_in_2(1), .data_out(S1[idx]));
                logic_or h0(.data_in_1(A2[idx]), .data_in_2(M1[idx]), .data_out(C1[idx+1]));
                end
           else if(idx == WORD_SIZE-1)
                begin
                logic_and f0(.data_in_1(N1[idx]), .data_in_2(C1[idx]), .data_out(M1[idx]));
                logic_xor g0(.data_in_1(N1[idx]), .data_in_2(C1[idx]), .data_out(S1[idx]));
                end
           else
                begin
                logic_and f0(.data_in_1(N1[idx]), .data_in_2(C1[idx]), .data_out(M1[idx]));
                logic_xor g0(.data_in_1(N1[idx]), .data_in_2(C1[idx]), .data_out(S1[idx]));
                logic_or h0(.data_in_1(A2[idx]), .data_in_2(M1[idx]), .data_out(C1[idx+1]));
                end
           end

    
    assign data_out = (alu_con==ADD)? S0 : 
			(alu_con==SUB)? S1 : 
 			(alu_con==AND)? A0 : 
			(alu_con==OR)? A1 : 
			(alu_con==NOR)? ~A1 : 0;

            
    ///////////////////////////////////////////////////////

endmodule