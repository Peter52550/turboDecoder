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
	input  signed [28-1:0]		sys_i;
	input  signed [28-1:0]		enc_i;
	input  signed [LLR_size-1:0]	ext_i;
	output signed [LLR_size-1:0]	data_o;
	output                      finish;

	/* =======================REG & wire================================ */
	reg					[2:0]	state, state_nxt;
	reg                         done, done_nxt;
	assign finish = done;

	reg signed  [3:0]	        sys                 	[0:extend_size-1];
	reg signed  [3:0]	        sys_nxt                 [0:extend_size-1];
	reg signed  [3:0]	        enc                 	[0:extend_size-1];
	reg signed  [3:0]	        enc_nxt             	[0:extend_size-1];
	reg signed  [data_size-1:0]	ext                 	[0:extend_size-1];
	reg signed  [data_size-1:0]	ext_nxt             	[0:extend_size-1];

	reg signed	[data_size-1:0]	branch_metrics 			[0:extend_size-1] [0:3];  // +-128
	reg signed	[data_size-1:0]	branch_metrics_nxt		[0:extend_size-1] [0:3];  // +-128
	reg signed	[data_size-1:0]	forward_metrics 		[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	forward_metrics_nxt 	[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	backward_metrics 		[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	backward_metrics_nxt	[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	LLR             		[0:extend_size-1];
	reg signed	[data_size-1:0]	LLR_nxt             	[0:extend_size-1];
	wire signed	[data_size-1:0]	branch_sum				[0:extend_size-1] [0:3];
	wire signed	[data_size-1:0]	forward_sum				[0:extend_size-1] [0:7];
	wire signed	[data_size-1:0]	backward_sum			[0:extend_size-1] [0:7];
	wire signed	[data_size-1:0]	LLR_sum					[0:extend_size-1] [0:7];

	reg signed  [data_size-1:0] negative            [0:3];    
	reg signed  [data_size-1:0] positive            [0:3];  
	reg signed  [data_size-1:0] max_negative		;
	reg signed  [data_size-1:0] max_negative_neg	;
	reg signed  [data_size-1:0] max_positive		;
	reg signed  [data_size-1:0] temp_positive_1		;
	reg signed  [data_size-1:0] temp_positive_2		;
	reg signed  [data_size-1:0] temp_negative_1		;
	reg signed  [data_size-1:0] temp_negative_2		;

	reg [3:0] count, count_nxt;

	integer i, k, n; 
	/* ====================Combinational Part================== */

	assign data_o = {LLR[0], LLR[1], LLR[2], LLR[3], LLR[4], LLR[5], LLR[6]};

	genvar m;
	generate
		for(m=0;m<extend_size;m=m+1) begin
			assign forward_sum[m][0] = forward_metrics[m][0] + branch_metrics[m][0];
			assign forward_sum[m][1] = forward_metrics[m][1] + branch_metrics[m][2];
			assign forward_sum[m][2] = forward_metrics[m][2] + branch_metrics[m][0];
			assign forward_sum[m][3] = forward_metrics[m][3] + branch_metrics[m][2];
			assign forward_sum[m][4] = forward_metrics[m][0] + branch_metrics[m][1];
			assign forward_sum[m][5] = forward_metrics[m][1] + branch_metrics[m][3];
			assign forward_sum[m][6] = forward_metrics[m][2] + branch_metrics[m][1];
			assign forward_sum[m][7] = forward_metrics[m][3] + branch_metrics[m][3];
			
			assign backward_sum[m][0] = backward_metrics[m][0] + branch_metrics[extend_size-m-1][0];
			assign backward_sum[m][1] = backward_metrics[m][2] + branch_metrics[extend_size-m-1][1];
			assign backward_sum[m][2] = backward_metrics[m][0] + branch_metrics[extend_size-m-1][2];
			assign backward_sum[m][3] = backward_metrics[m][2] + branch_metrics[extend_size-m-1][3];
			assign backward_sum[m][4] = backward_metrics[m][1] + branch_metrics[extend_size-m-1][0];
			assign backward_sum[m][5] = backward_metrics[m][3] + branch_metrics[extend_size-m-1][1];
			assign backward_sum[m][6] = backward_metrics[m][1] + branch_metrics[extend_size-m-1][2];
			assign backward_sum[m][7] = backward_metrics[m][3] + branch_metrics[extend_size-m-1][3];

			assign LLR_sum[m][0] = forward_sum[m][0] + backward_metrics[extend_size-m-1][0];
			assign LLR_sum[m][1] = forward_sum[m][5] + backward_metrics[extend_size-m-1][2];
			assign LLR_sum[m][2] = forward_sum[m][2] + backward_metrics[extend_size-m-1][1];
			assign LLR_sum[m][3] = forward_sum[m][7] + backward_metrics[extend_size-m-1][3];
			assign LLR_sum[m][4] = forward_sum[m][4] + backward_metrics[extend_size-m-1][2];
			assign LLR_sum[m][5] = forward_sum[m][1] + backward_metrics[extend_size-m-1][0];
			assign LLR_sum[m][6] = forward_sum[m][6] + backward_metrics[extend_size-m-1][3];
			assign LLR_sum[m][7] = forward_sum[m][3] + backward_metrics[extend_size-m-1][1];
		end
	endgenerate

	always @(*) begin
		for(k=0;k<extend_size;k=k+1) begin
			sys_nxt[k] = sys[k];
			enc_nxt[k] = enc[k];
			ext_nxt[k] = ext[k];
			branch_metrics_nxt[k][0] = branch_metrics[k][0];
			branch_metrics_nxt[k][1] = branch_metrics[k][1];
			branch_metrics_nxt[k][2] = branch_metrics[k][2];
			branch_metrics_nxt[k][3] = branch_metrics[k][3];
			forward_metrics_nxt[k+1][0] = forward_metrics[k+1][0];
			forward_metrics_nxt[k+1][1] = forward_metrics[k+1][1];
			forward_metrics_nxt[k+1][2] = forward_metrics[k+1][2];
			forward_metrics_nxt[k+1][3] = forward_metrics[k+1][3];
			backward_metrics_nxt[k+1][0] = backward_metrics[k+1][0];
			backward_metrics_nxt[k+1][1] = backward_metrics[k+1][1];
			backward_metrics_nxt[k+1][2] = backward_metrics[k+1][2];
			backward_metrics_nxt[k+1][3] = backward_metrics[k+1][3];
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
		count_nxt = count;
		state_nxt = state;

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
				if (count < extend_size) begin
					branch_metrics_nxt[count][0] = -sys[count] - enc[count] - ext[count]; //0 + 0 + 0;
					branch_metrics_nxt[count][1] =  sys[count] + enc[count] + ext[count]; //1 + 1 + 1;
					branch_metrics_nxt[count][2] =  sys[count] - enc[count] + ext[count]; //1 + 0 + 1;
					branch_metrics_nxt[count][3] = -sys[count] + enc[count] - ext[count]; //0 + 1 + 0;
					count_nxt = count + 1;
				end
				else begin
					state_nxt = FORWARD;
					count_nxt = 0;
				end
			end
			FORWARD: begin
				count_nxt = count + 1;
				if (count < extend_size) begin
					forward_metrics_nxt[count_nxt][0] = (forward_sum[count][0] > forward_sum[count][1]) ? forward_sum[count][0] : forward_sum[count][1];
					forward_metrics_nxt[count_nxt][1] = (forward_sum[count][2] > forward_sum[count][3]) ? forward_sum[count][2] : forward_sum[count][3];
					forward_metrics_nxt[count_nxt][2] = (forward_sum[count][4] > forward_sum[count][5]) ? forward_sum[count][4] : forward_sum[count][5];
					forward_metrics_nxt[count_nxt][3] = (forward_sum[count][6] > forward_sum[count][7]) ? forward_sum[count][6] : forward_sum[count][7];
				end
				else begin
					state_nxt = BACKWARD;
					count_nxt = 0;
				end
			end
			BACKWARD: begin
				count_nxt = count + 1;
				if (count < extend_size) begin    //for(k=extend_size-1;k>=0;k=k-1) begin
					backward_metrics_nxt[count_nxt][0] = (backward_sum[count][0] > backward_sum[count][1]) ? backward_sum[count][0] : backward_sum[count][1];
					backward_metrics_nxt[count_nxt][1] = (backward_sum[count][2] > backward_sum[count][3]) ? backward_sum[count][2] : backward_sum[count][3];
					backward_metrics_nxt[count_nxt][2] = (backward_sum[count][4] > backward_sum[count][5]) ? backward_sum[count][4] : backward_sum[count][5];
					backward_metrics_nxt[count_nxt][3] = (backward_sum[count][6] > backward_sum[count][7]) ? backward_sum[count][6] : backward_sum[count][7];
				end
				else begin
					state_nxt = LLR_COMPUTE;
					count_nxt = 0;
				end
			end
			LLR_COMPUTE: begin
				if (count < extend_size) begin
					negative[0] = LLR_sum[count][0];
					negative[1] = LLR_sum[count][1];
					negative[2] = LLR_sum[count][2];
					negative[3] = LLR_sum[count][3];
					positive[0] = LLR_sum[count][4];
					positive[1] = LLR_sum[count][5];
					positive[2] = LLR_sum[count][6];
					positive[3] = LLR_sum[count][7];
					temp_positive_1 = (positive[0]>positive[1]) ? positive[0] : positive[1];
					temp_positive_2 = (positive[2]>positive[3]) ? positive[2] : positive[3];
					max_positive = (temp_positive_1>temp_positive_2) ? temp_positive_1 : temp_positive_2;
					temp_negative_1 = (negative[0]>negative[1]) ? negative[0] : negative[1];
					temp_negative_2 = (negative[2]>negative[3]) ? negative[2] : negative[3];
					max_negative = (temp_negative_1>temp_negative_2) ? temp_negative_1 : temp_negative_2;
					//LLR[k] = max_positive - max_negative;
					LLR_nxt[count] = max_positive - max_negative;
					count_nxt = count + 1;
				end
				else begin
					state_nxt = READ_DATA;
					count_nxt = 0;
					done_nxt  = 1;
				end
			end
		endcase
	end

	/* ====================Sequential Part=================== */
		always@(posedge clk_i or negedge reset_n_i)
		begin
			if (reset_n_i == 1'b0)begin  
				state <= READ_DATA;
				done  <= 0;
				count <= 0;
				for(k=0;k<extend_size;k=k+1) begin
					sys[k] <= 0;
					enc[k] <= 0;
					ext[k] <= 0;
					branch_metrics[k][0] <= 0;
					branch_metrics[k][1] <= 0;
					branch_metrics[k][2] <= 0;
					branch_metrics[k][3] <= 0;
					forward_metrics[k+1][0] <= 0;
					forward_metrics[k+1][1] <= 0;
					forward_metrics[k+1][2] <= 0;
					forward_metrics[k+1][3] <= 0;
					backward_metrics[k+1][0] <= 0;
					backward_metrics[k+1][1] <= 0;
					backward_metrics[k+1][2] <= 0;
					backward_metrics[k+1][3] <= 0;
					LLR[k] <= 0;
				end
			end
			else begin 
				state <= state_nxt;
				done  <= done_nxt;
				count <= count_nxt;
				for(k=0;k<extend_size;k=k+1) begin
					sys[k] <= sys_nxt[k];
					enc[k] <= enc_nxt[k];
					ext[k] <= ext_nxt[k];
					branch_metrics[k][0] <= branch_metrics_nxt[k][0];
					branch_metrics[k][1] <= branch_metrics_nxt[k][1];
					branch_metrics[k][2] <= branch_metrics_nxt[k][2];
					branch_metrics[k][3] <= branch_metrics_nxt[k][3];
					forward_metrics[k+1][0] <= forward_metrics_nxt[k+1][0];
					forward_metrics[k+1][1] <= forward_metrics_nxt[k+1][1];
					forward_metrics[k+1][2] <= forward_metrics_nxt[k+1][2];
					forward_metrics[k+1][3] <= forward_metrics_nxt[k+1][3];
					backward_metrics[k+1][0] <= backward_metrics_nxt[k+1][0];
					backward_metrics[k+1][1] <= backward_metrics_nxt[k+1][1];
					backward_metrics[k+1][2] <= backward_metrics_nxt[k+1][2];
					backward_metrics[k+1][3] <= backward_metrics_nxt[k+1][3];
					LLR[k] <= LLR_nxt[k];
				end
			end
		end
	/* ====================================================== */

endmodule

