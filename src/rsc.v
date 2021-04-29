module rsc(
             clk_p_i,
             reset_n_i,
             data_i,
             data_sys,
             data_enc
             );

  /*========================IO declaration============================ */	  
      input           clk_p_i;
      input           reset_n_i;
      input   [15:0]  data_i;
      output  [15:0]  data_sys;
      output  [15:0]  data_enc;


  /* =======================REG & wire================================ */
      reg     [17:0]  sys_r;
      reg     [17:0]  sys_w;
      reg     [17:0]  enc_r;
      reg     [17:0]  enc_w;
      reg     [1:0]   state_r;
      reg     [1:0]   state_w;
      wire    [1:0]   rotate_w;
      reg     [1:0]   rotate_r;
      reg     [11:0]  counter_r;
      wire    [11:0]  counter_w;

  /* ====================Combinational Part================== */
  //next-state logic //todo
      
          
			  
  // output logic
    always@ (*)
      begin
          
      end

  // state transition
    always@ (*)
      begin
          case(state_r)
              2'b00:
                rotate_w = 2'b00;
                state_w = 2'b01;
              2'b01: 
                if(counter_r < 16) begin
                  enc_w[15-counter_r] = rotate_r[0] ^ data_i[15-counter_r]
                  rotate_w = {rotate_r[0] ^ data_i[15-counter_r], rotate_w[0]}
                  counter_w = counter_r + 12'b1;
                end
                else begin
                  state_w = 2'b10;
                  counter_w = 12'b0;
                end
              2'b10:
                  sys_w = {data_i, rotate_w[0], rotate_w[1]};
                  
                  
           default:

          endcase
      end
   			  //todo
  /* ====================Sequential Part=================== */
    always@(posedge clk_p_i or negedge reset_n_i)
    begin
        if (reset_n_i == 1'b0)
            begin  
                state_r <= 2'b00;
                rotate_r <= 2'b00;
                counter_r <= 12'd0;
            end
        else
            begin 
                state_r <= state_w;
                rotate_r <= rotate_w;
                counter_r <= counter_w;
            end
    end
  /* ====================================================== */

endmodule

