
`timescale 1 ns / 100 ps

module memory_reader
	#(
		parameter WORD_SIZE 	= 32,
		parameter DATA_WIDTH 	= 32,
		parameter CLOCK_PERIOD 	= 1,
		parameter ADDRESS_SIZE	= 12,
		parameter MEMORY_SIZE 	= 4096
	)
	(
		clk,
		rstn,
		read_complete,
		allow_address,
		data_path,
		finish,
		address
	);

	input clk;
	input rstn;
	input read_complete;
	input allow_address;
	input [DATA_WIDTH-1:0] data_path;

	output reg [1:0] finish;
	output reg [ADDRESS_SIZE -1:0] address;

	reg [ADDRESS_SIZE -1:0] read[0:MEMORY_SIZE-1];
	reg [WORD_SIZE -1:0] data[0:MEMORY_SIZE-1];
	integer next_address;
	integer next_data;
	integer sequential_score;
	integer random_score;


	always @ (posedge clk or negedge rstn) begin
		if(!rstn) begin
		//reset
		next_address <= 0;
		next_data <= 0;
		address <= 'bz;
		end
		else begin
			#0.1
			if(read_complete == 1 && finish == 2'b00) begin//sequential read
				if(data[next_data] == data_path)begin
					sequential_score <= sequential_score + 1;
					$display("answer : %b your data : %b <right>",data[next_data],data_path);
				end
				else begin
					$display("answer : %b your data : %b <wrong>",data[next_data],data_path);
				end
				#0.1 next_data <= next_data +1;
			end
			else if(read_complete == 1 && finish == 2'b01) begin//random read
				if(data[next_data] == data_path)begin
					random_score <= random_score + 1;
					$display("answer : %b your data : %b <right>",data[next_data],data_path);
				end
				else begin
					$display("answer : %b your data : %b <wrong>",data[next_data],data_path);
				end
				#0.1 next_data <= next_data +1;
			end
			if(allow_address == 1) begin //give address
				address <= read[next_address];
				#0.1 next_address <= next_address + 1;
			end
			#0.2
			if(next_data == 4096)begin
				if(finish == 2'b01 )begin
					$display("sequential read score : %d/4096 random read score : %d/4096 ",sequential_score,random_score);
					$finish();
				end
				
				$readmemb("random_ans.bin",data);
				$readmemb("random_address.bin",read);
				#0.1 finish <= finish + 2'b01;
				
			end
		end

	end

	initial begin
	finish <= 2'b00;
	random_score <= 0;
	sequential_score <=0;
	$readmemb("sequential_ans.bin",data);
	$readmemb("sequential_address.bin",read);

	#9999999
	if(finish == 2'b00)begin
	$display("sequential read score : %d/%d random read score : 0/0 ",sequential_score,next_data);
	end
	else begin
	$display("sequential read score : %d/4096 random read score : %d/%d ",sequential_score,random_score,next_data);
	end
	end

endmodule
/*
module memory_reader
	#(
		parameter WORD_SIZE 	= 32,
		parameter DATA_WIDTH 	= 32,
		parameter CLOCK_PERIOD 	= 1,
		parameter ADDRESS_SIZE	= 12,
		parameter MEMORY_SIZE 	= 4096
	)
	(
		clk,
		rstn,
		read_complete,
		allow_address,
		data_path,
		finish,
		address
	);

	input clk;
	input rstn;
	input read_complete;
	input allow_address;
	input [DATA_WIDTH-1:0] data_path;

	output reg [1:0] finish;
	output reg [ADDRESS_SIZE -1:0] address;

	reg [ADDRESS_SIZE -1:0] read[0:MEMORY_SIZE-1];
	reg [WORD_SIZE -1:0] data[0:MEMORY_SIZE-1];
	integer next_address;
	integer next_data;
	integer sequential_score;
	integer random_score;


	always @ (posedge clk or negedge rstn) begin
		if(!rstn) begin
		//reset
		next_address <= 0;
		next_data <= 0;
		address <= 'bz;
		end
		else begin
			#0.1
			if(read_complete == 1 && finish == 2'b00) begin//sequential read
				if(data[next_data] == data_path)begin
					random_score <= random_score + 1;
					$display("answer : %b your data : %b <right>",data[next_data],data_path);
				end
				else begin
					$display("answer : %b your data : %b <wrong>",data[next_data],data_path);
				end
				#0.1 next_data <= next_data +1;
			end
			else if(read_complete == 1 && finish == 2'b01) begin//random read
				if(data[next_data] == data_path)begin
					sequential_score <= sequential_score + 1;
					$display("answer : %b your data : %b <right>",data[next_data],data_path);
				end
				else begin
					$display("answer : %b your data : %b <wrong>",data[next_data],data_path);
				end
				#0.1 next_data <= next_data +1;
			end
			if(allow_address == 1) begin //give address
				address <= read[next_address];
				#0.1 next_address <= next_address + 1;
			end
			#0.2
			if(next_data == 4096)begin
				if(finish == 2'b01 )begin
					$display("sequential read score : %d/4096 random read score : %d/4096 ",sequential_score,random_score);
					$finish();
				end
				
				$readmemb("sequential_ans.bin",data);
				$readmemb("sequential_address.bin",read);
				#0.1 finish <= finish + 2'b01;
				
			end
		end

	end

	initial begin
	finish <= 2'b00;
	random_score <= 0;
	sequential_score <=0;
	$readmemb("random_ans.bin",data);
	$readmemb("random_address.bin",read);

	#9999999
	if(finish == 2'b00)begin
	$display("sequential read score : %d/%d random read score : 0/0 ",sequential_score,next_data);
	end
	else begin
	$display("sequential read score : %d/4096 random read score : %d/%d ",sequential_score,random_score,next_data);
	end
	end

endmodule*/
