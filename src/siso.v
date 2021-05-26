// DEFINE NUMBER OF BITS TO REPRESENT LLR HERE!!
//
`define LLR_BITS    13
//
//

module over(a, b, result);
	parameter WIDTH = `LLR_BITS;
	parameter MSB   = WIDTH-1;
	parameter neg 	= {1'b1, {(WIDTH-1){1'b0}}};
	parameter pos 	= {1'b0, {(WIDTH-1){1'b1}}};
	input signed [WIDTH-1:0] a, b;
	output reg signed [WIDTH-1:0] result;

	reg signed [WIDTH-1:0] temp;
	reg overflow, underflow;
	reg extra;

	always @* begin
		{extra, temp} = {a[MSB], a} + {b[MSB], b};
		overflow  = ({extra, temp[MSB]} == 2'b01) ? 1'b1 : 1'b0;
		underflow = ({extra, temp[MSB]} == 2'b10) ? 1'b1 : 1'b0;
		result = 	(overflow) 	? pos : 
					(underflow)	? neg : temp;
	end
endmodule

module Siso(
						 clk_i,
						 reset_n_i,
						 read_en_i,
						 sys_i,
						 enc_i,
						 ext_i,
						 data_o,
						 finish
	);

	/*========================Parameter declaration===================== */	
	parameter data_size  	= `LLR_BITS;                            // every number size = 4
	parameter input_size 	= 5;                                // input size (bit length) before encoding = 5
	parameter extend_size	= 7;                                // input_size + 2][adding 00 at the end
	parameter block_size 	= 21;                               // 3 * (input_size + 2)
	parameter neg_inf    	= {1'b1, {(data_size-1){1'b0}}};    // - 2^(data_size-1) 
	parameter LLR_size	 	= extend_size*data_size;
	parameter READ_DATA  	= 3'b000;
	parameter BRANCH     	= 3'b001;
	parameter FORWARD    	= 3'b010;
	parameter BACKWARD   	= 3'b011;
	parameter LLR_COMPUTE	= 3'b100;

	/*========================IO declaration============================ */	  
	input                       clk_i;
	input                       reset_n_i;
	input                       read_en_i;
	// input           	        data_i;       [0:block_size-1];  
	input  signed  [28-1:0]     sys_i;
	input  signed  [28-1:0]     enc_i;
	input  signed  [LLR_size-1:0]     ext_i;
	output signed  [LLR_size-1:0]     data_o;
	output                      finish;

	/* =======================REG & wire================================ */
	reg					[2:0]						state, state_nxt;
	reg                         done, done_nxt;
	assign finish = done;

	reg signed  [3:0]	        sys                 	[0:extend_size-1];
	reg signed  [3:0]	        enc                 	[0:extend_size-1];
	reg signed  [data_size-1:0]	ext                 	[0:extend_size-1];
	reg signed	[3:0]	        sys_neg               	[0:extend_size-1];
	reg signed	[3:0]	        enc_neg              	[0:extend_size-1];
	reg signed	[data_size-1:0]	ext_neg                 [0:extend_size-1];
	reg signed	[data_size-1:0]	sys_enc                 [0:extend_size-1] [0:3];

	reg signed	[data_size-1:0]	branch_metrics 			[0:extend_size-1] [0:3] [0:3];  // +-128
	reg signed	[data_size-1:0]	forward_metrics 		[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	backward_metrics 		[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	LLR             		[0:extend_size-1];
	wire signed	[data_size-1:0]	branch_sum				[0:extend_size-1] [0:3];
	wire signed	[data_size-1:0]	forward_sum				[0:extend_size-1] [0:7];
	wire signed	[data_size-1:0]	backward_sum			[0:extend_size-1] [0:7];
	wire signed	[data_size-1:0]	LLR_sum					[0:extend_size-1] [0:7];

	reg signed  [data_size-1:0] negative            [0:3];    
	reg signed  [data_size-1:0] positive            [0:3];  
	reg signed  [data_size-1:0] max_negative, max_positive, temp_positive_1,temp_positive_2, temp_negative_1, temp_negative_2;

	integer k, n; 
	/* ====================Combinational Part================== */

	assign data_o = {LLR[0], LLR[1], LLR[2], LLR[3], LLR[4], LLR[5], LLR[6]};

	always@(*) begin
		for(n=0;n<extend_size;n=n+1) begin
			sys_neg[n] = ~sys[n] + 1;
			enc_neg[n] = ~enc[n] + 1;
			ext_neg[n] = ~ext[n] + 1;
			sys_enc[n][0] = sys[n] + enc[n];
			sys_enc[n][1] = sys[n] - enc[n];
			sys_enc[n][2] = -sys[n] + enc[n];
			sys_enc[n][3] = -sys[n] - enc[n];
		end
	end
	
	genvar j, l, m;
	generate
		for(l=1;l<=extend_size;l=l+1) begin
			over f0(.a(forward_metrics[l-1][0]), .b(branch_metrics[l-1][0][0]), .result(forward_sum[l-1][0]) );
			over f1(.a(forward_metrics[l-1][1]), .b(branch_metrics[l-1][1][0]), .result(forward_sum[l-1][1]) );
			over f2(.a(forward_metrics[l-1][2]), .b(branch_metrics[l-1][2][1]), .result(forward_sum[l-1][2]) );
			over f3(.a(forward_metrics[l-1][3]), .b(branch_metrics[l-1][3][1]), .result(forward_sum[l-1][3]) );
			over f4(.a(forward_metrics[l-1][0]), .b(branch_metrics[l-1][0][2]), .result(forward_sum[l-1][4]) );
			over f5(.a(forward_metrics[l-1][1]), .b(branch_metrics[l-1][1][2]), .result(forward_sum[l-1][5]) );
			over f6(.a(forward_metrics[l-1][2]), .b(branch_metrics[l-1][2][3]), .result(forward_sum[l-1][6]) );
			over f7(.a(forward_metrics[l-1][3]), .b(branch_metrics[l-1][3][3]), .result(forward_sum[l-1][7]) );

			over b0(.a(backward_metrics[l-1][0]), .b(branch_metrics[extend_size-l][0][0]), .result(backward_sum[l-1][0]) );
			over b1(.a(backward_metrics[l-1][2]), .b(branch_metrics[extend_size-l][0][2]), .result(backward_sum[l-1][1]) );
			over b2(.a(backward_metrics[l-1][0]), .b(branch_metrics[extend_size-l][1][0]), .result(backward_sum[l-1][2]) );
			over b3(.a(backward_metrics[l-1][2]), .b(branch_metrics[extend_size-l][1][2]), .result(backward_sum[l-1][3]) );
			over b4(.a(backward_metrics[l-1][1]), .b(branch_metrics[extend_size-l][2][1]), .result(backward_sum[l-1][4]) );
			over b5(.a(backward_metrics[l-1][3]), .b(branch_metrics[extend_size-l][2][3]), .result(backward_sum[l-1][5]) );
			over b6(.a(backward_metrics[l-1][1]), .b(branch_metrics[extend_size-l][3][1]), .result(backward_sum[l-1][6]) );
			over b7(.a(backward_metrics[l-1][3]), .b(branch_metrics[extend_size-l][3][3]), .result(backward_sum[l-1][7]) );
		end
		for(m=0;m<extend_size;m=m+1) begin
			over LLR0(.a(forward_sum[m][0]), .b(backward_metrics[extend_size-m-1][0]), .result(LLR_sum[m][0]) );
			over LLR1(.a(forward_sum[m][5]), .b(backward_metrics[extend_size-m-1][2]), .result(LLR_sum[m][1]) );
			over LLR2(.a(forward_sum[m][2]), .b(backward_metrics[extend_size-m-1][1]), .result(LLR_sum[m][2]) );
			over LLR3(.a(forward_sum[m][7]), .b(backward_metrics[extend_size-m-1][3]), .result(LLR_sum[m][3]) );
			over LLR4(.a(forward_sum[m][4]), .b(backward_metrics[extend_size-m-1][2]), .result(LLR_sum[m][4]) );
			over LLR5(.a(forward_sum[m][1]), .b(backward_metrics[extend_size-m-1][0]), .result(LLR_sum[m][5]) );
			over LLR6(.a(forward_sum[m][6]), .b(backward_metrics[extend_size-m-1][3]), .result(LLR_sum[m][6]) );
			over LLR7(.a(forward_sum[m][3]), .b(backward_metrics[extend_size-m-1][1]), .result(LLR_sum[m][7]) );

			over Branch0(.a(sys_enc[m][3]), .b(ext_neg[m]), .result(branch_sum[m][0]) );
			over Branch1(.a(sys_enc[m][0]), .b(ext[m]), 	.result(branch_sum[m][1]) );
			over Branch2(.a(sys_enc[m][1]), .b(ext[m]), 	.result(branch_sum[m][2]) );
			over Branch3(.a(sys_enc[m][2]), .b(ext_neg[m]), .result(branch_sum[m][3]) );
		end
	endgenerate

	always @(*) begin
		done_nxt = 0;
		case(state)
			READ_DATA: begin
					if(read_en_i == 1) begin
						sys[6] = sys_i[3:0];
						sys[5] = sys_i[7:4];
						sys[4] = sys_i[11:8];
						sys[3] = sys_i[15:12];
						sys[2] = sys_i[19:16];
						sys[1] = sys_i[23:20];
						sys[0] = sys_i[27:24];

						enc[6] = enc_i[3:0];
						enc[5] = enc_i[7:4];
						enc[4] = enc_i[11:8];
						enc[3] = enc_i[15:12];
						enc[2] = enc_i[19:16];
						enc[1] = enc_i[23:20];
						enc[0] = enc_i[27:24];

						ext[6] = ext_i[LLR_size-1 - 6*data_size -: data_size];
						ext[5] = ext_i[LLR_size-1 - 5*data_size -: data_size];
						ext[4] = ext_i[LLR_size-1 - 4*data_size -: data_size];
						ext[3] = ext_i[LLR_size-1 - 3*data_size -: data_size];
						ext[2] = ext_i[LLR_size-1 - 2*data_size -: data_size];
						ext[1] = ext_i[LLR_size-1 - data_size -: data_size];
						ext[0] = ext_i[LLR_size-1 -: data_size];
						
						state_nxt = BRANCH;
					end
					else begin
						state_nxt = READ_DATA;
					end
			end
			BRANCH: begin
				for(k=0;k<extend_size;k=k+1) begin
					branch_metrics[k][0][0] = branch_sum[k][0]; //0 + 0 + 0;
					branch_metrics[k][0][2] = branch_sum[k][1]; //1 + 1 + 1;
					branch_metrics[k][1][0] = branch_sum[k][2]; //1 + 0 + 1;
					branch_metrics[k][1][2] = branch_sum[k][3]; //0 + 1 + 0;
					branch_metrics[k][2][1] = branch_sum[k][0]; //0 + 0 + 0;
					branch_metrics[k][2][3] = branch_sum[k][1]; //1 + 1 + 1;
					branch_metrics[k][3][1] = branch_sum[k][2]; //1 + 0 + 1;
					branch_metrics[k][3][3] = branch_sum[k][3]; //0 + 1 + 0;
				end
				state_nxt = FORWARD;
			end
			FORWARD: begin
				forward_metrics[0][0] = 0;
				forward_metrics[0][1] = neg_inf;
				forward_metrics[0][2] = neg_inf;
				forward_metrics[0][3] = neg_inf;
				for(k=1;k<=extend_size;k=k+1) begin
					forward_metrics[k][0] = (forward_sum[k-1][0] > forward_sum[k-1][1]) ? forward_sum[k-1][0] : forward_sum[k-1][1];
					forward_metrics[k][1] = (forward_sum[k-1][2] > forward_sum[k-1][3]) ? forward_sum[k-1][2] : forward_sum[k-1][3];
					forward_metrics[k][2] = (forward_sum[k-1][4] > forward_sum[k-1][5]) ? forward_sum[k-1][4] : forward_sum[k-1][5];
					forward_metrics[k][3] = (forward_sum[k-1][6] > forward_sum[k-1][7]) ? forward_sum[k-1][6] : forward_sum[k-1][7];
				end
				state_nxt = BACKWARD;
			end
			BACKWARD: begin
				backward_metrics[0][0] = 0;            //backward_metrics[extend_size][0] = 0;
				backward_metrics[0][1] = neg_inf;      //backward_metrics[extend_size][1] = neg_inf;
				backward_metrics[0][2] = neg_inf;      //backward_metrics[extend_size][2] = neg_inf;
				backward_metrics[0][3] = neg_inf;      //backward_metrics[extend_size][3] = neg_inf;
				for(k=1;k<=extend_size;k=k+1) begin    //for(k=extend_size-1;k>=0;k=k-1) begin
					backward_metrics[k][0] = (backward_sum[k-1][0] > backward_sum[k-1][1]) ? backward_sum[k-1][0] : backward_sum[k-1][1];
					backward_metrics[k][1] = (backward_sum[k-1][2] > backward_sum[k-1][3]) ? backward_sum[k-1][2] : backward_sum[k-1][3];
					backward_metrics[k][2] = (backward_sum[k-1][4] > backward_sum[k-1][5]) ? backward_sum[k-1][4] : backward_sum[k-1][5];
					backward_metrics[k][3] = (backward_sum[k-1][6] > backward_sum[k-1][7]) ? backward_sum[k-1][6] : backward_sum[k-1][7];
				end
				state_nxt = LLR_COMPUTE;
			end
			LLR_COMPUTE: begin
				for(k=0;k<extend_size;k=k+1) begin
					negative[1] = LLR_sum[k][0];
					negative[2] = LLR_sum[k][1];
					negative[3] = LLR_sum[k][2];
					negative[0] = LLR_sum[k][3];
					positive[1] = LLR_sum[k][4];
					positive[2] = LLR_sum[k][5];
					positive[3] = LLR_sum[k][6];
					positive[0] = LLR_sum[k][7];
					temp_positive_1 = (positive[1]>positive[2]) ? positive[1] : positive[2];
					temp_positive_2 = (positive[3]>positive[0]) ? positive[3] : positive[0];
					max_positive = (temp_positive_1>temp_positive_2) ? temp_positive_1 : temp_positive_2;
					temp_negative_1 = (negative[1]>negative[2]) ? negative[1] : negative[2];
					temp_negative_2 = (negative[3]>negative[0]) ? negative[3] : negative[0];
					max_negative = (temp_negative_1>temp_negative_2) ? temp_negative_1 : temp_negative_2;
					LLR[k] = max_positive - max_negative;
				end
				state_nxt = READ_DATA;
				done_nxt  = 1;
			end
		endcase
	end

	/* ====================Sequential Part=================== */
		always@(posedge clk_i or negedge reset_n_i)
		begin
				if (reset_n_i == 1'b0)
						begin  
							state <= READ_DATA;
							done  <= 0;
						end
				else
						begin 
							state <= state_nxt;
							done  <= done_nxt;
						end
		end
	/* ====================================================== */

endmodule

