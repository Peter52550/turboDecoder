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
	parameter data_size   = 5'd10;                            // every number size = 4
	parameter input_size  = 5;                                // input size (bit length) before encoding = 5
	parameter extend_size = 7;                                // input_size + 2][adding 00 at the end
	parameter block_size  = 21;                               // 3 * (input_size + 2)
	parameter neg_inf     = {1'b1, {(data_size-1){1'b0}}};    // - 2^(data_size-1) 
	parameter READ_DATA   = 3'b000;
	parameter BRANCH      = 3'b001;
	parameter FORWARD     = 3'b010;
	parameter BACKWARD    = 3'b011;
	parameter LLR_COMPUTE = 3'b100;

	/*========================IO declaration============================ */	  
	input                       clk_i;
	input                       reset_n_i;
	input                       read_en_i;
	// input           	        data_i;       [0:block_size-1];  
	input  signed  [28-1:0]     sys_i;
	input  signed  [28-1:0]     enc_i;
	input  signed  [70-1:0]     ext_i;
	output signed  [70-1:0]     data_o;
	output                      finish;

	/* =======================REG & wire================================ */
	reg					[2:0]						state, state_nxt;
	reg                         done, done_nxt;
	assign finish = done;

	reg signed	[data_size-1:0]	branch_metrics 			[0:extend_size-1] [0:3] [0:3];  // +-128
	reg signed	[data_size-1:0]	forward_metrics 		[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	backward_metrics 		[0:extend_size  ] [0:3];
	reg signed  [3:0]	          sys                 [0:extend_size-1];
	reg signed  [3:0]	          enc                 [0:extend_size-1];
	reg signed  [data_size-1:0]	ext                 [0:extend_size-1];

	reg signed	[data_size-1:0]	LLR             		[0:extend_size-1];
	reg signed  [data_size-1:0] negative            [0:3];    
	reg signed  [data_size-1:0] positive            [0:3];  
	reg signed  [data_size-1:0] max_negative, max_positive, temp_positive_1,temp_positive_2, temp_negative_1, temp_negative_2; 
	/* ====================Combinational Part================== */

	integer k;
	genvar j;
	generate
		for(j=0;j<extend_size;j=j+1) begin
			assign data_o[j] = LLR[j]; 
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

						ext[6] = 0;//ext_i[9:0];
						ext[5] = 0;//ext_i[19:10];
						ext[4] = 0;//ext_i[29:20];
						ext[3] = 0;//ext_i[39:30];
						ext[2] = 0;//ext_i[49:40];
						ext[1] = 0;//ext_i[59:50];
						ext[0] = 0;//ext_i[69:60];
						
						state_nxt = BRANCH;
					end
			end
			BRANCH: begin
				for(k=0;k<extend_size;k=k+1) begin
					branch_metrics[k][0][0] = -sys[k] - enc[k] - ext[k]; //0 + 0 + 0;
					branch_metrics[k][0][2] =  sys[k] + enc[k] + ext[k]; //1 + 1 + 1;
					branch_metrics[k][1][0] =  sys[k] - enc[k] + ext[k]; //1 + 0 + 1;
					branch_metrics[k][1][2] = -sys[k] + enc[k] - ext[k]; //0 + 1 + 0;
					branch_metrics[k][2][1] = -sys[k] - enc[k] - ext[k]; //0 + 0 + 0;
					branch_metrics[k][2][3] =  sys[k] + enc[k] + ext[k]; //1 + 1 + 1;
					branch_metrics[k][3][1] =  sys[k] - enc[k] + ext[k]; //1 + 0 + 1;
					branch_metrics[k][3][3] = -sys[k] + enc[k] - ext[k]; //0 + 1 + 0;
				end
				state_nxt = FORWARD;
			end
			FORWARD: begin
				forward_metrics[0][0] = 0;
				forward_metrics[0][1] = neg_inf;
				forward_metrics[0][2] = neg_inf;
				forward_metrics[0][3] = neg_inf;
				for(k=1;k<=extend_size;k=k+1) begin
					forward_metrics[k][0] = (forward_metrics[k-1][0]+branch_metrics[k-1][0][0] > forward_metrics[k-1][1]+branch_metrics[k-1][1][0]) ? forward_metrics[k-1][0]+branch_metrics[k-1][0][0] : forward_metrics[k-1][1]+branch_metrics[k-1][1][0];
					forward_metrics[k][1] = (forward_metrics[k-1][2]+branch_metrics[k-1][2][1] > forward_metrics[k-1][3]+branch_metrics[k-1][3][1]) ? forward_metrics[k-1][2]+branch_metrics[k-1][2][1] : forward_metrics[k-1][3]+branch_metrics[k-1][3][1];
					forward_metrics[k][2] = (forward_metrics[k-1][0]+branch_metrics[k-1][0][2] > forward_metrics[k-1][1]+branch_metrics[k-1][1][2]) ? forward_metrics[k-1][0]+branch_metrics[k-1][0][2] : forward_metrics[k-1][1]+branch_metrics[k-1][1][2];
					forward_metrics[k][3] = (forward_metrics[k-1][2]+branch_metrics[k-1][2][3] > forward_metrics[k-1][3]+branch_metrics[k-1][3][3]) ? forward_metrics[k-1][2]+branch_metrics[k-1][2][3] : forward_metrics[k-1][3]+branch_metrics[k-1][3][3];
				end
				state_nxt = BACKWARD;
			end
			BACKWARD: begin
				backward_metrics[0][0] = 0;            //backward_metrics[extend_size][0] = 0;
				backward_metrics[0][1] = neg_inf;      //backward_metrics[extend_size][1] = neg_inf;
				backward_metrics[0][2] = neg_inf;      //backward_metrics[extend_size][2] = neg_inf;
				backward_metrics[0][3] = neg_inf;      //backward_metrics[extend_size][3] = neg_inf;
				for(k=1;k<=extend_size;k=k+1) begin    //for(k=extend_size-1;k>=0;k=k-1) begin
					backward_metrics[k][0] = (backward_metrics[k-1][0]+branch_metrics[extend_size-k][0][0] > backward_metrics[k-1][2]+branch_metrics[extend_size-k][0][2]) ? backward_metrics[k-1][0]+branch_metrics[extend_size-k][0][0] : backward_metrics[k-1][2]+branch_metrics[extend_size-k][0][2];//backward_metrics[k][0] = (backward_metrics[k+1][0]+branch_metrics[k][0][0] > backward_metrics[k+1][2]+branch_metrics[k][0][2]) ? backward_metrics[k+1][0]+branch_metrics[k][0][0] : backward_metrics[k+1][2]+branch_metrics[k][0][2];
					backward_metrics[k][1] = (backward_metrics[k-1][0]+branch_metrics[extend_size-k][1][0] > backward_metrics[k-1][2]+branch_metrics[extend_size-k][1][2]) ? backward_metrics[k-1][0]+branch_metrics[extend_size-k][1][0] : backward_metrics[k-1][2]+branch_metrics[extend_size-k][1][2];//backward_metrics[k][1] = (backward_metrics[k+1][0]+branch_metrics[k][1][0] > backward_metrics[k+1][2]+branch_metrics[k][1][2]) ? backward_metrics[k+1][0]+branch_metrics[k][1][0] : backward_metrics[k+1][2]+branch_metrics[k][1][2];
					backward_metrics[k][2] = (backward_metrics[k-1][1]+branch_metrics[extend_size-k][2][1] > backward_metrics[k-1][3]+branch_metrics[extend_size-k][2][3]) ? backward_metrics[k-1][1]+branch_metrics[extend_size-k][2][1] : backward_metrics[k-1][3]+branch_metrics[extend_size-k][2][3];//backward_metrics[k][2] = (backward_metrics[k+1][1]+branch_metrics[k][2][1] > backward_metrics[k+1][3]+branch_metrics[k][2][3]) ? backward_metrics[k+1][1]+branch_metrics[k][2][1] : backward_metrics[k+1][3]+branch_metrics[k][2][3];
					backward_metrics[k][3] = (backward_metrics[k-1][1]+branch_metrics[extend_size-k][3][1] > backward_metrics[k-1][3]+branch_metrics[extend_size-k][3][3]) ? backward_metrics[k-1][1]+branch_metrics[extend_size-k][3][1] : backward_metrics[k-1][3]+branch_metrics[extend_size-k][3][3];//backward_metrics[k][3] = (backward_metrics[k+1][1]+branch_metrics[k][3][1] > backward_metrics[k+1][3]+branch_metrics[k][3][3]) ? backward_metrics[k+1][1]+branch_metrics[k][3][1] : backward_metrics[k+1][3]+branch_metrics[k][3][3];
				end
				state_nxt = LLR_COMPUTE;
			end
			LLR_COMPUTE: begin
				for(k=0;k<extend_size;k=k+1) begin
					negative[1] = forward_metrics[k][0] + branch_metrics[k][0][0] + backward_metrics[extend_size-k-1][0];
					negative[2] = forward_metrics[k][1] + branch_metrics[k][1][2] + backward_metrics[extend_size-k-1][2];
					negative[3] = forward_metrics[k][2] + branch_metrics[k][2][1] + backward_metrics[extend_size-k-1][1];
					negative[0] = forward_metrics[k][3] + branch_metrics[k][3][3] + backward_metrics[extend_size-k-1][3];
					positive[1] = forward_metrics[k][0] + branch_metrics[k][0][2] + backward_metrics[extend_size-k-1][2];
					positive[2] = forward_metrics[k][1] + branch_metrics[k][1][0] + backward_metrics[extend_size-k-1][0];
					positive[3] = forward_metrics[k][2] + branch_metrics[k][2][3] + backward_metrics[extend_size-k-1][3];
					positive[0] = forward_metrics[k][3] + branch_metrics[k][3][1] + backward_metrics[extend_size-k-1][1];
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

