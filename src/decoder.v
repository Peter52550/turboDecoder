module Decoder(
             clk_p_i,
             reset_n_i,
             data_i,
             data_o,
             start_i,
             );

  /*========================IO declaration============================ */	 
      // parameter MAX_ITER = 16;
      parameter data_size = 5'd10;
      parameter input_size = 5;
      parameter extend_size = 7;                // input_size + 2, adding 00 at the end
      parameter block_size  = 21;               // 3 * (input_size + 2)
      parameter S_READ            = 3'd0;
      parameter S_DEC1            = 3'd1;
      parameter S_DEC1_FINISH     = 3'd2;
      parameter S_DEC2            = 3'd3;
      parameter S_DEC2_FINISH     = 3'd4;
      parameter S_ITER_FINISH     = 3'd5;

      input                       clk_p_i;
      input                       reset_n_i;
      input   [block_size-1:0]    data_i;
      output  [input_size-1:0]    data_o;

  /* =======================REG & wire================================ */
      reg     [3:0]               vec0         [0:extend_size-1];
      reg     [3:0]               vec1         [0:extend_size-1];
      reg     [3:0]               vec2         [0:extend_size-1];
      reg     [3:0]               vec0_ITL     [0:extend_size-1];   // interleaved
      reg                         vec0_nxt     [0:extend_size-1];
      reg                         vec1_nxt     [0:extend_size-1];
      reg                         vec2_nxt     [0:extend_size-1];

      wire    [27:0]              vec0_i     = { vec0[6][3:0], vec0[5][3:0], vec0[4][3:0], vec0[3][3:0], vec0[2][3:0], vec0[1][3:0], vec0[0][3:0] };
      wire    [27:0]              vec1_i     = { vec1[6][3:0], vec1[5][3:0], vec1[4][3:0], vec1[3][3:0], vec1[2][3:0], vec1[1][3:0], vec1[0][3:0] };
      wire    [27:0]              vec0_ITL_i = { vec0_ITL[6][3:0], vec0_ITL[5][3:0], vec0_ITL[4][3:0], vec0_ITL[3][3:0], 
                                                 vec0_ITL[2][3:0], vec0_ITL[1][3:0], vec0_ITL[0][3:0] };
      reg     [27:0]              sys_i    ;                        // 1st input for siso
      reg     [27:0]              enc_i    ;                        // 2nd input for siso
      reg     [4*data_size-1:0]   ext_i    ;                        // 3rd input for siso
      reg     [27:0]              sys_i_nxt;                        // 1st input for siso
      reg     [27:0]              enc_i_nxt;                        // 2nd input for siso
      reg     [4*data_size-1:0]   ext_i_nxt;                        // 3rd input for siso

      reg     [data_size-1:0]     siso_o       [0:extend_size-1];   // output for siso
      // reg     [3:0]               sys_r  [0:extend_size-1];
      // reg     [3:0]               enc_r  [0:extend_size-1];
      // reg     [3:0]               ext_r  [0:extend_size-1];

      reg     [3:0]               state;
      reg     [3:0]               state_nxt;
      reg     [1:0]               read_counter;     
      reg     [1:0]               read_counter_nxt; 
      reg     [5:0]               iter_counter;
      reg     [5:0]               iter_counter_nxt;
      // reg                         dec_finish_w;
      // reg                         dec_finish_r;
      // reg                         iter_finish_w;
      // reg                         iter_finish_r;
      // reg                         begin_w;
      // reg                         begin_r;
      
    Siso siso(
      .clk_i(clk_p_i),
      .rst_n_i(reset_n_i),
      .read_en_i(begin_r),
      .sys_i(sys_i),
      .enc_i(enc_i),
      .ext_i(ext_i),
      .data_o(siso_o),
      .done(dec_finish_r), //
    );

    Interleaver vec0_ITL_3(
      .clk_p_i(clk_p_i),
      .reset_n_i(reset_n_i),
      .data_i(vec0[6:0][3]),
      .data_o(vec0_ITL[6:0][3]),
    );

    Interleaver vec0_ITL_2(
      .clk_p_i(clk_p_i),
      .reset_n_i(reset_n_i),
      .data_i(vec0[6:0][2]),
      .data_o(vec0_ITL[6:0][2]),
    );

    Interleaver vec0_ITL_1(
      .clk_p_i(clk_p_i),
      .reset_n_i(reset_n_i),
      .data_i(vec0[6:0][1]),
      .data_o(vec0_ITL[6:0][1]),
    );

    Interleaver vec0_ITL_0(
      .clk_p_i(clk_p_i),
      .reset_n_i(reset_n_i),
      .data_i(vec0[6:0][0]),
      .data_o(vec0_ITL[6:0][0]),
    );

  /* ====================Combinational Part================== */
  //next-state logic //todo
  always @(*) begin
    // done_nxt = 0;
		case(state)
      S_READ: begin
        // read 21 bits per cycle from data_i, read 4 times
        // save them in vec0, vec1, vec2
        if (start_i == 1) begin
          vec0_nxt[extend_size-1:0] = data_i[20:14];
          vec1_nxt[extend_size-1:0] = data_i[13:7];
          vec2_nxt[extend_size-1:0] = data_i[6:0];
          read_counter_nxt = read_counter + 1;

          // finish reading data_i
          if(read_counter == 4) begin
            state_nxt = S_DEC1;
            read_counter_nxt = 0;
          end
        end

        else begin
          state_nxt = S_READ;
        end
      end

			S_DEC1: begin
        sys_i_nxt = vec0_i;       // [27:0]
        enc_i_nxt = vec1_i;       // [27:0]
        ext_i_nxt = ;             // [39:0]
        state_nxt = S_DEC2;
      end

      S_DEC2: begin
        sys_i_nxt = vec0_ITL_i;   // [27:0]
        enc_i_nxt = vec2_i;       // [27:0]
        ext_i_nxt = ;             // [39:0]
        if (iter_counter < MAX_ITER) begin
          state_nxt = S_DEC1;
          iter_counter_nxt = iter_counter + 1;
        end
        else begin
          state_nxt = S_ITER_FINISH;
        end
      end
		endcase
  end

  // state transition
    // always@ (*)
    //   // state           = state_nxt;
    //   // sys_w           = sys_r;
    //   // enc_w           = enc_r;
    //   // ext_w           = ext_r;
    //   // begin_w         = begin_r;
    //   // dec_finish_w    = dec_finish_r;
    //   // iter_finish_w   = iter_finish_r;
    //   // counter_w       = counter_r;

    //   begin
    //       case(state_nxt)
    //           S_IDLE: begin
    //             if(i_begin == 1) begin
    //               begin_w     = 1'd1;
    //               state     = S_DEC1;
    //               counter_w   = 6'd0;
    //             end
    //           end 
    //           S_DEC1: begin
    //             begin_w = 1'd0;
    //             if(dec_finish_r == 1)
    //               state     = S_DEC1_FINISH;
    //               counter_w   = counter_r += 6'd1;
    //           end 
    //           S_DEC1_FINISH: begin
    //             state       = S_DEC2;
    //             begin_w       = 1'd1;
    //             counter_w     = counter_r;
    //             state       = S_DEC2;
    //             counter_w     = counter_r;
    //           end 
    //           S_DEC2: begin
    //             begin_w = 1'd0;
    //             if(dec_finish_r == 1)
    //               state     = S_DEC2_FINISH;
    //               counter_w   = counter_r += 6'd1;
    //           end 
    //           S_DEC2_FINISH: begin
    //             if(counter_r == 6'd32) begin
    //               begin_w     = 1'd0;
    //               state     = S_ITER_FINISH;
    //             end
    //             else begin
    //               begin_w     = 1'd1;
    //               state     = S_DEC1;
    //             end
    //           end 
    //           S_ITER_FINISH: begin
    //             state       = S_IDLE;
    //             counter_w     = 6'd0;
    //           end 
    //        default:
        
    //       endcase
    //   end
   			  //todo
  /* ====================Sequential Part=================== */
    always@(posedge clk_p_i or negedge reset_n_i)
    begin
        if (reset_n_i == 1'b0)
            begin
                // vec0[0:extend_size-1][read_counter] <= 7'b0;
                // vec1[0:extend_size-1][read_counter] <= 7'b0;
                // vec2[0:extend_size-1][read_counter] <= 7'b0;
                sys_i                               <= 28'b0;
                enc_i                               <= 28'b0;
                ext_i                               <= 28'b0;

                state_nxt                           <= S_IDLE;
                read_counter                        <= 1'b0;
                iter_counter                        <= 6'b0;

                // begin_r         <= 1'd0;
                // dec_finish_r    <= 1'd0;
                // iter_finish_r   <= 1'd0;
                // counter_r       <= 6'd0;
                // data_r          <= data_i;
            end
        else
            begin
                // read input
                if (state == S_READ) begin
                  vec0[0:extend_size-1][read_counter] <= vec0_nxt[0:extend_size-1];
                  vec1[0:extend_size-1][read_counter] <= vec1_nxt[0:extend_size-1];
                  vec2[0:extend_size-1][read_counter] <= vec2_nxt[0:extend_size-1];
                end
                // calculate siso
                if (state == S_DEC1 or state == S_DEC2) begin
                  sys_i <= sys_i_nxt;
                  enc_i <= enc_i_nxt;
                  ext_i <= ext_i_nxt;
                end

                state           <= state_nxt;
                read_counter    <= read_counter_nxt;
                iter_counter    <= iter_counter_nxt;
                // enc_r           <= enc_w;
                // ext_r           <= ext_w;
                // sys_r           <= sys_w;
                // begin_r         <= begin_w;
                // dec_finish_r    <= dec_finish_w;
                // iter_finish_r   <= iter_finish_w;
                // counter_r       <= counter_w;
                // data_r          <= data_i;
            end
    end
  /* ====================================================== */

endmodule