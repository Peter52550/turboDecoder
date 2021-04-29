module encoder(
             clk_p_i,
             reset_n_i,
             data_i,
             data_o
             );

  /*========================IO declaration============================ */	  
      input           clk_p_i;
      input           reset_n_i;
      input   [15:0]  data_i;
      input   [15:0]  interleaver_i;
      output  [53:0]  data_o;

  /* =======================REG & wire================================ */
      reg     [2:0]   state_w;
      reg     [2:0]   state_r;
      reg     [15:0]  interleaved;

  /* ====================Combinational Part================== */
  //next-state logic //todo
    SISO()
          
			  
  // output logic
    always@ (*)
      begin
          
      end

  // state transition
    always@ (*)
      begin
          case(state_r)
              2'b00:
                
              2'b01: 
              2'b10: 
              2'b11:  
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
            end
        else
            begin 
                state_r <= state_w;
            end
    end
  /* ====================================================== */

endmodule

