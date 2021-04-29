module siso(
             clk_p_i,
             reset_n_i,
             data_i,
             data_o
             );

  /*========================IO declaration============================ */	  
      input           clk_p_i;
      input           reset_n_i;
      input   signed  [input_size-1:0]  enc_i;
      input   signed  [input_size-1:0]  sys_i;
      input   signed  [input_size-1:0]  ext_i;
      output  [15:0]  data_o;

  parameter data_size = 11;
  parameter input_size = 7;
  parameter block_size = 21;
  /* =======================REG & wire================================ */
      reg [1:0]   state, state_nxt;
      reg         in, out;
      reg signed [data_size-1:0]  branch_metrics [0:block_size-1] [0:3] [0:3];
      reg signed [data_size-1:0]  forward_metrics [0:block_size-1] [0:3];
      reg signed [data_size-1:0]  backward_metrics [0:block_size-1] [0:3];
      reg signed [data_size-1:0]  LLR             [0:block_size-1];
      reg [1:0]            past1, past2, next1, next2;
      reg [1:0]            current;
  /* ====================Combinational Part================== */
  //next-state logic //todo
      assign next1 = {0, current[1]};
      assign next2 = {1, current[1]};
      assign past1 = {current[0], 0};
      assign past2 = {current[0], 1};
  integer i;
  always @(*) begin
    COMPUTE_BRANCH:begin
      for(k=0;k<block_size;k=k+1) begin
        branch_metrics[k, 0, 0] = -enc_i[k] - sys_i[k] - ext_i[k]; //0 + 0 + 0;
        branch_metrics[k, 0, 2] = enc_i[k] + sys_i[k] + ext_i[k]; //1 + 1 + 1;
        branch_metrics[k, 1, 0] = enc_i[k] - sys_i[k] + ext_i[k]; //1 + 0 + 1;
        branch_metrics[k, 1, 2] = -enc_i[k] + sys_i[k] - ext_i[k]; //0 + 1 + 0;
        branch_metrics[k, 2, 1] = -enc_i[k] - sys_i[k] - ext_i[k]; //0 + 0 + 0;
        branch_metrics[k, 2, 3] = enc_i[k] + sys_i[k] + ext_i[k]; //1 + 1 + 1;
        branch_metrics[k, 3, 1] = enc_i[k] - sys_i[k] + ext_i[k]; //1 + 0 + 1;
        branch_metrics[k, 3, 3] = -enc_i[k] + sys_i[k] - ext_i[k]; //0 + 1 + 0;

      end
    end

  end
  // task prune(
  //   input   [1:0] m,
  //   input   [1:0] n,
  //   output  [1:0] i,
  //   output  [1:0] o
  // );
    
  // endtask


          
			  
  // output logic


  // state transition
    always@ (*)
      begin
          case(state_r)
              2'd0:
                if(!in) begin
                  out = 1'd0;
                  state_nxt = 2'b0;
                  branch_metrics
                end
                else begin
                  out = 1'd1;
                  state_nxt = 2'd2;
                end
              2'd1:
                if(!in) begin
                  out = 1'd1;
                  state_nxt = 2'd2;
                end
                else begin
                  out = 1'd0;
                  state_nxt = 2'd0;
                end
              2'd2:
                if(!in) begin
                  out = 1'd0;
                  state_nxt = 2'd1;
                end
                else begin
                  out = 1'd1;
                  state_nxt = 2'd3;
                end
              2'd3:
                if(!in) begin
                  out = 1'd1;
                  state_nxt = 2'd3;
                end
                else begin
                  out = 1'd0;
                  state_nxt = 2'd1;
                end
           default:
        
          endcase
      end
      always@ (*)
      begin
          case(state_r)
              2'd0:
                if(!in) begin
                  out = 1'd0;
                  state_nxt = 2'b0;
                  branch_metrics
                end
                else begin
                  out = 1'd1;
                  state_nxt = 2'd2;
                end
              2'd1:
                if(!in) begin
                  out = 1'd1;
                  state_nxt = 2'd2;
                end
                else begin
                  out = 1'd0;
                  state_nxt = 2'd0;
                end
              2'd2:
                if(!in) begin
                  out = 1'd0;
                  state_nxt = 2'd1;
                end
                else begin
                  out = 1'd1;
                  state_nxt = 2'd3;
                end
              2'd3:
                if(!in) begin
                  out = 1'd1;
                  state_nxt = 2'd3;
                end
                else begin
                  out = 1'd0;
                  state_nxt = 2'd1;
                end
           default:
        
          endcase
      end
   			  //todo
  /* ====================Sequential Part=================== */
    always@(posedge clk_p_i or negedge reset_n_i)
    begin
        if (reset_n_i == 1'b0)
            begin  
                
            end
        else
            begin 

            end
    end
  /* ====================================================== */

endmodule

