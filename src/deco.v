module Deco(
             clk_p_i,
             reset_n_i,
             data_i,
             data_o,
             start_i,
             done_o,
             );

    parameter MAX_ITER          = 16;
    parameter data_size         = 5'd10;
    parameter input_size        = 5;
    parameter extend_size       = 7;             // input_size + 2, adding 00 at the end
    parameter block_size        = 21;            // 3 * (input_size + 2)
    parameter S_READ            = 2'd0;
    parameter S_DEC1            = 2'd1;
    parameter S_DEC2            = 2'd2;
    parameter S_ITER_FINISH     = 2'd3;

    input                       clk_p_i;
    input                       reset_n_i;
    input   [20:0]              data_i;       // **here
    output  [4:0]               data_o;
    input                       start_i;
    output                      done_o;

    wire    [27:0]              vec0_1D;
    wire    [27:0]              vec1_1D;
    wire    [69:0]              vec2_1D;

    wire    [69:0]              ext_i;
    reg     [27:0]              sys_reg;
    reg     [27:0]              enc_reg;
    reg     [69:0]              ext_reg;
    wire    [69:0]              siso1_o;

    reg     [3:0]               vec0         [0:extend_size-1];
    reg     [3:0]               vec1         [0:extend_size-1];
    reg     [3:0]               vec2         [0:extend_size-1];

    reg     [6:0]              vec0_reg;
    reg     [6:0]              vec1_reg;
    reg     [6:0]              vec2_reg;
    // reg     [3:0]               vec0_nxt     [0:extend_size-1];
    // reg     [3:0]               vec1_nxt     [0:extend_size-1];
    // reg     [3:0]               vec2_nxt     [0:extend_size-1];

    reg     [69:0]              temp_LLR;
    reg     [69:0]              temp_LLR_nxt;
    reg     [69:0]              temp_LLR1;
    reg     [69:0]              temp_LLR1_nxt;

    reg     [3:0]               state;
    reg     [3:0]               state_nxt;
    reg     [2:0]               read_counter;     
    reg     [2:0]               read_counter_nxt; 
    reg     [5:0]               iter_counter;
    reg     [5:0]               iter_counter_nxt;
    reg                         dec1_begin;
    reg                         dec1_begin_nxt;
    wire                        dec1_finish;
    reg                         start_reg;
    reg                         done;
    reg                         done_nxt; 

    // assign vec1_1D = ;
    // assign vec2_1D = {vec2[0][3:0], vec2[1][3:0], vec2[2][3:0], vec2[3][3:0], vec2[4][3:0], vec2[5][3:0], vec2[6][3:0]};
    // assign ext_i   = ext_reg;
    Siso siso1(
      .clk_i(clk_p_i),
      .reset_n_i(reset_n_i),
      .read_en_i(dec1_begin),
      .sys_i(vec0_1D),
      .enc_i(vec1_1D),
      .ext_i(vec2_1D),
      .data_o(siso1_o),
      .finish(dec1_finish)
    );
    assign done_o = done;
    assign vec0_1D = sys_reg;
    assign vec1_1D = enc_reg;
    assign vec2_1D = ext_reg;
    integer i;
    always @(*) begin
        temp_LLR_nxt = temp_LLR;
        temp_LLR1_nxt = temp_LLR1;
        read_counter_nxt = read_counter;
        iter_counter_nxt = iter_counter;
        dec1_begin_nxt = dec1_begin;
        done_nxt = done;
        case(state) 
            S_READ: begin
                if(start_reg == 1) begin
                    if(read_counter < 4) begin
                        for(i=0;i<7;i=i+1) begin
                            vec0[i][read_counter] = vec0_reg[6-i];
                            vec1[i][read_counter] = vec1_reg[6-i];
                            vec2[i][read_counter] = vec2_reg[6-i];
                        end
                        read_counter_nxt = read_counter + 1;
                        dec1_begin_nxt = 0;
                        state_nxt = S_READ;
                        iter_counter_nxt = iter_counter;
                    end
                    else begin
                        sys_reg = {vec0[0][3:0], vec0[1][3:0], vec0[2][3:0], vec0[3][3:0], vec0[4][3:0], vec0[5][3:0], vec0[6][3:0]};
                        enc_reg = {vec1[0][3:0], vec1[1][3:0], vec1[2][3:0], vec1[3][3:0], vec1[4][3:0], vec1[5][3:0], vec1[6][3:0]};
                        ext_reg = temp_LLR;
                        read_counter_nxt = 0;
                        dec1_begin_nxt = 1;
                        state_nxt = S_DEC1;
                    end
                end
                else begin
                    read_counter_nxt = 0;
                    dec1_begin_nxt = 0;
                    state_nxt = S_READ;
                    iter_counter_nxt = iter_counter;
                end
            end 
            S_DEC1: begin
                if(dec1_finish == 1) begin
                    sys_reg  = {vec0[0][3:0], vec0[4][3:0], vec0[2][3:0], vec0[1][3:0], vec0[3][3:0], 4'b0, 4'b0};
                    enc_reg  = {vec2[0][3:0], vec2[1][3:0], vec2[2][3:0], vec2[3][3:0], vec2[4][3:0], vec2[5][3:0], vec2[6][3:0]};
                    temp_LLR1_nxt[69:60] = siso1_o[69:60] - temp_LLR[69:60] - 2*vec0[0];
                    temp_LLR1_nxt[59:50] = siso1_o[29:20] - temp_LLR[29:20] - 2*vec0[4];
                    temp_LLR1_nxt[49:40] = siso1_o[49:40] - temp_LLR[49:40] - 2*vec0[2];
                    temp_LLR1_nxt[39:30] = siso1_o[59:50] - temp_LLR[59:50] - 2*vec0[1];
                    temp_LLR1_nxt[29:20] = siso1_o[39:30] - temp_LLR[39:30] - 2*vec0[3];
                    temp_LLR1_nxt[19:10] = 10'b0;
                    temp_LLR1_nxt[9:0] = 10'b0;
                    ext_reg  = temp_LLR1_nxt;

                    read_counter_nxt = 0;
                    dec1_begin_nxt = 1;
                    state_nxt = S_DEC2;
                    iter_counter_nxt = iter_counter;
                end
                else begin
                    read_counter_nxt = 0;
                    dec1_begin_nxt = 0;
                    state_nxt = S_DEC1;
                    iter_counter_nxt = iter_counter;
                end
            end
            S_DEC2: begin
                if(dec1_finish == 1) begin
                    sys_reg = {vec0[0][3:0], vec0[1][3:0], vec0[2][3:0], vec0[3][3:0], vec0[4][3:0], vec0[5][3:0], vec0[6][3:0]};
                    enc_reg = {vec1[0][3:0], vec1[1][3:0], vec1[2][3:0], vec1[3][3:0], vec1[4][3:0], vec1[5][3:0], vec1[6][3:0]};
                    temp_LLR_nxt[69:60] = siso1_o[69:60] - temp_LLR1[69:60] - 2*vec0[0];
                    temp_LLR_nxt[59:50] = siso1_o[39:30] - temp_LLR1[39:30] - 2*vec0[1];
                    temp_LLR_nxt[49:40] = siso1_o[49:40] - temp_LLR1[49:40] - 2*vec0[2];
                    temp_LLR_nxt[39:30] = siso1_o[29:20] - temp_LLR1[29:20] - 2*vec0[3];
                    temp_LLR_nxt[29:20] = siso1_o[59:50] - temp_LLR1[59:50] - 2*vec0[4];
                    temp_LLR_nxt[19:10] = 10'b0;
                    temp_LLR_nxt[9:0] = 10'b0;
                    
                    ext_reg  = temp_LLR_nxt;
                    read_counter_nxt = 0;
                    if(iter_counter != MAX_ITER) begin
                        state_nxt = S_DEC1;
                        dec1_begin_nxt = 1;
                        iter_counter_nxt = iter_counter + 1;
                    end
                    else begin
                        state_nxt = S_ITER_FINISH;
                        dec1_begin_nxt = 0;
                        iter_counter_nxt = 0;
                    end
                end
                else begin
                    read_counter_nxt = 0;
                    dec1_begin_nxt = 0;
                    state_nxt = S_DEC2;
                    iter_counter_nxt = iter_counter;
                end
            end
            S_ITER_FINISH: begin
                read_counter_nxt = 0;
                dec1_begin_nxt = 0;
                state_nxt = S_READ;
                iter_counter_nxt = 0;
                done_nxt = 1;
            end           
        endcase
    end
    always@(posedge clk_p_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin  
            state <= S_READ;
            done  <= 0;
            vec0_reg <= 7'b0;
            vec1_reg <= 7'b0;
            vec2_reg <= 7'b0;
            // vec0 <= vec0_reg;
            // vec1 <= vec1_reg;
            // vec1 <= vec2_reg;
            temp_LLR <= 70'b0;
            temp_LLR1 <= 70'b0;
            iter_counter <= 0;
            read_counter <= 0;
            dec1_begin <= 0;
            start_reg <= 0;
        end
        else begin 
            state <= state_nxt;
            done  <= done_nxt;
            vec0_reg <= data_i[20:14];
            vec1_reg <= data_i[13:7];
            vec2_reg <= data_i[6:0];
            // vec0 <= vec0_reg;
            // vec1 <= vec1_reg;
            // vec1 <= vec2_reg;
            temp_LLR <= temp_LLR_nxt;
            temp_LLR1 <= temp_LLR1_nxt;
            iter_counter <= iter_counter_nxt;
            read_counter <= read_counter_nxt;
            dec1_begin <= dec1_begin_nxt;
            start_reg <= start_i;
        end
	end
endmodule