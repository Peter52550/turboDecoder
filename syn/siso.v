// DEFINE NUMBER OF BITS TO REPRESENT LLR HERE!!
//
`define LLR_BITS    12
//
//

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
	parameter neg_inf    	= {2'b11, {(data_size-2){1'b0}}};	// - 2^(data_size-2), originally {1'b1, {(data_size-1){1'b0}}} aka - 2^(data_size-1)
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
	reg signed  [3:0]	        sys_nxt                 [0:extend_size-1];
	reg signed  [3:0]	        enc                 	[0:extend_size-1];
	reg signed  [3:0]	        enc_nxt             	[0:extend_size-1];
	reg signed  [data_size-1:0]	ext                 	[0:extend_size-1];
	reg signed  [data_size-1:0]	ext_nxt             	[0:extend_size-1];
	reg signed	[3:0]	        sys_neg               	[0:extend_size-1];
	reg signed	[3:0]	        enc_neg              	[0:extend_size-1];
	reg signed	[data_size-1:0]	ext_neg                 [0:extend_size-1];
	reg signed	[data_size-1:0]	sys_enc                 [0:extend_size-1] [0:3];

	reg signed	[data_size-1:0]	branch_metrics 			[0:extend_size-1] [0:3];  // +-128
	reg signed	[data_size-1:0]	branch_metrics_nxt		[0:extend_size-1] [0:3];  // +-128
	reg signed	[data_size-1:0]	forward_metrics 		[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	forward_metrics_prev 	[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	backward_metrics 		[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	backward_metrics_prev	[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	LLR             		[0:extend_size-1];
	reg signed	[data_size-1:0]	LLR_nxt             	[0:extend_size-1];
	wire signed	[data_size-1:0]	branch_sum				[0:extend_size-1] [0:3];
	wire signed	[data_size-1:0]	forward_sum				[0:extend_size-1] [0:7];
	wire signed	[data_size-1:0]	backward_sum			[0:extend_size-1] [0:7];
	wire signed	[data_size-1:0]	LLR_sum					[0:extend_size-1] [0:7];

	reg signed  [data_size-1:0] negative            [0:extend_size-1][0:3];    
	reg signed  [data_size-1:0] positive            [0:extend_size-1][0:3];  
	reg signed  [data_size-1:0] max_negative		[0:extend_size-1];
	reg signed  [data_size-1:0] max_negative_neg	[0:extend_size-1];
	reg signed  [data_size-1:0] max_positive		[0:extend_size-1];
	reg signed  [data_size-1:0] temp_positive_1		[0:extend_size-1];
	reg signed  [data_size-1:0] temp_positive_2		[0:extend_size-1];
	reg signed  [data_size-1:0] temp_negative_1		[0:extend_size-1];
	reg signed  [data_size-1:0] temp_negative_2		[0:extend_size-1];
	wire signed [data_size-1:0] LLR_result			[0:extend_size-1];

	integer i, k, n; 
	/* ====================Combinational Part================== */

	assign data_o = {LLR[0], LLR[1], LLR[2], LLR[3], LLR[4], LLR[5], LLR[6]};

	always@(*) begin
		for(n=0;n<extend_size;n=n+1) begin
			sys_neg[n] = ~sys[n] + 1;
			enc_neg[n] = ~enc[n] + 1;
			ext_neg[n] = ~ext[n] + 1;
			max_negative_neg[n] = ~max_negative[n] + 1;
			sys_enc[n][0] = sys[n] + enc[n];
			sys_enc[n][1] = sys[n] - enc[n];
			sys_enc[n][2] = -sys[n] + enc[n];
			sys_enc[n][3] = -sys[n] - enc[n];
		end
	end

	genvar l, m;
	generate
		for(l=1;l<=extend_size;l=l+1) begin
			assign forward_sum[l-1][0] = forward_metrics[l-1][0] + branch_metrics[l-1][0];
			assign forward_sum[l-1][1] = forward_metrics[l-1][1] + branch_metrics[l-1][2];
			assign forward_sum[l-1][2] = forward_metrics[l-1][2] + branch_metrics[l-1][0];
			assign forward_sum[l-1][3] = forward_metrics[l-1][3] + branch_metrics[l-1][2];
			assign forward_sum[l-1][4] = forward_metrics[l-1][0] + branch_metrics[l-1][1];
			assign forward_sum[l-1][5] = forward_metrics[l-1][1] + branch_metrics[l-1][3];
			assign forward_sum[l-1][6] = forward_metrics[l-1][2] + branch_metrics[l-1][1];
			assign forward_sum[l-1][7] = forward_metrics[l-1][3] + branch_metrics[l-1][3];
			
			assign backward_sum[l-1][0] = backward_metrics[l-1][0] + branch_metrics[extend_size-l][0];
			assign backward_sum[l-1][1] = backward_metrics[l-1][2] + branch_metrics[extend_size-l][1];
			assign backward_sum[l-1][2] = backward_metrics[l-1][0] + branch_metrics[extend_size-l][2];
			assign backward_sum[l-1][3] = backward_metrics[l-1][2] + branch_metrics[extend_size-l][3];
			assign backward_sum[l-1][4] = backward_metrics[l-1][1] + branch_metrics[extend_size-l][0];
			assign backward_sum[l-1][5] = backward_metrics[l-1][3] + branch_metrics[extend_size-l][1];
			assign backward_sum[l-1][6] = backward_metrics[l-1][1] + branch_metrics[extend_size-l][2];
			assign backward_sum[l-1][7] = backward_metrics[l-1][3] + branch_metrics[extend_size-l][3];
		end
		for(m=0;m<extend_size;m=m+1) begin
			assign LLR_sum[m][0] = forward_sum[m][0] + backward_metrics[extend_size-m-1][0];
			assign LLR_sum[m][1] = forward_sum[m][5] + backward_metrics[extend_size-m-1][2];
			assign LLR_sum[m][2] = forward_sum[m][2] + backward_metrics[extend_size-m-1][1];
			assign LLR_sum[m][3] = forward_sum[m][7] + backward_metrics[extend_size-m-1][3];
			assign LLR_sum[m][4] = forward_sum[m][4] + backward_metrics[extend_size-m-1][2];
			assign LLR_sum[m][5] = forward_sum[m][1] + backward_metrics[extend_size-m-1][0];
			assign LLR_sum[m][6] = forward_sum[m][6] + backward_metrics[extend_size-m-1][3];
			assign LLR_sum[m][7] = forward_sum[m][3] + backward_metrics[extend_size-m-1][1];

			assign LLR_result[m] = max_positive[m] + max_negative_neg[m];
		end
	endgenerate

	always @(*) begin
		for(k=0;k<extend_size;k=k+1) begin
			max_negative[k] = {data_size{1'b0}};
			max_positive[k] = {data_size{1'b0}};
			sys_nxt[k] = 0;
			enc_nxt[k] = 0;
			ext_nxt[k] = 0;
			branch_metrics_nxt[k][0] = branch_metrics[k][0];
			branch_metrics_nxt[k][1] = branch_metrics[k][1];
			branch_metrics_nxt[k][2] = branch_metrics[k][2];
			branch_metrics_nxt[k][3] = branch_metrics[k][3];
			forward_metrics[k+1][0] = forward_metrics_prev[k+1][0];
			forward_metrics[k+1][1] = forward_metrics_prev[k+1][1];
			forward_metrics[k+1][2] = forward_metrics_prev[k+1][2];
			forward_metrics[k+1][3] = forward_metrics_prev[k+1][3];
			backward_metrics[k+1][0] = backward_metrics_prev[k+1][0];
			backward_metrics[k+1][1] = backward_metrics_prev[k+1][1];
			backward_metrics[k+1][2] = backward_metrics_prev[k+1][2];
			backward_metrics[k+1][3] = backward_metrics_prev[k+1][3];
			LLR_nxt[k] = LLR[k];
		end
		forward_metrics[0][0] = 0;
		forward_metrics[0][1] = neg_inf;
		forward_metrics[0][2] = neg_inf;
		forward_metrics[0][3] = neg_inf;
		backward_metrics[0][0] = 0;
		backward_metrics[0][1] = neg_inf;
		backward_metrics[0][2] = neg_inf;
		backward_metrics[0][3] = neg_inf;
		done_nxt = 0;
		state_nxt = 3'b0;

		case(state)
			READ_DATA: begin
				if(read_en_i == 1) begin
					sys_nxt[6] = sys_i[3:0];
					sys_nxt[5] = sys_i[7:4];
					sys_nxt[4] = sys_i[11:8];
					sys_nxt[3] = sys_i[15:12];
					sys_nxt[2] = sys_i[19:16];
					sys_nxt[1] = sys_i[23:20];
					sys_nxt[0] = sys_i[27:24];

					enc_nxt[6] = enc_i[3:0];
					enc_nxt[5] = enc_i[7:4];
					enc_nxt[4] = enc_i[11:8];
					enc_nxt[3] = enc_i[15:12];
					enc_nxt[2] = enc_i[19:16];
					enc_nxt[1] = enc_i[23:20];
					enc_nxt[0] = enc_i[27:24];

					ext_nxt[6] = ext_i[LLR_size-1 - 6*data_size -: data_size];
					ext_nxt[5] = ext_i[LLR_size-1 - 5*data_size -: data_size];
					ext_nxt[4] = ext_i[LLR_size-1 - 4*data_size -: data_size];
					ext_nxt[3] = ext_i[LLR_size-1 - 3*data_size -: data_size];
					ext_nxt[2] = ext_i[LLR_size-1 - 2*data_size -: data_size];
					ext_nxt[1] = ext_i[LLR_size-1 - data_size -: data_size];
					ext_nxt[0] = ext_i[LLR_size-1 -: data_size];
					
					state_nxt = BRANCH;
				end
				else begin
					state_nxt = READ_DATA;
				end
			end
			BRANCH: begin
				for(k=0;k<extend_size;k=k+1) begin
					branch_metrics_nxt[k][0] = -sys[k] - enc[k] - ext[k]; //0 + 0 + 0;
					branch_metrics_nxt[k][1] =  sys[k] + enc[k] + ext[k]; //1 + 1 + 1;
					branch_metrics_nxt[k][2] =  sys[k] - enc[k] + ext[k]; //1 + 0 + 1;
					branch_metrics_nxt[k][3] = -sys[k] + enc[k] - ext[k]; //0 + 1 + 0;
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
					negative[k][0] = LLR_sum[k][0];
					negative[k][1] = LLR_sum[k][1];
					negative[k][2] = LLR_sum[k][2];
					negative[k][3] = LLR_sum[k][3];
					positive[k][0] = LLR_sum[k][4];
					positive[k][1] = LLR_sum[k][5];
					positive[k][2] = LLR_sum[k][6];
					positive[k][3] = LLR_sum[k][7];
					temp_positive_1[k] = (positive[k][0]>positive[k][1]) ? positive[k][0] : positive[k][1];
					temp_positive_2[k] = (positive[k][2]>positive[k][3]) ? positive[k][2] : positive[k][3];
					max_positive[k] = (temp_positive_1[k]>temp_positive_2[k]) ? temp_positive_1[k] : temp_positive_2[k];
					temp_negative_1[k] = (negative[k][0]>negative[k][1]) ? negative[k][0] : negative[k][1];
					temp_negative_2[k] = (negative[k][2]>negative[k][3]) ? negative[k][2] : negative[k][3];
					max_negative[k] = (temp_negative_1[k]>temp_negative_2[k]) ? temp_negative_1[k] : temp_negative_2[k];
					//LLR[k] = max_positive - max_negative;
					LLR_nxt[k] = LLR_result[k];
				end
				state_nxt = READ_DATA;
				done_nxt  = 1;
			end
		endcase
	end

	/* ====================Sequential Part=================== */
		always@(posedge clk_i or negedge reset_n_i)
		begin
			if (reset_n_i == 1'b0)begin  
				state <= READ_DATA;
				done  <= 0;
				for(k=0;k<extend_size;k=k+1) begin
					sys[k] <= 0;
					enc[k] <= 0;
					ext[k] <= 0;
					branch_metrics[k][0] <= 0;
					branch_metrics[k][1] <= 0;
					branch_metrics[k][2] <= 0;
					branch_metrics[k][3] <= 0;
					forward_metrics_prev[k+1][0] <= 0;
					forward_metrics_prev[k+1][1] <= 0;
					forward_metrics_prev[k+1][2] <= 0;
					forward_metrics_prev[k+1][3] <= 0;
					backward_metrics_prev[k+1][0] <= 0;
					backward_metrics_prev[k+1][1] <= 0;
					backward_metrics_prev[k+1][2] <= 0;
					backward_metrics_prev[k+1][3] <= 0;
					LLR[k] <= 0;
				end
			end
			else begin 
				state <= state_nxt;
				done  <= done_nxt;
				for(k=0;k<extend_size;k=k+1) begin
					sys[k] <= sys_nxt[k];
					enc[k] <= enc_nxt[k];
					ext[k] <= ext_nxt[k];
					branch_metrics[k][0] <= branch_metrics_nxt[k][0];
					branch_metrics[k][1] <= branch_metrics_nxt[k][1];
					branch_metrics[k][2] <= branch_metrics_nxt[k][2];
					branch_metrics[k][3] <= branch_metrics_nxt[k][3];
					forward_metrics_prev[k+1][0] <= forward_metrics[k+1][0];
					forward_metrics_prev[k+1][1] <= forward_metrics[k+1][1];
					forward_metrics_prev[k+1][2] <= forward_metrics[k+1][2];
					forward_metrics_prev[k+1][3] <= forward_metrics[k+1][3];
					backward_metrics_prev[k+1][0] <= backward_metrics[k+1][0];
					backward_metrics_prev[k+1][1] <= backward_metrics[k+1][1];
					backward_metrics_prev[k+1][2] <= backward_metrics[k+1][2];
					backward_metrics_prev[k+1][3] <= backward_metrics[k+1][3];
					LLR[k] <= LLR_nxt[k];
				end
			end
		end
	/* ====================================================== */

endmodule

