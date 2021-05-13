`timescale 1ns/10ps
`define CYCLE    10
`define INPUT       "../data/golden.dat"                         
`define EXPECT      "../data/ans.dat"    


module siso_tb;

parameter ITERATE       = 10'd16;
parameter INPUT_SIZE    = 4'd10;

// parameter  [15:0] data_arr [0:4] = '{
//         16'b1111_0010_1100_1111,
//         16'b1111_0110_0100_1111,
//         16'b1000_0011_1100_0001,
//         16'b1001_1100_0101_1000,
//         16'b0110_1010_0100_1100
//     };
// parameter  [15:0] answer_arr [0:4] = '{
//         16'b1111_0010_1100_1111,
//         16'b1111_0110_0100_1111,
//         16'b1000_0011_1100_0001,
//         16'b1001_1100_0101_1000,
//         16'b0110_1010_0100_1100
//     };

reg           clk, rst, over, stop;
reg   [83:0]   data;
reg   [6:0]   sys;
reg   [6:0]   enc;
reg   [9:0]   ext;
wire  [9:0]   out;
reg   [9:0]  out_temp;       
reg   [15:0]  err;
reg            done;

reg   [83:0]   input_mem     ;
reg   [9:0]    out_mem       [0:INPUT_SIZE-1];

integer  iter, counter;


Siso siso0(
        .clk_i(clk),
        .rst_n_i(rst), 
        .read_en_i(en),
        .sys_i(sys),
        .enc_i(enc),
        .ext_i(ext),
        .data_o(out),
        .done(done),
    );       
   
initial	$readmemh (`INPUT,  input_mem);
initial	$readmemh (`EXPECT, out_mem);

initial begin
   clk         = 1'b1;
   rst         = 1'b1;
   stop        = 1'b0;
   counter     = 0;
   done        = 0;
   iter        = 0;
//    data        = data_arr[0];
   pattern_num = 0; 
    #2.5 reset=1'b0;                       
    #2.5 reset=1'b1;

end


always begin #(`CYCLE/2) clk = ~clk; end

initial begin
	$dumpfile("siso.fsdb");
	$dumpvars;
    out_f = $fopen("out.dat");
    out_error_f = $fopen("out_error.dat");
    if (out_f == 0) begin
        $display("Output file open error !");
        $finish;
    end
    else if (out_error_f == 0) begin
        $display("Output error file open error !");
        $finish;
    end
end


always @(negedge clk)begin
    if(counter < INPUT_SIZE) begin
        if(iter < 4) begin
            // data        = input_mem[counter+1];
            sys         = input_mem[counter][(83-iter*7):(77-iter*7)];
            enc         = input_mem[counter][(55-iter*7):(49-iter*7)];
            ext         = input_mem[counter][(27-iter*7):(21-iter*7)];
            iter        = iter + 1;
        end
        else begin
            counter     = counter+1;
            iter        = 0;
            
        end
        if(counter > 0)
            out_temp    = out_mem[counter-1];         
    end
    else begin                                  
       counter = 0;
       stop = 1'd1;
    end
end

always @(posedge clk)begin
    if(done) begin
        if(out !== out_temp) begin
            $display("ERROR at %d:output %d !=expect %d ", pattern_num, out, out_temp);
            $fdisplay(out_error_f, "ERROR at %d:output %h !=expect %h ",pattern_num-2, out, out_temp);
            err = err + 1;
        end
        else begin
            $display("GREAT! You get %d and the output is %d", out, out_temp);
        end
        $fdisplay(out_f, "%d    output %h    expect %h ",pattern_num-2, out, out_temp);
        pattern_num = pattern_num + 1; 
        $display("---------------------------------------------\n");
    end
end
initial begin
      @(posedge stop)      
      if(stop) begin
        $display("---------------------------------------------\n");
        $display("There are %d errors!\n", err);
        $display("The total accuracy is %d/%d\n", err, INPUT_SIZE);
        $display("---------------------------------------------\n");
      end
      else begin
        $display("---------------------------------------------\n");
        $display("-------------SIMULATION FUCK!!!-------------\n");
        $display("-------------------FAIL-------------------\n");
        $display("---------------------------------------------\n");
    end
      $finish;
end
 
endmodule
 
endmodule



















