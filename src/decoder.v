module Decoder(
             clk_p_i,
             reset_n_i,
             data_i,
             data_o,
             i_start,
             );

  /*========================IO declaration============================ */	 
      parameter MAX_ITER = 16;
      parameter data_size = 5;
      parameter input_size = 28;
      parameter S_START           = 3'd0;
      parameter S_DEC1            = 3'd1;
      parameter S_DEC1_FINISH     = 3'd2;
      parameter S_DEC2            = 3'd3;
      parameter S_DEC2_FINISH     = 3'd4;
      parameter S_ITER_FINISH     = 3'd5;

      input                       clk_p_i;
      input                       reset_n_i;
      input   [83:0]              data_i;
      output  [data_size-1:0]     data_o;

  /* =======================REG & wire================================ */
      wire    [input_size-1:0]    enc_w;
      reg     [input_size-1:0]    enc_r;
      wire    [input_size-1:0]    sys_w;
      reg     [input_size-1:0]    sys_r;
      wire    [input_size-1:0]    ext_w;
      reg     [input_size-1:0]    ext_r;

      reg     [3:0]       state_r;
      reg     [3:0]       state_w;
	  
      reg                dec_finish_w;
      reg                dec_finish_r;
      reg                iter_finish_w;
      reg                iter_finish_r;
      reg                begin_w;
      reg                begin_r;
      reg [5:0]          counter_w;
      reg [5:0]          counter_r;
      
    Siso siso(
      .clki_(i_clk),
      .rsti_(i_rst),
      .read_en_i(begin_r),
      .done(dec_finish_r),
    );

  /* ====================Combinational Part================== */
  //next-state logic //todo
    assign enc_w = ;
    assign sys_w = ;
    assign ext_w = ;
    
  

  // state transition
    always@ (*)
      state_w         = state_r;
      enc_w           = enc_r;
      sys_w           = sys_r;
      ext_w           = ext_r;
      begin_w         = begin_r;
      dec_finish_w    = dec_finish_r;
      iter_finish_w   = iter_finish_r;
      counter_w       = counter_r;

      begin
          case(state_r)
              S_IDLE: begin
                if(i_begin == 1) begin
                  begin_w     = 1'd1;
                  state_w     = S_DEC1;
                  counter_w   = 6'd0;
                end
              end 
              S_DEC1: begin
                begin_w = 1'd0;
                if(dec_finish_r == 1)
                  state_w     = S_DEC1_FINISH;
                  counter_w   = counter_r += 6'd1;
              end 
              S_DEC1_FINISH: begin
                state_w       = S_DEC2;
                begin_w       = 1'd1;
                counter_w     = counter_r;
                state_w       = S_DEC2;
                counter_w     = counter_r;
              end 
              S_DEC2: begin
                begin_w = 1'd0;
                if(dec_finish_r == 1)
                  state_w     = S_DEC2_FINISH;
                  counter_w   = counter_r += 6'd1;
              end 
              S_DEC2_FINISH: begin
                if(counter_r == 6'd32) begin
                  begin_w     = 1'd0;
                  state_w     = S_ITER_FINISH;
                end
                else begin
                  begin_w     = 1'd1;
                  state_w     = S_DEC1;
                end
              end 
              S_ITER_FINISH: begin
                state_w       = S_IDLE;
                counter_w     = 6'd0;
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
                state_r         <= S_IDLE;
                enc_r           <= 71'b0;
                ext_r           <= 71'b0;
                sys_r           <= 71'b0;
                begin_r         <= 1'd0;
                dec_finish_r    <= 1'd0;
                iter_finish_r   <= 1'd0;
                counter_r       <= 6'd0;
                data_r          <= data_i;
            end
        else
            begin 
                state_r         <= state_w;
                enc_r           <= enc_w;
                ext_r           <= ext_w;
                sys_r           <= sys_w;
                begin_r         <= begin_w;
                dec_finish_r    <= dec_finish_w;
                iter_finish_r   <= iter_finish_w;
                counter_r       <= counter_w;
                data_r          <= data_i;
            end
    end
  /* ====================================================== */

endmodule