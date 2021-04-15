module decoder(
             clk_p_i,
             reset_n_i,
             data_i,
             data_o
             );

  /*========================IO declaration============================ */	  
      input           clk_p_i;
      input           reset_n_i;
      input   [53:0]  data_i;
      output  [15:0]  data_o;

  /* =======================REG & wire================================ */
	
	  

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

