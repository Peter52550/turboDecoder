module decoder(
             clk_p_i,
             reset_n_i,
             data_i,
             data_o
             );

  /*========================IO declaration============================ */	 
      parameter MAX_ITER = 16;
      
      input             clk_p_i;
      input             reset_n_i;
      input   [215:0]   data_i;
      output  [15:0]    data_o;

  /* =======================REG & wire================================ */
      wire    [71:0]    enc_w;
      reg     [71:0]    enc_r;
      wire    [71:0]    sys_w;
      reg     [71:0]    sys_r;
      wire    [71:0]    ext_w;
      reg     [71:0]    ext_r;

      reg     [3:0]     state_r;
      reg     [3:0]     state_w;
	  

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
              4'b0:
                enc_w = data_i[215:144];
                sys_w = data_i[143:72];
                ext_w = data_i[71:0];
                state_w = data
           default:
        
          endcase
      end
   			  //todo
  /* ====================Sequential Part=================== */
    always@(posedge clk_p_i or negedge reset_n_i)
    begin
        if (reset_n_i == 1'b0)
            begin  
                enc_r <= 71'b0;
                ext_r <= 71'b0;
                sys_r <= 71'b0;
                state_r <= state_w;
            end
        else
            begin 
                enc_r <= enc_w;
                ext_r <= ext_w;
                sys_r <= sys_w;
                state_r <= 4'b0;
            end
    end
  /* ====================================================== */

endmodule

