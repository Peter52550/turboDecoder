`timescale 1ns/10ps
`define CYCLE       10
`define INPUT	    "../data/golden.dat"						 
`define EXPECT	    "../data/ans.dat"	


module siso_tb;
	parameter INPUT_NUM = 10;
	// parameter  [15:0] data_arr [0:4] = '{
	//		 16'b1111_0010_1100_1111,
	//		 16'b1111_0110_0100_1111,
	//		 16'b1000_0011_1100_0001,
	//		 16'b1001_1100_0101_1000,
	//		 16'b0110_1010_0100_1100
	//	 };
	// parameter  [15:0] answer_arr [0:4] = '{
	//		 16'b1111_0010_1100_1111,
	//		 16'b1111_0110_0100_1111,
	//		 16'b1000_0011_1100_0001,
	//		 16'b1001_1100_0101_1000,
	//		 16'b0110_1010_0100_1100
	//	 };

	reg				    clk, rst, over, stop;
	reg   [83:0]		data;
	reg   signed [28-1:0]		sys;
	reg   signed [28-1:0]		enc;
	reg   signed [84-1:0]		ext;
	wire  [84-1:0]	    out;
	reg				    en;
	reg   [84-1:0]	    out_temp;	   
	reg   [15:0]		err;
	wire				done;

	reg   [83:0]	    input_mem	[0:INPUT_NUM-1];
	reg   [83:0]		out_mem	    [0:INPUT_NUM-1];

	integer  iter, counter, pattern_num, out_f, out_error_f;


	Siso siso0(
		.clk_i(clk),
		.reset_n_i(rst), 
		.read_en_i(en),
		.sys_i(sys),
		.enc_i(enc),
		.ext_i(ext),
		.data_o(out),
		.finish(done)
	);	   
	
	initial	$readmemb (`INPUT,  input_mem);
	initial	$readmemb (`EXPECT, out_mem);

	initial begin
		clk		    = 1'b1;
		rst		    = 1'b1;
		stop        = 1'b0;
		counter	    = 0;
		iter		= 0;
		ext		    = 0;
		pattern_num = 0; 
		//	data		= data_arr[0];
		#2.5 rst=1'b0; 
		#2.5 rst=1'b1;
	end

	always begin #(`CYCLE/2) clk = ~clk; end

	initial begin
		$fsdbDumpfile("siso.fsdb");
		$fsdbDumpvars("+mda");
		out_f = $fopen("out.dat");
		out_error_f = $fopen("out_error.dat");
		if (out_f == 0) begin
			$display("Output file open error !");
			$finish;
		end
		else if (out_error_f == 0) begin
			$display("Output error file open error !");
			$finish;
		end
	end


	always @(negedge clk)begin
		if(counter==0 || (counter < 5*INPUT_NUM && done)) begin
			en = 1;
			sys		= input_mem[counter][83:83-28+1];
			//$display("%b", sys);
			//$display("%b %b %b %b %b %b %b", $signed(sys[3:0]), $signed(sys[7:4]), $signed(sys[11:8]), $signed(sys[15:12]), $signed(sys[19:16]), $signed(sys[23:20]), $signed(sys[27:24]));
			//$display("sys at time %d is %d %d %d %d %d %d %d", counter, $signed(sys[3:0]), $signed(sys[7:4]), $signed(sys[11:8]), $signed(sys[15:12]), $signed(sys[19:16]), $signed(sys[23:20]), $signed(sys[27:24]));
			enc		= input_mem[counter][83-28:83-28*2+1];
			ext 	= 70'b0;
			//$display("enc at time %d is %d %d %d %d %d %d %d", counter, $signed(enc[3:0]), $signed(enc[7:4]), $signed(enc[11:8]), $signed(enc[15:12]), $signed(enc[19:16]), $signed(enc[23:20]), $signed(enc[27:24]));
			counter = counter + 1;	
			out_temp = out_mem[counter];	 
		end
		if(counter >= 5*INPUT_NUM)
			stop = 1'd1;
	end

	always @(posedge clk)begin
		if(out !== out_temp) begin
			//$display("ERROR at %d:output %d !=expect %d ", pattern_num, out, out_temp);
			$fdisplay(out_error_f, "ERROR at %d:output %h !=expect %h ",pattern_num-2, out, out_temp);
			err = err + 1;
		end
		else begin
			$display("GREAT! You get %d and the output is %d", out, out_temp);
		end
		$fdisplay(out_f, "%d	output %h	expect %h ",pattern_num-2, out, out_temp);
		pattern_num = pattern_num + 1; 
		//$display("---------------------------------------------\n");
	end
	initial begin
		@(posedge stop)	  
		if(stop) begin
			$display("---------------------------------------------\n");
			$display("There are %d errors!\n", err);
			$display("The total accuracy is %d/%d\n", err, INPUT_NUM);
			$display("---------------------------------------------\n");
		end
		else begin
			$display("---------------------------------------------\n");
			$display("-------------SIMULATION FAIL!!!--------------\n");
			$display("---------------------------------------------\n");
		end
		$finish;
	end
 
endmodule



















