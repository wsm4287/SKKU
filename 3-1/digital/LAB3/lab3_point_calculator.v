`timescale 1 ns / 100 ps

module point_calculator
	#(
		parameter WORD_SIZE 	= 32,
		parameter CLOCK_PERIOD 	= 1
	)
	(
		clk,
		rstn,
		selector,
		operand1,
		operand2,
		result,
		flag,
		done
	);
	input clk;
	input rstn;
	input [2:0] selector;
	input [WORD_SIZE-1:0] operand1,operand2;
	
	output reg [WORD_SIZE-1:0] result;
	output reg flag,done;

/*
no use # syntax and initial syntax
but you can create submodule or register when you need.
*/
///////////////////your code here///////////////////

  reg [WORD_SIZE-1:0] fix1;
  reg [WORD_SIZE-1:0] fix2;
  reg sign;
  reg [WORD_SIZE-1:0] flo1;
  reg [WORD_SIZE-1:0] flo2;
  reg [WORD_SIZE*2-1:0] mul1;
  integer n,i;
  integer x,y;

    always @(posedge rstn) begin
	fix1 <= 0;
	fix2 <= 0;
	sign <= 0;
	flo1 <= 0;
	flo2 <= 0;
	mul1 <= 0;
	n <= 0;
	i <= 0;
	x <= 0;
	y <= 0;
	done <=0;
	flag <=0;
	result <=0;
    end

    always @(posedge clk) begin
	if(rstn == 1) begin
	  fix1 = 0;
	  fix2 = 0;
	  sign = 0;
	  flo1 = 0;
	  flo2 = 0;
	  mul1 = 0;
          result = 0;
	  case(selector)
	  3'b000 : begin
	    flag = 0;
	    if(operand1[31:31] == operand2[31:31]) begin 
	      if(operand1[31:31] == 0) begin // positive + positive
	        sign = operand1[31:31];
	        fix1 = operand1[30:0] + operand2[30:0];
		if(fix1[31:31] == 1) flag = 1;
	        result[31:31] = sign;
	        result[30:0] = fix1[30:0];
	      end
	      else begin // negative + negative
		sign = operand1[31:31];
		fix1 = ~operand1 + 1;
		fix2 = ~operand2 + 1;
		fix1 = fix1 + fix2;
		if(fix1[31:31] == 1) flag = 1;
		else result[30:0] = fix1[30:0];
		result = ~result + 1;
	      end
	    end
	    else begin	// positive + negative
	      if(operand1[31:31] == 0) begin
		fix1 = operand1;
		fix2 = ~operand2 + 1;
	      end
	      else begin
		fix1 = operand2;
		fix2 = ~operand1 + 1;
	      end
	      if(fix1[31:0] >= fix2[31:0]) begin
		result[30:0] = fix1[30:0] - fix2[30:0];
		result[31:31] = 0;
	      end
	      else begin
		result[31:0] = fix2[31:0] - fix1[31:0];
		result = ~result + 1;
	      end
	    end
	    done <= 1;
	  end

	  3'b001 : begin
	    flag = 0;
	    sign = operand1[31:31] ^ operand2[31:31];
	    if(operand1[31:31] == operand2[31:31]) begin 
	      if(operand1[31:31] == 0) begin // positive * positive
	        mul1[63:0] = operand1[30:0] * operand2[30:0];
                result[31:31] = sign;
	        if(mul1[63:47] !== 17'b0) flag = 1;
                result[30:0] = mul1[46:16];
	        if(mul1[15:15] == 1) begin
	          result = result + 1;
	          if(result[31:31] != sign) flag = 1;
		end
	      end
	      else begin // negative * negative
		fix1 = ~operand1 + 1;
		fix2 = ~operand2 + 1;
		mul1[63:0] = fix1 * fix2;
                result[31:31] = sign;
	        if(mul1[63:47] !== 17'b0) flag = 1;
                result[30:0] = mul1[46:16];
	        if(mul1[15:15] == 1) begin
	          result = result + 1;
	          if(result[31:31] != sign) flag = 1;
		end
	      end
	    end
	    else begin  // positive * negative
	      if(operand1[31:31] ==1) fix1 = ~operand1 + 1;
	      else fix1 = operand1;
	      if(operand2[31:31] ==1) fix2 = ~operand2 + 1;
	      else fix2 = operand2;	     
	      mul1[63:0] = fix1 * fix2;
	      if(mul1[63:48] !== 16'b0) flag = 1;
              result[31:0] = mul1[47:16];
	      if(mul1[15:15] == 1) begin
	        result = result + 1;
	        if(result[31:31] != 0) flag = 1;
	      end	
	      result = ~result + 1;
	    end	    
	    done <=1;
	  end

	  3'b010 : begin
	    sign = operand1[31:31];
	    flag = 0;
	    if(operand1[30:0] == 31'b0) flo1 = 0; // 0 -> 0
	    else begin
	      if(sign ==0) begin
              fix1[14:0] = operand1[30:16];
	      fix2[15:0] = operand1[15:0];
              end
	      else begin
	      fix1 = ~operand1 + 1;
              fix2[15:0] = fix1[15:0];
              fix1[14:0] = fix1[30:16];
              fix1[30:16] = 15'b0;
	      end
	      if(fix1) begin
		n = 14;
	        while(fix1[14:14]!=1) begin
		  n = n-1;
		  fix1 = fix1 << 1;
		end
              end
              else begin
		n = -1;
	        while(fix2[15:15] != 1) begin
		  n = n -1;
		  fix2 = fix2 << 1;
	        end
	      end
	      flo1[30:23] = 8'b01111111;
	      if(n >= 0) begin
		for(i=0; i<n; i= i+1) flo1[30:23]= flo1[30:23] +1;
		if(sign==0) flo2[30:0] = operand1[30:0];
		else flo2[30:0] = ~operand1 + 1;
		while(flo2[30:30] != 1) flo2 = flo2 << 1;
		flo2 = flo2 << 1;
		flo1[22:0] = flo2[30:8];
	      end
	      else begin
		for(i=0; i>n; i= i-1) flo1[30:23]= flo1[30:23] -1;
		if(sign==0) flo2[30:0] = operand1[30:0];
		else flo2[30:0] = ~operand1 + 1;
		while(flo2[30:30] != 1) flo2 = flo2 << 1;
		flo2 = flo2 << 1;
		flo1[22:0] = flo2[30:8];
	      end	    
	    end
	    result[31:31] = sign;
	    result[30:0] = flo1[30:0];	
	    done <=1;
	  end

	  3'b011 : begin
	    if(operand1[31:31] == operand2[31:31]) begin
	    result <= (operand1 >= operand2)? operand1 : operand2;
	    end
	    if((operand1[31:31] == 0) && (operand2[31:31] ==1)) begin
	    result <= operand1;
	    end
	    if((operand1[31:31] == 1) && (operand2[31:31] ==0)) begin
	    result <= operand2;
	    end
	    flag <= 0;
	    done <=1;
	  end

	  3'b100 : begin
	    if(operand1[31:31] == operand2[31:31]) begin // addition
	      if(operand1[30:23] >= operand2[30:23]) begin // operand1 exp >= operand2 exp
                sign = operand1[31:31];
		if(operand1[30:23] == 8'b11111111) flo2[30:0] = operand1[30:0];
		if(operand2[30:23] == 8'b0) begin
		  if(operand2[30:0] == 31'b0) flo2[30:0] = operand1[30:0];
		  else begin
		    if(operand1[30:23] == 8'b0) begin // denormal + denormal
		      flo1[23:0] = operand1[22:0] + operand2[22:0];
		      flo2[22:0] = flo1[22:0];
		      if(flo1[23:23] == 1) flo2[23:23] = 1;
		    end
		    else begin // normal + denormal
	              n = operand1[30:23] - operand2[30:23];
	              flo1[22:0] = operand2[22:0];
	              for(i=0; i<n-1; i= i+1) flo1 = flo1 >> 1;
		      if(flo1[0:0] == 1) flo1 = flo1+1;
		      flo1 = flo1 >> 1;
	              flo2[23:0] = operand1[22:0] + flo1[22:0];
	              if(flo2[23:23] == 1) begin 
			flo2[23:23] = 0;
		        if(flo2[0:0] == 1) flo2 = flo2 + 1;
		        flo2 = flo2 >> 1;
		        flo2[31:23] = operand1[31:23] +1;
		      end
	              else flo2[31:23] = operand1[31:23];
		    end
		  end
		end
		else begin  // normal + normal
	          n = operand1[30:23] - operand2[30:23];
	          flo1[22:0] = operand2[22:0];
		  if(n!=0) begin
		    flo1[23:23] = 1;
	            for(i=0; i<n-1; i= i+1) flo1 = flo1 >> 1;
                    if(flo1[0:0] == 1) flo1 = flo1+1;
                    flo1 = flo1 >> 1;
	            flo2[23:0] = operand1[22:0] + flo1[22:0];
	            if(flo2[23:23] == 1) begin 
		      flo2[23:23] = 0;
		      if(flo2[0:0] == 1) flo2 = flo2 + 1;
		      flo2 = flo2 >> 1;
		      flo2[31:23] = operand1[31:23] +1;
		    end
	            else flo2[31:23] = operand1[31:23];
                  end
                  else begin
                    flo1[23:23] = 1;
                    flo2[22:0] = operand1[22:0];
                    flo2[23:23] = 1;
                    flo2[24:0] = flo1[23:0] + flo2[23:0];
                    flo2 = flo2 >> 1;
                    flo2[31:23] = operand1[31:23] + 1;
                  end
		end
	      end

	      else begin //operand2 exp > operand1 exp
                sign = operand2[31:31];
		if(operand2[30:23] == 8'b11111111) flo2[30:0] = operand2[30:0];
		if(operand1[30:23] == 8'b0) begin
		  if(operand1[30:0] == 31'b0) flo2[30:0] = operand2[30:0];
		  else begin // denormal + denoraml
		    if(operand2[30:23] == 8'b0) begin
		      flo1[23:0] = operand1[22:0] + operand2[22:0];
		      flo2[22:0] = flo1[22:0];
		      if(flo1[23:23] == 1) flo2[23:23] = 1;
		    end
		    else begin // denormal + normal
	              n = operand2[30:23] - operand1[30:23];
	              flo1[22:0] = operand1[22:0];
	              for(i=0; i<n-1; i= i+1) flo1 = flo1 >> 1;
		      if(flo1[0:0] == 1) flo1 = flo1+1;
		      flo1 = flo1 >> 1;
	              flo2[23:0] = operand2[22:0] + flo1[22:0];
	              if(flo2[23:23] == 1) begin 
		        flo2[23:23] = 0;
		        if(flo2[0:0] == 1) flo2 = flo2 + 1;
		        flo2 = flo2 >> 1;
		        flo2[31:23] = operand2[31:23] +1;
		      end
	              else flo2[31:23] = operand2[31:23];
		    end
		  end
		end
		else begin   // normal + normal
	          n = operand2[30:23] - operand1[30:23];
	          flo1[22:0] = operand1[22:0];
		  if(n!=0) begin
		    flo1[23:23] = 1;
	            for(i=0; i<n-1; i= i+1) flo1 = flo1 >> 1;
                    if(flo1[0:0] == 1) flo1 = flo1+1;
                    flo1 = flo1 >> 1;
	            flo2[23:0] = operand2[22:0] + flo1[22:0];
	            if(flo2[23:23] == 1) begin 
		      flo2[23:23] = 0;
		      if(flo2[0:0] == 1) flo2 = flo2 + 1;
		      flo2 = flo2 >> 1;
		      flo2[31:23] = operand2[31:23] +1;
		    end
	            else flo2[31:23] = operand2[31:23];
		  end
                  else begin
                    flo1[23:23] = 1;
                    flo2[22:0] = operand2[22:0];
                    flo2[23:23] = 1;
                    flo2[24:0] = flo1[23:0] + flo2[23:0];
                    flo2 = flo2 >> 1;
                    flo2[31:23] = operand2[31:23] + 1;
                  end
                end
	      end
              if(flo2[30:23] == 8'b11111111) flag = 1;
              else flag = 0;
    	      result[31:31] = sign;
	      result[30:0] = flo2[30:0];
	    end

	    else begin //subtraction
	      flag = 0;
	      if(operand1[30:23] > operand2[30:23]) begin // exp1 > exp2
		sign = operand1[31:31];
		if(operand1[30:23] == 8'b11111111) begin
		  if(operand2[30:23] == 8'b11111111) flo2[31:0] = 32'hFFFFFFFF;
		  else flo2[30:0] = operand1[30:0];
		end
		else begin
		  if(operand2[30:23] == 8'b0) begin // normal - denormal
		    if(operand2[30:0] == 31'b0) flo2[30:0] = operand1[30:0];
		    else begin
	              n = operand1[30:23] - operand2[30:23];
	              flo1[22:0] = operand2[22:0];
	              for(i=0; i<n-1; i= i+1) flo1 = flo1 >> 1;
		      if(flo1[0:0] == 1) flo1 = flo1+1;
		      flo1 = flo1 >> 1;
		      if(operand1[22:0] >= flo1[22:0]) begin 
			flo2[22:0] = operand1[22:0] - flo1[22:0];
			flo2[31:23] = operand1[31:23];
		      end
		      else begin
			flo2[23:23] = 1;
			flo2[22:0] = operand1[22:0];
			flo2[23:0] = flo2[23:0] - flo1[22:0];
			flo1[31:23] = operand1[31:23];
			while((flo2[23:23] != 1) && (flo1[31:23] != 8'b0)) begin 
			  flo2 = flo2 << 1;
			  flo1[31:23] = flo1[31:23] - 1;
			end
			flo2[31:23] = flo1[31:23];
		      end
		    end
		  end

		  else begin  // normal - normal
	            n = operand1[30:23] - operand2[30:23];
	            flo1[22:0] = operand2[22:0];
		    flo1[23:23] = 1;
	            for(i=0; i<n-1; i= i+1) flo1 = flo1 >> 1;
		    if(flo1[0:0] == 1) flo1 = flo1+1;
		    flo1 = flo1 >> 1;
		    if(operand1[22:0] >= flo1[22:0]) begin
	              flo2[22:0] = operand1[22:0] - flo1[22:0];
	              flo2[31:23] = operand1[31:23];
		    end
		    else begin
		      flo2[23:23] = 1;
		      flo2[22:0] = operand1[22:0];
		      flo2[23:0] = flo2[23:0] - flo1[22:0];	
		      flo1[31:23] = operand1[31:23];
		      while((flo2[23:23] != 1) && (flo1[31:23] != 8'b0)) begin 
			flo2 = flo2 << 1;
			flo1[31:23] = flo1[31:23] - 1;
		      end
		      flo2[31:23] = flo1[31:23];	      
		    end  
		  end

	        end
	      end

	      else if(operand1[30:23] == operand2[30:23]) begin // exp1 == exp2
		if(operand1[30:23] == 8'b0) begin // denormal - denormal
		  if(operand1[22:0] > operand2[22:0]) begin
		    sign = operand1[31:31];
		    flo2[22:0] = operand1[22:0] - operand2[22:0];
		    flo2[30:23] = operand1[30:23];
		  end
		  else if(operand1[22:0] == operand2[22:0]) flo2[31:0] = 32'b0;
		  else begin
		    sign = operand2[31:31];
		    flo2[22:0] = operand2[22:0] - operand1[22:0];
		    flo2[30:23] = operand2[30:23];
		  end
		end
		else begin // normal - normal
		  if(operand1[22:0] > operand2[22:0]) begin
		    sign = operand1[31:31];
		    flo2[23:0] = operand1[22:0] - operand2[22:0];
		    flo1[30:23] = operand1[30:23];
		    while(flo2[23:23]!=1) begin
		      flo2 = flo2 <<1;
	              flo1[30:23] = flo1[30:23] - 1;
	            end
		    flo2[30:23] = flo1[30:23];
		  end
		  else if(operand1[22:0] == operand2[22:0]) flo2[31:0] = 32'b0;
		  else begin
		    sign = operand2[31:31];
		    flo2[22:0] = operand2[22:0] - operand1[22:0];
		    flo1[30:23] = operand2[30:23];
		    while(flo2[23:23]!=1) begin
		      flo2 = flo2 <<1;
	              flo1[30:23] = flo1[30:23] - 1;
	            end
		    flo2[30:23] = flo1[30:23];
		  end
		end		  
	      end

	      else begin  // exp2 > exp1
		sign = operand2[31:31];
		if(operand2[30:23] == 8'b11111111) begin
		  if(operand1[30:23] == 8'b11111111) flo2[31:0] = 32'hFFFFFFFF;
		  else flo2[30:0] = operand2[30:0];
		end
		else begin
		  if(operand1[30:23] == 8'b0) begin // normal - denormal
		    if(operand1[30:0] == 31'b0) flo2[30:0] = operand2[30:0];
		    else begin
		      n = operand2[30:23] - operand1[30:23];
		      flo1[22:0] = operand1[22:0];
	              for(i=0; i<n-1; i= i+1) flo1 = flo1 >> 1;
		      if(flo1[0:0] == 1) flo1 = flo1+1;
		      flo1 = flo1 >> 1;
		      if(operand2[22:0] >= flo1[22:0]) begin
		        flo2[22:0] = operand2[22:0] - flo1[22:0];
			flo2[31:23] = operand2[31:23];
		      end
		      else begin
		        flo2[23:23] = 1;
			flo2[22:0] = operand2[22:0];
			flo2[23:0] = flo2[23:0] - flo1[22:0];
			flo1[31:23] = operand2[31:23];
			while((flo2[23:23] != 1) && (flo1[31:23] != 8'b0)) begin
			  flo2 = flo2 << 1;
			  flo1[31:23] = flo1[31:23] - 1;
			end
			flo2[31:23] = flo1[31:23];
		      end
		    end
		  end

		  else begin // normal - normal
	            n = operand2[30:23] - operand1[30:23];    
	            flo1[22:0] = operand1[22:0];
                    flo1[23:23] = 1;
	            for(i=0; i<n-1; i= i+1) flo1 = flo1 >> 1;
		    if(flo1[0:0] == 1) flo1 = flo1+1;
		    flo1 = flo1 >> 1;
		    if(operand2[22:0] >= flo1[22:0]) begin
	              flo2[22:0] = operand2[22:0] - flo1[22:0];
	              flo2[31:23] = operand2[31:23];
		    end
		    else begin
		      flo2[23:23] = 1;
		      flo2[22:0] = operand2[22:0];
		      flo2[23:0] = flo2[23:0] - flo1[22:0];	
		      flo1[31:23] = operand2[31:23];
		      while((flo2[23:23] != 1) && (flo1[31:23] != 8'b0)) begin 
			flo2 = flo2 << 1;
			flo1[31:23] = flo1[31:23] - 1;
		      end
		      flo2[31:23] = flo1[31:23];	      
		    end  
		  end

	        end
	      end


  	      result[31:31] = sign;
	      result[30:0] = flo2[30:0];	
            end
	    done <= 1;
	  end

	  3'b101 : begin
	    flag = 0;
	    if((operand1[30:0] == 31'b0) && (operand2[30:23] == 8'b11111111)) result = 32'hFFFFFFFF;  // 0 X INF = NAN
	    else if((operand2[30:0] == 31'b0) && (operand1[30:23] == 8'b11111111)) result = 32'hFFFFFFFF;  // 0 X INF = NAN
	    else if((operand1[30:0] == 31'b0) || (operand2[30:0] == 31'b0)) result = 32'b0; // 0 X ? = 0
	    else if((operand1[30:23] == 8'b11111111) || (operand2[30:23] == 8'b11111111)) result = 32'h7F800000; // INF X ? = INF

	    else begin
	      if((operand1[30:23] != 8'b0) && (operand2[30:23] != 8'b0)) begin // normal * normal 
	        x = operand1[30:23] - 8'b01111111;
	        y = operand2[30:23] - 8'b01111111;
	        n = x + y;
	            
	        flo1[23:23] = 1;
	        flo2[23:23] = 1;
	        flo1[22:0] = operand1[22:0];
	        flo2[22:0] = operand2[22:0];
	        mul1[47:0] = flo1[23:0] * flo2[23:0];

	        while(mul1[47:47]) begin 
		  n = n + 1;
		  mul1 = mul1 >> 1;
	        end

	        if(n > 127) flag = 1; // overflow
	        if(n < -149) flag = 1; // underflow

		if(n < -126) begin
		  flo1[30:23] = 8'b0;
		  while((n< -126) && (mul1 != 0)) begin
                    if((n == -127) && (mul1[22:22] == 1)) mul1 = mul1 + 64'h400000;
		    mul1 = mul1 >> 1;
		    n = n+1;
		  end
		  flo1[22:0] = mul1[45:23];
	        end	
	        else begin
                  if(mul1[22:22] == 1) mul1 = mul1 + 64'h400000;
		  flo1[30:23] = 8'b01111111 + n;
		  flo1[22:0] = mul1[45:23];
	        end
	      end

	      else if((operand1[30:23] == 8'b0) && (operand2[30:23] == 8'b0)) flag = 1; // denormal * denormal
 
	      else begin // normal * denormal
	        x = operand1[30:23] - 8'b01111111;
	        y = operand2[30:23] - 8'b01111111;
	        n = x + y + 1;

	        if(n < -149) flag = 1; // underflow

	        if(operand1[30:23] != 8'b0) flo1[23:23] = 1;
	        if(operand2[30:23] != 8'b0)  flo2[23:23] = 1;
	        flo1[22:0] = operand1[22:0];
	        flo2[22:0] = operand2[22:0];
	        mul1[47:0] = flo1[23:0] * flo2[23:0];	

		while(mul1[46:46] != 1) begin
		  mul1 = mul1 << 1;
	          n = n - 1;
		end

		if(n < -126) begin
		  flo1[30:23] = 8'b0;
		  while((n< -126) && (mul1 != 0)) begin
                    if((n == -127) && (mul1[22:22] == 1)) mul1 = mul1 + 64'h400000;
		    mul1 = mul1 >> 1;
		    n = n+1;
		  end
		  if(n!=-126) flag = 1;
		  flo1[22:0] = mul1[45:23];
	        end	
	        else begin
                  if(mul1[22:22] == 1) mul1 = mul1 + 64'h400000;
		  flo1[30:23] = 8'b01111111 + n;
		  flo1[22:0] = mul1[45:23];
	        end
		
	      end

	      sign = operand1[31:31] ^ operand2[31:31];
	      result[31:31] = sign;
	      result[30:0] = flo1[30:0];

	    end
	    done <= 1;
	  end

	  3'b110 : begin
	    flag = 0;
	    flo1[22:0] = operand1[22:0];
	    flo2[22:0] = operand1[22:0];
	    x = operand1[30:23] - 8'b01111111;
	    if(x>14) flag = 1; //overflow
	    else if(x<-16) flag = 1; //underflow
	    else begin
	      if(x>=0) begin
		flo1[23:23] = 1;
		flo2[23:23] = 1;
	        for(i=0; i<x; i = i+1) flo2 = flo2 << 1;
		fix1[15:0] = flo2[22:7];
		for(i=22; i>=x; i = i-1) flo1 = flo1 >> 1;
		fix1[30:16] = flo1[14:0];
		if(operand1[31:31] ==0) result[30:0] = fix1[30:0];
		else result = ~fix1 + 1;
		done <= 1;
	      end
	      else begin
		flo1[23:23] = 1;
		flo2[23:23] = 1;
		for(i=x; i<0; i = i+1) flo1 = flo1 >> 1;
		fix1[15:0] = flo1[22:7];
		fix1[30:16] = 15'b0;
		if(operand1[31:31] ==0) result[30:0] = fix1[30:0];
		else result = ~fix1 + 1;
	      end
	    end
            if(operand1[30:0] == 31'b0) begin 
	      result[31:0] = 32'b0;
	      flag = 0;
            end
	    done <= 1;
	  end

	  3'b111 : begin
	    if((operand1[31:31] == 0) && (operand2[31:31] ==0)) begin
	    result <= (operand1 >= operand2)? operand1 : operand2;
	    end
	    if((operand1[31:31] == 0) && (operand2[31:31] ==1)) begin
	    result <= operand1;
	    end
	    if((operand1[31:31] == 1) && (operand2[31:31] ==0)) begin
	    result <= operand2;
	    end
	    if((operand1[31:31] == 1) && (operand2[31:31] ==1)) begin
	    result <= (operand1 >= operand2)? operand2 : operand1;
	    end
	    flag <= 0;
	    done <=1;
	  end
        endcase
       end
     end
   
///////////////////your code end////////////////////
endmodule

//////your can create your own submodule here///////


////////////////your submodule end//////////////////