module Decoder(
             clk_p_i,
             reset_n_i,
             data_i,
             data_o,
             start_i,
             done_o,
             );

  /*========================IO declaration============================ */	 

      parameter MAX_ITER          = 16;
      parameter data_size         = 5'd10;
      parameter input_size        = 5;
      parameter extend_size       = 7;             // input_size + 2, adding 00 at the end
      parameter block_size        = 21;            // 3 * (input_size + 2)
      parameter S_READ            = 2'd0;
      parameter S_DEC1            = 2'd1;
      parameter S_DEC2            = 2'd2;
      parameter S_ITER_FINISH     = 2'd3;
      // parameter S_DEC1_FINISH     = 3'd2;
      // parameter S_DEC2_FINISH     = 3'd4;

      input                       clk_p_i;
      input                       reset_n_i;
      input   [83:0]              data_i;
      output  [4:0]               data_o;
      input                       start_i;
      output                      done_o;

  /* =======================REG & wire================================ */

      // input vector
      reg     [3:0]               vec0         [0:extend_size-1];
      reg     [3:0]               vec1         [0:extend_size-1];
      reg     [3:0]               vec2         [0:extend_size-1];
      reg     [extend_size-1:0]   vec0_nxt;
      reg     [extend_size-1:0]   vec1_nxt;
      reg     [extend_size-1:0]   vec2_nxt;

      wire    [27:0]              vec0_1D;
      wire    [27:0]              vec1_1D;
      wire    [27:0]              vec2_1D;
      assign  vec0_1D = { vec0[6][3:0], vec0[5][3:0], vec0[4][3:0], vec0[3][3:0], vec0[2][3:0], vec0[1][3:0], vec0[0][3:0] };
      assign  vec1_1D = { vec1[6][3:0], vec1[5][3:0], vec1[4][3:0], vec1[3][3:0], vec1[2][3:0], vec1[1][3:0], vec1[0][3:0] };
      assign  vec2_1D = { vec2[6][3:0], vec2[5][3:0], vec2[4][3:0], vec2[3][3:0], vec2[2][3:0], vec2[1][3:0], vec2[0][3:0] };

      // siso1      
      reg     [27:0]              sys1_i;
      reg     [27:0]              sys1_i_nxt;
      reg     [27:0]              enc1_i;
      reg     [27:0]              enc1_i_nxt;
      reg     [69:0]              ext1_i;
      reg     [69:0]              ext1_i_nxt;
      reg     [69:0]              siso1_o;
      reg     [69:0]              siso1_o_nxt;

      wire    [9:0]               siso1_o_2D   [0:extend_size-1];

      assign  siso1_o_2D[6][9:0] = siso1_o[69:60];
      assign  siso1_o_2D[5][9:0] = siso1_o[59:50];
      assign  siso1_o_2D[4][9:0] = siso1_o[49:40];
      assign  siso1_o_2D[3][9:0] = siso1_o[39:30];
      assign  siso1_o_2D[2][9:0] = siso1_o[29:20];
      assign  siso1_o_2D[1][9:0] = siso1_o[19:10];
      assign  siso1_o_2D[0][9:0] = siso1_o[9:0];

      // siso2
      reg     [27:0]              sys2_i;
      reg     [27:0]              sys2_i_nxt;
      reg     [27:0]              enc2_i;
      reg     [27:0]              enc2_i_nxt;
      reg     [69:0]              ext2_i;
      reg     [69:0]              ext2_i_nxt;
      reg     [69:0]              siso2_o;
      reg     [69:0]              siso2_o_nxt;

      wire    [9:0]               siso2_o_2D   [0:extend_size-1];

      assign  siso2_o_2D[6][9:0] = siso2_o[69:60];
      assign  siso2_o_2D[5][9:0] = siso2_o[59:50];
      assign  siso2_o_2D[4][9:0] = siso2_o[49:40];
      assign  siso2_o_2D[3][9:0] = siso2_o[39:30];
      assign  siso2_o_2D[2][9:0] = siso2_o[29:20];
      assign  siso2_o_2D[1][9:0] = siso2_o[19:10];
      assign  siso2_o_2D[0][9:0] = siso2_o[9:0];

      // interleaver
      wire    [3:0]               ITL1_o       [0:extend_size-1];
      wire    [9:0]               ITL2_o       [0:extend_size-1];
      wire    [27:0]              ITL1_o_1D;
      wire    [69:0]              ITL2_o_1D;
      assign  ITL1_o_1D = { ITL1_o[6][3:0], ITL1_o[5][3:0], ITL1_o[4][3:0], ITL1_o[3][3:0], ITL1_o[2][3:0], ITL1_o[1][3:0], ITL1_o[0][3:0] };
      assign  ITL2_o_1D = { ITL2_o[6][9:0], ITL2_o[5][9:0], ITL2_o[4][9:0], ITL2_o[3][9:0], ITL2_o[2][9:0], ITL2_o[1][9:0], ITL2_o[0][9:0] };

      // de-interleaver
      wire    [9:0]               DITL1_o      [0:extend_size-1];
      wire    [9:0]               DITL2_o      [0:extend_size-1];
      wire    [69:0]              DITL1_o_1D;
      wire    [69:0]              DITL2_o_1D;
      assign  DITL1_o_1D = { DITL1_o[6][9:0], DITL1_o[5][9:0], DITL1_o[4][9:0], DITL1_o[3][9:0], DITL1_o[2][9:0], DITL1_o[1][9:0], DITL1_o[0][9:0] };
      assign  DITL2_o_1D = { DITL2_o[6][9:0], DITL2_o[5][9:0], DITL2_o[4][9:0], DITL2_o[3][9:0], DITL2_o[2][9:0], DITL2_o[1][9:0], DITL2_o[0][9:0] };

      // middle connection
      wire    [9:0]               ITL2_i       [0:extend_size-1];
      wire    [9:0]               DITL1_i      [0:extend_size-1];

      generate
        genvar o, p;
        for ( o = 0; o < 4; o = o + 1 ) begin
          for ( p = 0; p < 7; p = p + 1 ) begin
            assign  ITL2_i[p][o]  = siso1_o_2D[p][o] - DITL1_o[p][o];
            assign  DITL1_i[p][o] = siso2_o_2D[p][o] - ITL2_o[p][o];
          end
        end
      endgenerate
      // assign  ITL2_i  = siso1_o_2D - DITL1_o;
      // assign  DITL1_i = siso2_o_2D - ITL2_o;

      // output sampling
      assign  data_o[4] = DITL2_o[6][9] ? 0 : 1;
      assign  data_o[3] = DITL2_o[5][9] ? 0 : 1;
      assign  data_o[2] = DITL2_o[4][9] ? 0 : 1;      
      assign  data_o[1] = DITL2_o[3][9] ? 0 : 1; 
      assign  data_o[0] = DITL2_o[2][9] ? 0 : 1;
      
      // state control signals
      reg     [3:0]               state;
      reg     [3:0]               state_nxt;
      reg     [1:0]               read_counter;     
      reg     [1:0]               read_counter_nxt; 
      reg     [5:0]               iter_counter;
      reg     [5:0]               iter_counter_nxt;
      reg                         dec1_begin;
      reg                         dec1_begin_nxt;
      reg                         dec1_finish;
      reg                         dec1_finish_nxt;
      reg                         dec2_begin;
      reg                         dec2_begin_nxt;
      reg                         dec2_finish;
      reg                         dec2_finish_nxt;
      reg                         done;
      reg                         done_nxt; 

      assign  done_o    = done;
      // reg                         iter_finish_w;
      // reg                         iter_finish_r;
      // reg                         begin_w;
      // reg                         begin_r;
      
    Siso siso1(
      .clk_i(clk_p_i),
      .reset_n_i(reset_n_i),
      .read_en_i(dec1_begin),
      .sys_i(sys1_i),
      .enc_i(enc1_i),
      .ext_i(ext1_i),
      .data_o(siso1_o),
      .finish(dec1_finish)
    );

    Siso siso2(
      .clk_i(clk_p_i),
      .reset_n_i(reset_n_i),
      .read_en_i(dec2_begin),
      .sys_i(sys2_i),
      .enc_i(enc2_i),
      .ext_i(ext2_i),
      .data_o(siso2_o),
      .finish(dec2_finish)
    );

    // ITL1 7 bits 4 times, input: vec0, output: ITL1_o 
    genvar i;
      generate
        for (i=0; i<4; i=i+1) begin
          Interleaver ITL1(
            .clk_p_i(clk_p_i),
            .reset_n_i(reset_n_i),
            .data_i( { vec0[6][i], vec0[5][i], vec0[4][i], vec0[3][i], vec0[2][i], vec0[1][i], vec0[0][i]} ),
            .data_o( { ITL1_o[6][i], ITL1_o[5][i], ITL1_o[4][i], ITL1_o[3][i], ITL1_o[2][i], ITL1_o[1][i], ITL1_o[0][i]} )
          );
        end 
    endgenerate

    // ITL2 7 bits 10 times, input: ITL2_i, output: ITL2_o 
    genvar j;
      generate
        for (j=0; j<10; j=j+1) begin
          Interleaver ITL2(
            .clk_p_i(clk_p_i),
            .reset_n_i(reset_n_i),
            .data_i( { ITL2_i[6][j], ITL2_i[5][j], ITL2_i[4][j], ITL2_i[3][j], ITL2_i[2][j], ITL2_i[1][j], ITL2_i[0][j]} ),
            .data_o( { ITL2_o[6][j], ITL2_o[5][j], ITL2_o[4][j], ITL2_o[3][j], ITL2_o[2][j], ITL2_o[1][j], ITL2_o[0][j]} )
          );
        end 
    endgenerate

    // DITL1 7 bits 10 times, input: DITL1_i, output: DITL1_o 
    genvar k;
      generate
        for (k=0; k<10; k=k+1) begin
          Interleaver ITL2(
            .clk_p_i(clk_p_i),
            .reset_n_i(reset_n_i),
            .data_i( { DITL1_i[6][k], DITL1_i[5][k], DITL1_i[4][k], DITL1_i[3][k], DITL1_i[2][k], DITL1_i[1][k], DITL1_i[0][k]} ),
            .data_o( { DITL1_o[6][k], DITL1_o[5][k], DITL1_o[4][k], DITL1_o[3][k], DITL1_o[2][k], DITL1_o[1][k], DITL1_o[0][k]} )
          );
        end 
    endgenerate

    // DITL2 7 bits 10 times, input: siso2_o_2D, output: DITL2_o 
    genvar l;
      generate
        for (l=0; l<10; l=l+1) begin
          Interleaver ITL2(
            .clk_p_i(clk_p_i),
            .reset_n_i(reset_n_i),
            .data_i( { siso2_o_2D[6][l], siso2_o_2D[5][l], siso2_o_2D[4][l], siso2_o_2D[3][l], siso2_o_2D[2][l], siso2_o_2D[1][l], siso2_o_2D[0][l]} ),
            .data_o( { DITL2_o[6][l], DITL2_o[5][l], DITL2_o[4][l], DITL2_o[3][l], DITL2_o[2][l], DITL2_o[1][l], DITL2_o[0][l]} )
          );
        end 
    endgenerate

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
            dec1_begin_nxt = 1;
            read_counter_nxt = 0;
          end
        end

        else begin
          state_nxt = S_READ;
        end
      end

			S_DEC1: begin
        sys1_i_nxt = vec0_1D;       // [27:0]
        enc1_i_nxt = vec1_1D;       // [27:0]
        ext1_i_nxt = DITL1_o_1D;    // [69:0] first iter is 70'b0
        if ( dec1_finish == 1 ) begin
          state_nxt = S_DEC2;
          dec1_begin_nxt = 0;
          // done_nxt = 1;
          dec2_begin_nxt = 1;
        end
        else begin
          state_nxt = S_DEC1;
          // done_nxt = 0;
        end
      end

      S_DEC2: begin
        sys2_i_nxt = ITL1_o_1D;     // [27:0]
        enc2_i_nxt = vec2_1D;       // [27:0]
        ext2_i_nxt = ITL2_o_1D;     // [69:0]
        if ( dec2_finish == 1 ) begin
          if (iter_counter < MAX_ITER) begin
            state_nxt = S_DEC1;
            dec2_begin_nxt = 0;
            // done_nxt = 1;
            dec1_begin_nxt = 1;
            iter_counter_nxt = iter_counter + 1;
          end
          else begin
            state_nxt = S_ITER_FINISH;
            // done_nxt = 1;
          end
        end
        else begin
          state_nxt = S_DEC2;
          // done_nxt = 0;
        end
      end

      S_ITER_FINISH: begin // todo calculate data_o from DITL2
        done_nxt = 1;
      end

		endcase
  end

  integer ii, jj;
  /* ====================Sequential Part=================== */
    always@(posedge clk_p_i or negedge reset_n_i)
    begin
        if (reset_n_i == 1'b0) 
            begin
                for ( ii = 0; ii < 4; ii = ii+1 ) begin
                  for ( jj = 0; jj < 7; jj = jj+1 ) begin
                    vec0[jj][ii] <= 7'b0;
                    vec1[jj][ii] <= 7'b0;
                    vec2[jj][ii] <= 7'b0;  
                  end
                end

                sys1_i                      <= 28'b0;
                enc1_i                      <= 28'b0;
                ext1_i                      <= 28'b0;
                siso1_o                     <= 28'b0;
                sys2_i                      <= 28'b0;
                enc2_i                      <= 28'b0;
                ext2_i                      <= 28'b0;
                siso2_o                     <= 28'b0;

                state                       <= S_READ;
                read_counter                <= 2'b0;
                iter_counter                <= 6'b0;
                dec1_begin                  <= 1'b0;
                dec1_finish                 <= 1'b0;
                dec2_begin                  <= 1'b0;
                dec2_finish                 <= 1'b0;
                done                        <= 1'b0;

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
                  for ( jj = 0; jj < 7; jj = jj+1 ) begin
                    vec0[jj][read_counter] <= vec0_nxt[jj];
                    vec1[jj][read_counter] <= vec1_nxt[jj];
                    vec2[jj][read_counter] <= vec2_nxt[jj];
                  end
                end
                // calculate siso
                else if (state == S_DEC1) begin
                  sys1_i                              <= sys1_i_nxt;
                  enc1_i                              <= enc1_i_nxt;
                  ext1_i                              <= ext1_i_nxt;
                  siso1_o                             <= siso1_o_nxt;
                end
                else if (state == S_DEC2) begin
                  sys2_i                              <= sys2_i_nxt;
                  enc2_i                              <= enc2_i_nxt;
                  ext2_i                              <= ext2_i_nxt;
                  siso2_o                             <= siso2_o_nxt;
                end

                state                                 <= state_nxt;
                read_counter                          <= read_counter_nxt;
                iter_counter                          <= iter_counter_nxt;
                dec1_begin                            <= dec1_begin_nxt;
                dec1_finish                           <= dec1_finish_nxt;
                dec2_begin                            <= dec2_begin_nxt;
                dec2_finish                           <= dec2_finish_nxt;
                done                                  <= done_nxt;
                // begin_r         <= begin_w;
                // dec_finish_r    <= dec_finish_w;
                // iter_finish_r   <= iter_finish_w;
                // counter_r       <= counter_w;
                // data_r          <= data_i;
            end
    end
  /* ====================================================== */

endmodule