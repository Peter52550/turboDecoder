module Siso(
             clk_i,
             rst_n_i,
             read_en_i,
             sys_i,
             enc_i,
             ext_i,
             data_o,
             done
  );

  /*========================Parameter declaration===================== */	
  parameter data_size   = 5'd10;            // every number size = 4
  parameter input_size  = 5;                // input size (bit length) before encoding = 5
  parameter extend_size = 7;                // input_size + 2, adding 00 at the end
  parameter block_size  = 21;               // 3 * (input_size + 2)
  parameter neg_inf     = {data_size{1}};   // - 2^(data_size-1) 
  parameter READ_DATA   = 3'b000;
  parameter BRANCH      = 3'b001;
  parameter FORWARD     = 3'b010;
  parameter BACKWARD    = 3'b011;
  parameter LLR         = 3'b100;

  /*========================IO declaration============================ */	  
  input                    clk_i;
  input                    reset_n_i;
  // input           	       data_i;       [0:block_size-1];  
  input  signed  [extend_size-1:0]  sys_i;
  input  signed  [extend_size-1:0]  enc_i;
  input  signed  [extend_size-1:0]  ext_i;
  output signed  [data_size-1:0]    data_o;
  output reg                        done, done_nxt;

  integer k;
  for(k=0;k<block_size;k=k+1) begin
    assign data_o[k] = LLR[k]; 
  end

  /* =======================REG & wire================================ */
	reg					[1:0]						state, state_nxt;
	reg signed	[data_size-1:0]	branch_metrics 			[0:extend_size-1] [0:3] [0:3];  // +-128
	reg signed	[data_size-1:0]	forward_metrics 		[0:extend_size  ] [0:3];
	reg signed	[data_size-1:0]	backward_metrics 		[0:extend_size  ] [0:3];
  reg signed  [3:0]	          sys                 [0:extend_size-1];
  reg signed  [3:0]	          enc                 [0:extend_size-1];
  reg signed  [3:0]	          ext                 [0:extend_size-1];

	reg signed	[data_size-1:0]	LLR             		[0:extend_size-1];
  reg         [1:0]           read_counter;     
  reg         [1:0]           read_counter_nxt;   

  /* ====================Combinational Part================== */
	always @(*) begin
    done_nxt = 0;
		case(state)
      READ_DATA: begin
          if(read_en_i == 1) begin
            sys[6:0][read_counter] = sys_i;
            enc[6:0][read_counter] = enc_i;
            ext[6:0][read_counter] = ext_i;
            read_counter_nxt = read_counter + 1;
            if(read_counter == 4) begin
              state_nxt = BRANCH;
              read_counter_nxt = read_counter + 1;
            end
          end
          else 
            state_nxt = READ_DATA;
      end
			BRANCH: begin
				for(k=0;k<block_size;k=k+1) begin
					branch_metrics[k, 0, 0] = -enc_i[k] - sys_i[k] - ext_i[k]; //0 + 0 + 0;
					branch_metrics[k, 0, 2] =  enc_i[k] + sys_i[k] + ext_i[k]; //1 + 1 + 1;
					branch_metrics[k, 1, 0] =  enc_i[k] - sys_i[k] + ext_i[k]; //1 + 0 + 1;
					branch_metrics[k, 1, 2] = -enc_i[k] + sys_i[k] - ext_i[k]; //0 + 1 + 0;
					branch_metrics[k, 2, 1] = -enc_i[k] - sys_i[k] - ext_i[k]; //0 + 0 + 0;
					branch_metrics[k, 2, 3] =  enc_i[k] + sys_i[k] + ext_i[k]; //1 + 1 + 1;
					branch_metrics[k, 3, 1] =  enc_i[k] - sys_i[k] + ext_i[k]; //1 + 0 + 1;
					branch_metrics[k, 3, 3] = -enc_i[k] + sys_i[k] - ext_i[k]; //0 + 1 + 0;
				end
        state_nxt = FORWARD;
			end
			FORWARD: begin
        forward_metrics[0, 0] = 0;
        forward_metrics[0, 1] = neg_inf;
        forward_metrics[0, 2] = neg_inf;
        forward_metrics[0, 3] = neg_inf;
				for(k=1;k<=block_size;k=k+1) begin
					forward_metrics[k, 0] = (forward_metrics[k-1, 0]+branch_metrics[k, 0, 0] > forward_metrics[k-1, 1]+branch_metrics[k, 1, 0]) ? forward_metrics[k-1, 0]+branch_metrics[k, 0, 0] : forward_metrics[k-1, 1]+branch_metrics[k, 1, 0];
          forward_metrics[k, 1] = (forward_metrics[k-1, 2]+branch_metrics[k, 2, 1] > forward_metrics[k-1, 3]+branch_metrics[k, 3, 1]) ? forward_metrics[k-1, 2]+branch_metrics[k, 2, 1] : forward_metrics[k-1, 3]+branch_metrics[k, 3, 1];
          forward_metrics[k, 2] = (forward_metrics[k-1, 0]+branch_metrics[k, 0, 2] > forward_metrics[k-1, 1]+branch_metrics[k, 1, 2]) ? forward_metrics[k-1, 0]+branch_metrics[k, 0, 2] : forward_metrics[k-1, 1]+branch_metrics[k, 1, 2];
          forward_metrics[k, 3] = (forward_metrics[k-1, 2]+branch_metrics[k, 2, 3] > forward_metrics[k-1, 3]+branch_metrics[k, 3, 3]) ? forward_metrics[k-1, 2]+branch_metrics[k, 2, 3] : forward_metrics[k-1, 3]+branch_metrics[k, 3, 3];
				end
        state_nxt = BACKWARD;
			end
      BACKWARD: begin
        backward_metrics[block_size, 0] = 0;
        backward_metrics[block_size, 1] = neg_inf;
        backward_metrics[block_size, 2] = neg_inf;
        backward_metrics[block_size, 3] = neg_inf;
				for(k=block_size-1;k>=0;k=k-1) begin
          backward_metrics[k, 0] = (backward_metrics[k+1, 0]+branch_metrics[k, 0, 0] > backward_metrics[k+1, 2]+branch_metrics[k, 0, 2]) ? backward_metrics[k+1, 0]+branch_metrics[k, 0, 0] : backward_metrics[k+1, 2]+branch_metrics[k, 0, 2];
					backward_metrics[k, 1] = (backward_metrics[k+1, 0]+branch_metrics[k, 1, 0] > backward_metrics[k+1, 2]+branch_metrics[k, 1, 2]) ? backward_metrics[k+1, 0]+branch_metrics[k, 1, 0] : backward_metrics[k+1, 2]+branch_metrics[k, 1, 2];
          backward_metrics[k, 2] = (backward_metrics[k+1, 1]+branch_metrics[k, 2, 1] > backward_metrics[k+1, 3]+branch_metrics[k, 2, 3]) ? backward_metrics[k+1, 1]+branch_metrics[k, 2, 1] : backward_metrics[k+1, 3]+branch_metrics[k, 2, 3];
          backward_metrics[k, 3] = (backward_metrics[k+1, 1]+branch_metrics[k, 3, 1] > backward_metrics[k+1, 3]+branch_metrics[k, 3, 3]) ? backward_metrics[k+1, 1]+branch_metrics[k, 3, 1] : backward_metrics[k+1, 3]+branch_metrics[k, 3, 3];
				end
        state_nxt = LLR;
			end
      LLR: begin
				for(k=1;k<block_size;k=k+1) begin
          negative[1] = forward_metrics[k-1, 0] + branch_metrics[k, 0, 0] + backward_metrics[k, 0];
          negative[2] = forward_metrics[k-1, 1] + branch_metrics[k, 1, 2] + backward_metrics[k, 2];
          negative[3] = forward_metrics[k-1, 2] + branch_metrics[k, 2, 1] + backward_metrics[k, 1];
          negative[4] = forward_metrics[k-1, 3] + branch_metrics[k, 3, 3] + backward_metrics[k, 3];
          positive[1] = forward_metrics[k-1, 0] + branch_metrics[k, 0, 2] + backward_metrics[k, 2];
          positive[2] = forward_metrics[k-1, 1] + branch_metrics[k, 1, 0] + backward_metrics[k, 0];
          positive[3] = forward_metrics[k-1, 2] + branch_metrics[k, 2, 3] + backward_metrics[k, 3];
          positive[4] = forward_metrics[k-1, 3] + branch_metrics[k, 3, 1] + backward_metrics[k, 1];
          temp_positive_1 = (positive[1]>positive[2]) ? positive[1] : positive[2];
          temp_positive_2 = (positive[3]>positive[4]) ? positive[3] : positive[4];
          max_positive = (temp_positive_1>temp_positive_2) ? temp_positive_1 : temp_positive_2;
          temp_negative_1 = (negative[1]>negative[2]) ? negative[1] : negative[2];
          temp_negative_2 = (negative[3]>negative[4]) ? negative[3] : negative[4];
          max_negative = (temp_negative_1>temp_negative_2) ? temp_negative_1 : temp_negative_2;
          LLR[k] = max_positive - max_negative;
        end
        state_nxt = BRANCH;
        done_nxt  = 1;
			end
		endcase
  end

  /* ====================Sequential Part=================== */
    always@(posedge clk_i or negedge reset_n_i)
    begin
        if (reset_n_i == 1'b0)
            begin  
              state <= BRANCH;
              done  <= 0;
              read_counter <= 0;
            end
        else
            begin 
              state <= state_nxt;
              done  <= done_nxt;
              read_counter <= read_counter_nxt;
            end
    end
  /* ====================================================== */

endmodule

