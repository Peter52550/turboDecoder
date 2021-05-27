// DEFINE NUMBER OF BITS TO REPRESENT LLR HERE!!
//
`define LLR_BITS    12
//
//

module over1(a, b, result);
	parameter WIDTH = `LLR_BITS;
	parameter MSB   = WIDTH-1;
	parameter neg 	= {1'b1, {(WIDTH-1){1'b0}}};
	parameter pos 	= {1'b0, {(WIDTH-1){1'b1}}};
	input signed [WIDTH-1:0] a, b;
	output reg signed [WIDTH-1:0] result;

	reg signed [WIDTH-1:0] temp;
	reg overflow, underflow;
	reg extra;
    reg signed [WIDTH-1:0] b_com;
	always @* begin
        b_com = ~b + 1;
		{extra, temp} = {a[MSB], a} + {b_com[MSB], b_com};
		overflow  = ({extra, temp[MSB]} == 2'b01) ? 1'b1 : 1'b0;
		underflow = ({extra, temp[MSB]} == 2'b10) ? 1'b1 : 1'b0;
		result = 	(overflow) 	? pos : 
					(underflow)	? neg : temp;
	end
endmodule

module Deco(
             clk_p_i,
             reset_n_i,
             data_i,
             data_o,
             start_i,
             done_o,
);

    parameter MAX_ITER          = 10;
    parameter data_size         = `LLR_BITS;
    
    parameter input_size        = 5;
    parameter extend_size       = 7;                    // input_size + 2, adding 00 at the end
    parameter block_size        = 21;                   // 3 * (input_size + 2)
    parameter LLR_size          = extend_size*data_size;// extend_size * data_size 
    parameter S_READ            = 2'd0;
    parameter S_DEC1            = 2'd1;
    parameter S_DEC2            = 2'd2;
    parameter S_ITER_FINISH     = 2'd3;

    input                       clk_p_i;
    input                       reset_n_i;
    input   [block_size-1:0]    data_i;       // **here
    output  [input_size-1:0]    data_o;
    input                       start_i;
    output                      done_o;

    //latch
    reg     [input_size-1:0]                    out_reg_nxt;
    reg     [3:0]               vec0_nxt     [0:extend_size-1];
    reg     [3:0]               vec1_nxt     [0:extend_size-1];
    reg     [3:0]               vec2_nxt     [0:extend_size-1];

    reg     [input_size-1:0]                    out_reg; 
    reg     [input_size-1:0]                    LLR1_reg;
    reg     [input_size-1:0]                    LLR2_reg;
    wire    signed [27:0]                       vec0_1D;
    wire    signed [27:0]                       vec1_1D;
    wire    signed [LLR_size-1:0]               vec2_1D;

    wire    signed [LLR_size-1:0]               ext_i;
    reg     signed [27:0]                       sys_reg;
    reg     signed [27:0]                       enc_reg;
    reg     signed [LLR_size-1:0]               ext_reg;
    reg     signed [27:0]                       sys_reg_nxt;
    reg     signed [27:0]                       enc_reg_nxt;
    reg     signed [LLR_size-1:0]               ext_reg_nxt;
    wire    signed [data_size-1:0]              ext_out     [0:input_size-1];
    wire    signed [data_size-1:0]              ext1_out    [0:input_size-1];
    wire    signed [LLR_size-1:0]               siso1_o;

    reg     signed [3:0]                        vec0        [0:extend_size-1];
    reg     signed [3:0]                        vec1        [0:extend_size-1];
    reg     signed [3:0]                        vec2        [0:extend_size-1];

    reg     signed [extend_size-1:0]            vec0_reg;
    reg     signed [extend_size-1:0]            vec1_reg;
    reg     signed [extend_size-1:0]            vec2_reg;

    reg     signed [data_size-1:0]              temp_LLR        [0:extend_size-1];
    reg     signed [data_size-1:0]              temp_LLR_nxt    [0:extend_size-1];
    reg     signed [data_size-1:0]              temp_LLR1       [0:extend_size-1];
    reg     signed [data_size-1:0]              temp_LLR1_nxt   [0:extend_size-1];

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

    wire   signed  [LLR_size-1:0]        middle1;
    wire   signed  [LLR_size-1:0]        middle2;
    wire   signed  [LLR_size-1:0]        middle3;
    wire   signed  [LLR_size-1:0]        middle4;
   
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
    over1 M111(.a(siso1_o[LLR_size-1 -: data_size]),  .b(temp_LLR[0]),  .result(middle1[LLR_size-1 -: data_size]));
    over1 M121(.a(middle1[LLR_size-1 -: data_size]),  .b({{(data_size-4){vec0[0][3]}}, vec0[0]}),  .result(middle2[LLR_size-1 -: data_size]));
    over1 M131(.a(middle2[LLR_size-1 -: data_size]),  .b({{(data_size-4){vec0[0][3]}}, vec0[0]}),  .result(ext_out[0]));
    over1 M211(.a(siso1_o[LLR_size-1 - 4*data_size -: data_size]),  .b(temp_LLR[4]),  .result(middle1[LLR_size-1 - data_size -: data_size]));
    over1 M221(.a(middle1[LLR_size-1 - data_size -: data_size]),  .b({{(data_size-4){vec0[4][3]}}, vec0[4]}),  .result(middle2[LLR_size-1 - data_size -: data_size]));
    over1 M231(.a(middle2[LLR_size-1 - data_size -: data_size]),  .b({{(data_size-4){vec0[4][3]}}, vec0[4]}),  .result(ext_out[1]));
    over1 M311(.a(siso1_o[LLR_size-1 - 2*data_size -: data_size]),  .b(temp_LLR[2]),  .result(middle1[LLR_size-1 - 2*data_size -: data_size]));
    over1 M321(.a(middle1[LLR_size-1 - 2*data_size -: data_size]),  .b({{(data_size-4){vec0[2][3]}}, vec0[2]}),  .result(middle2[LLR_size-1 - 2*data_size -: data_size]));
    over1 M331(.a(middle2[LLR_size-1 - 2*data_size -: data_size]),  .b({{(data_size-4){vec0[2][3]}}, vec0[2]}),  .result(ext_out[2]));
    over1 M411(.a(siso1_o[LLR_size-1 - data_size -: data_size]),  .b(temp_LLR[1]),  .result(middle1[LLR_size-1 - 3*data_size -: data_size]));
    over1 M421(.a(middle1[LLR_size-1 - 3*data_size -: data_size]),  .b({{(data_size-4){vec0[1][3]}}, vec0[1]}),  .result(middle2[LLR_size-1 - 3*data_size -: data_size]));
    over1 M431(.a(middle2[LLR_size-1 - 3*data_size -: data_size]),  .b({{(data_size-4){vec0[1][3]}}, vec0[1]}),  .result(ext_out[3]));
    over1 M511(.a(siso1_o[LLR_size-1 - 3*data_size -: data_size]),  .b(temp_LLR[3]),  .result(middle1[LLR_size-1 - 4*data_size -: data_size]));
    over1 M521(.a(middle1[LLR_size-1 - 4*data_size -: data_size]),  .b({{(data_size-4){vec0[3][3]}}, vec0[3]}),  .result(middle2[LLR_size-1 - 4*data_size -: data_size]));
    over1 M531(.a(middle2[LLR_size-1 - 4*data_size -: data_size]),  .b({{(data_size-4){vec0[3][3]}}, vec0[3]}),  .result(ext_out[4]));
    over1 M112(.a(siso1_o[LLR_size-1 -: data_size]),  .b(temp_LLR1[0]), .result(middle3[LLR_size-1 -: data_size]));
    over1 M122(.a(middle3[LLR_size-1 -: data_size]),  .b({{(data_size-4){vec0[0][3]}}, vec0[0]}),  .result(middle4[LLR_size-1 -: data_size]));
    over1 M132(.a(middle4[LLR_size-1 -: data_size]),  .b({{(data_size-4){vec0[0][3]}}, vec0[0]}),  .result(ext1_out[0]));
    over1 M212(.a(siso1_o[LLR_size-1 - 3*data_size -: data_size]),  .b(temp_LLR1[3]), .result(middle3[LLR_size-1 - data_size -: data_size]));
    over1 M222(.a(middle3[LLR_size-1 - data_size -: data_size]),  .b({{(data_size-4){vec0[1][3]}}, vec0[1]}),  .result(middle4[LLR_size-1 - data_size -: data_size]));
    over1 M232(.a(middle4[LLR_size-1 - data_size -: data_size]),  .b({{(data_size-4){vec0[1][3]}}, vec0[1]}),  .result(ext1_out[1]));
    over1 M312(.a(siso1_o[LLR_size-1 - 2*data_size -: data_size]),  .b(temp_LLR1[2]), .result(middle3[LLR_size-1 - 2*data_size -: data_size]));
    over1 M322(.a(middle3[LLR_size-1 - 2*data_size -: data_size]),  .b({{(data_size-4){vec0[2][3]}}, vec0[2]}),  .result(middle4[LLR_size-1 - 2*data_size -: data_size]));
    over1 M332(.a(middle4[LLR_size-1 - 2*data_size -: data_size]),  .b({{(data_size-4){vec0[2][3]}}, vec0[2]}),  .result(ext1_out[2]));
    over1 M412(.a(siso1_o[LLR_size-1 - 4*data_size -: data_size]),  .b(temp_LLR1[4]), .result(middle3[LLR_size-1 - 3*data_size -: data_size]));
    over1 M422(.a(middle3[LLR_size-1 - 3*data_size -: data_size]),  .b({{(data_size-4){vec0[3][3]}}, vec0[3]}),  .result(middle4[LLR_size-1 - 3*data_size -: data_size]));
    over1 M432(.a(middle4[LLR_size-1 - 3*data_size -: data_size]),  .b({{(data_size-4){vec0[3][3]}}, vec0[3]}),  .result(ext1_out[3]));
    over1 M512(.a(siso1_o[LLR_size-1 - data_size -: data_size]),  .b(temp_LLR1[1]), .result(middle3[LLR_size-1 - 4*data_size -: data_size]));
    over1 M522(.a(middle3[LLR_size-1 - 4*data_size -: data_size]),  .b({{(data_size-4){vec0[4][3]}}, vec0[4]}),  .result(middle4[LLR_size-1 - 4*data_size -: data_size]));
    over1 M532(.a(middle4[LLR_size-1 - 4*data_size -: data_size]),  .b({{(data_size-4){vec0[4][3]}}, vec0[4]}),  .result(ext1_out[4]));
    assign done_o = done;
    assign vec0_1D = sys_reg;
    assign vec1_1D = enc_reg;
    assign vec2_1D = ext_reg;
    assign data_o = out_reg;
    integer i,j;
    integer siso_f, count;
    initial begin
        count = 1;
        siso_f = $fopen("siso.dat");
    end
    always@(siso1_o) begin
        $fdisplay(siso_f, "%3d %b ", count, siso1_o);
        //$fdisplay(siso_f, $time, " %3d %b ", count, siso1_o);
        count = count + 1;
    end
    always @(*) begin
        for(i=0;i<extend_size;i=i+1) begin
            temp_LLR_nxt[i] = temp_LLR[i];
            temp_LLR1_nxt[i] = temp_LLR1[i];
        end
        read_counter_nxt = read_counter;
        iter_counter_nxt = iter_counter;
        dec1_begin_nxt = dec1_begin;
        done_nxt = done;
        state_nxt = state;
        sys_reg_nxt = sys_reg;
        enc_reg_nxt = enc_reg;
        ext_reg_nxt = ext_reg;
        out_reg_nxt = out_reg;
        for(j=0;j<7;j=j+1) begin
            vec0_nxt[j] = vec0[j];
            vec1_nxt[j] = vec1[j];
            vec2_nxt[j] = vec2[j];
        end
        case(state) 
            S_READ: begin
                done_nxt = 0;
                if(start_reg == 1) begin
                    if(read_counter < 4) begin
                        for(i=0;i<7;i=i+1) begin
                            vec0_nxt[i][read_counter] = vec0_reg[6-i];
                            vec1_nxt[i][read_counter] = vec1_reg[6-i];
                            vec2_nxt[i][read_counter] = vec2_reg[6-i];
                        end
                        read_counter_nxt = read_counter + 1;
                        dec1_begin_nxt = 0;
                        state_nxt = S_READ;
                        iter_counter_nxt = iter_counter;
                    end
                    else begin
                        sys_reg_nxt = {vec0_nxt[0][3:0], vec0_nxt[1][3:0], vec0_nxt[2][3:0], vec0_nxt[3][3:0], vec0_nxt[4][3:0], vec0_nxt[5][3:0], vec0_nxt[6][3:0]};
                        enc_reg_nxt = {vec1_nxt[0][3:0], vec1_nxt[1][3:0], vec1_nxt[2][3:0], vec1_nxt[3][3:0], vec1_nxt[4][3:0], vec1_nxt[5][3:0], vec1_nxt[6][3:0]};
                        ext_reg_nxt = {temp_LLR[0], temp_LLR[1], temp_LLR[2], temp_LLR[3], temp_LLR[4], temp_LLR[5], temp_LLR[6]};
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
                    sys_reg_nxt  = {vec0[0][3:0], vec0[4][3:0], vec0[2][3:0], vec0[1][3:0], vec0[3][3:0], 4'b0, 4'b0};
                    enc_reg_nxt  = {vec2[0][3:0], vec2[1][3:0], vec2[2][3:0], vec2[3][3:0], vec2[4][3:0], vec2[5][3:0], vec2[6][3:0]};
                    
                    // temp_LLR1_nxt[0] = siso1_o[69:60] - temp_LLR[0] - 2* { {6{vec0[0][3]}} , vec0[0]};
                    // temp_LLR1_nxt[1] = siso1_o[29:20] - temp_LLR[4] - 2* { {6{vec0[4][3]}} , vec0[4]};
                    // temp_LLR1_nxt[2] = siso1_o[49:40] - temp_LLR[2] - 2* { {6{vec0[2][3]}} , vec0[2]};
                    // temp_LLR1_nxt[3] = siso1_o[59:50] - temp_LLR[1] - 2* { {6{vec0[1][3]}} , vec0[1]};
                    // temp_LLR1_nxt[4] = siso1_o[39:30] - temp_LLR[3] - 2* { {6{vec0[3][3]}} , vec0[3]};
                    
                    //temp_LLR1_nxt[0] = siso1_o[LLR_size-1 -: data_size]               - temp_LLR[0] - {{(data_size-4){vec0[0][3]}}, vec0[0]} - {{(data_size-4){vec0[0][3]}}, vec0[0]};
                    //temp_LLR1_nxt[1] = siso1_o[LLR_size-1 - 4*data_size -: data_size] - temp_LLR[4] - {{(data_size-4){vec0[4][3]}}, vec0[4]} - {{(data_size-4){vec0[4][3]}}, vec0[4]};
                    //temp_LLR1_nxt[2] = siso1_o[LLR_size-1 - 2*data_size -: data_size] - temp_LLR[2] - {{(data_size-4){vec0[2][3]}}, vec0[2]} - {{(data_size-4){vec0[2][3]}}, vec0[2]};
                    //temp_LLR1_nxt[3] = siso1_o[LLR_size-1 - data_size -: data_size]   - temp_LLR[1] - {{(data_size-4){vec0[1][3]}}, vec0[1]} - {{(data_size-4){vec0[1][3]}}, vec0[1]};
                    //temp_LLR1_nxt[4] = siso1_o[LLR_size-1 - 3*data_size -: data_size] - temp_LLR[3] - {{(data_size-4){vec0[3][3]}}, vec0[3]} - {{(data_size-4){vec0[3][3]}}, vec0[3]};
                    //temp_LLR1_nxt[5] = {(data_size){1'b0}};
                    //temp_LLR1_nxt[6] = {(data_size){1'b0}};

                    temp_LLR1_nxt[0] = ext_out[0];
                    temp_LLR1_nxt[1] = ext_out[1];
                    temp_LLR1_nxt[2] = ext_out[2];
                    temp_LLR1_nxt[3] = ext_out[3];
                    temp_LLR1_nxt[4] = ext_out[4];
                    temp_LLR1_nxt[5] = {(data_size){1'b0}};
                    temp_LLR1_nxt[6] = {(data_size){1'b0}};
                    ext_reg_nxt  = {temp_LLR1_nxt[0], temp_LLR1_nxt[1], temp_LLR1_nxt[2], temp_LLR1_nxt[3], temp_LLR1_nxt[4], temp_LLR1_nxt[5], temp_LLR1_nxt[6]};

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
                    sys_reg_nxt = {vec0[0][3:0], vec0[1][3:0], vec0[2][3:0], vec0[3][3:0], vec0[4][3:0], vec0[5][3:0], vec0[6][3:0]};
                    enc_reg_nxt = {vec1[0][3:0], vec1[1][3:0], vec1[2][3:0], vec1[3][3:0], vec1[4][3:0], vec1[5][3:0], vec1[6][3:0]};
                    
                    // temp_LLR_nxt[0] = siso1_o[69:60] - temp_LLR1[0] - 2* { {6{vec0[0][3]}},  vec0[0]};
                    // temp_LLR_nxt[1] = siso1_o[39:30] - temp_LLR1[3] - 2* { {6{vec0[1][3]}},  vec0[1]};
                    // temp_LLR_nxt[2] = siso1_o[49:40] - temp_LLR1[2] - 2* { {6{vec0[2][3]}},  vec0[2]};
                    // temp_LLR_nxt[3] = siso1_o[29:20] - temp_LLR1[4] - 2* { {6{vec0[3][3]}},  vec0[3]};
                    // temp_LLR_nxt[4] = siso1_o[59:50] - temp_LLR1[1] - 2* { {6{vec0[4][3]}},  vec0[4]};
                    
                    //temp_LLR_nxt[0] = siso1_o[LLR_size-1 -: data_size]               - temp_LLR1[0] - {{(data_size-4){vec0[0][3]}}, vec0[0]} - {{(data_size-4){vec0[0][3]}}, vec0[0]};
                    //temp_LLR_nxt[1] = siso1_o[LLR_size-1 - 3*data_size -: data_size] - temp_LLR1[3] - {{(data_size-4){vec0[1][3]}}, vec0[1]} - {{(data_size-4){vec0[1][3]}}, vec0[1]};
                    //temp_LLR_nxt[2] = siso1_o[LLR_size-1 - 2*data_size -: data_size] - temp_LLR1[2] - {{(data_size-4){vec0[2][3]}}, vec0[2]} - {{(data_size-4){vec0[2][3]}}, vec0[2]};
                    //temp_LLR_nxt[3] = siso1_o[LLR_size-1 - 4*data_size -: data_size] - temp_LLR1[4] - {{(data_size-4){vec0[3][3]}}, vec0[3]} - {{(data_size-4){vec0[3][3]}}, vec0[3]};
                    //temp_LLR_nxt[4] = siso1_o[LLR_size-1 - data_size -: data_size]   - temp_LLR1[1] - {{(data_size-4){vec0[4][3]}}, vec0[4]} - {{(data_size-4){vec0[4][3]}}, vec0[4]};
                    //temp_LLR_nxt[5] = {(data_size){1'b0}};
                    //temp_LLR_nxt[6] = {(data_size){1'b0}};

                    temp_LLR_nxt[0] = ext1_out[0];
                    temp_LLR_nxt[1] = ext1_out[1];
                    temp_LLR_nxt[2] = ext1_out[2];
                    temp_LLR_nxt[3] = ext1_out[3];
                    temp_LLR_nxt[4] = ext1_out[4];
                    temp_LLR_nxt[5] = {(data_size){1'b0}};
                    temp_LLR_nxt[6] = {(data_size){1'b0}};
                    
                    ext_reg_nxt  = {temp_LLR_nxt[0], temp_LLR_nxt[1], temp_LLR_nxt[2], temp_LLR_nxt[3], temp_LLR_nxt[4], temp_LLR_nxt[5], temp_LLR_nxt[6]};
                    read_counter_nxt = 0;

                    // Restore temp_LLR1_nxt to LLR1
                    // LLR1_reg[4] = temp_LLR1_nxt[0][data_size-1] == 1 ? 0 : 1;
                    // LLR1_reg[3] = temp_LLR1_nxt[3][data_size-1] == 1 ? 0 : 1;
                    // LLR1_reg[2] = temp_LLR1_nxt[2][data_size-1] == 1 ? 0 : 1;
                    // LLR1_reg[1] = temp_LLR1_nxt[4][data_size-1] == 1 ? 0 : 1;
                    // LLR1_reg[0] = temp_LLR1_nxt[1][data_size-1] == 1 ? 0 : 1;
                    // LLR2_reg[4] = temp_LLR_nxt[0][data_size-1] == 1 ? 0 : 1;
                    // LLR2_reg[3] = temp_LLR_nxt[1][data_size-1] == 1 ? 0 : 1;
                    // LLR2_reg[2] = temp_LLR_nxt[2][data_size-1] == 1 ? 0 : 1;
                    // LLR2_reg[1] = temp_LLR_nxt[3][data_size-1] == 1 ? 0 : 1;
                    // LLR2_reg[0] = temp_LLR_nxt[4][data_size-1] == 1 ? 0 : 1;
                    LLR1_reg[4] = ~temp_LLR1_nxt[0][data_size-1];
                    LLR1_reg[3] = ~temp_LLR1_nxt[3][data_size-1];
                    LLR1_reg[2] = ~temp_LLR1_nxt[2][data_size-1];
                    LLR1_reg[1] = ~temp_LLR1_nxt[4][data_size-1];
                    LLR1_reg[0] = ~temp_LLR1_nxt[1][data_size-1];
                    LLR2_reg[4] = ~temp_LLR_nxt[0][data_size-1];
                    LLR2_reg[3] = ~temp_LLR_nxt[1][data_size-1];
                    LLR2_reg[2] = ~temp_LLR_nxt[2][data_size-1];
                    LLR2_reg[1] = ~temp_LLR_nxt[3][data_size-1];
                    LLR2_reg[0] = ~temp_LLR_nxt[4][data_size-1];
                    
                    
                    if(LLR1_reg == LLR2_reg) begin
                        state_nxt = S_ITER_FINISH;
                        dec1_begin_nxt = 0;
                        iter_counter_nxt = 0;
                        out_reg_nxt = LLR2_reg;
                    end
                    else begin
                        if(iter_counter != MAX_ITER-1) begin
                            state_nxt = S_DEC1;
                            dec1_begin_nxt = 1;
                            iter_counter_nxt = iter_counter + 1;
                        end
                        else begin
                            state_nxt = S_ITER_FINISH;
                            dec1_begin_nxt = 0;
                            iter_counter_nxt = 0;
                            // out_reg_nxt[4] = temp_LLR_nxt[0][data_size-1] == 1 ? 0 : 1;
                            // out_reg_nxt[3] = temp_LLR_nxt[1][data_size-1] == 1 ? 0 : 1;
                            // out_reg_nxt[2] = temp_LLR_nxt[2][data_size-1] == 1 ? 0 : 1;
                            // out_reg_nxt[1] = temp_LLR_nxt[3][data_size-1] == 1 ? 0 : 1;
                            // out_reg_nxt[0] = temp_LLR_nxt[4][data_size-1] == 1 ? 0 : 1;
                            out_reg_nxt[4] = ~temp_LLR_nxt[0][data_size-1];
                            out_reg_nxt[3] = ~temp_LLR_nxt[1][data_size-1];
                            out_reg_nxt[2] = ~temp_LLR_nxt[2][data_size-1];
                            out_reg_nxt[1] = ~temp_LLR_nxt[3][data_size-1];
                            out_reg_nxt[0] = ~temp_LLR_nxt[4][data_size-1];
                        end
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
                for (i=0;i<extend_size;i=i+1) begin
                    temp_LLR_nxt[i] = {data_size{1'b0}};
                    temp_LLR1_nxt[i] = {data_size{1'b0}};
                end
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
            sys_reg  <= 27'b0;
            enc_reg  <= 27'b0;
            ext_reg  <= {LLR_size{1'b0}};
            for (i=0;i<extend_size;i=i+1) begin
                temp_LLR[i] <= {data_size{1'b0}};
                temp_LLR1[i] <= {data_size{1'b0}};
            end
            iter_counter <= 0;
            read_counter <= 0;
            dec1_begin <= 0;
            start_reg <= 0;
            out_reg <= {(input_size){1'b0}};
            for(j=0;j<7;j=j+1) begin
                vec0[j] <= 4'b0;
                vec1[j] <= 4'b0;
                vec2[j] <= 4'b0;
            end
        end
        else begin 
            state <= state_nxt;
            done  <= done_nxt;
            vec0_reg <= data_i[20:14];
            vec1_reg <= data_i[13:7];
            vec2_reg <= data_i[6:0];
            sys_reg  <= sys_reg_nxt;
            enc_reg  <= enc_reg_nxt;
            ext_reg  <= ext_reg_nxt;
            for (i=0;i<extend_size;i=i+1) begin
                temp_LLR[i] <= temp_LLR_nxt[i];
                temp_LLR1[i] <= temp_LLR1_nxt[i];
            end
            iter_counter <= iter_counter_nxt;
            read_counter <= read_counter_nxt;
            dec1_begin <= dec1_begin_nxt;
            start_reg <= start_i;
            out_reg <= out_reg_nxt;
            for(j=0;j<7;j=j+1) begin
                vec0[j] <= $signed(vec0_nxt[j]);
                vec1[j] <= $signed(vec1_nxt[j]);
                vec2[j] <= $signed(vec2_nxt[j]);
            end
        end
	end
endmodule