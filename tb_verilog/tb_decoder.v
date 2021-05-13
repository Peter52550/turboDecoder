`timescale 1ns/10ps
`define CYCLE    10
`define INPUT    "../data/golden.dat"                         
`define EXPECT   "../data/ans.dat"

module decoder_tb;

parameter ITERATE       = 10'd16;
parameter INPUT_SIZE    = 4'd10;

parameter  [15:0] data_arr [0:4] = '{
        16'b1111_0010_1100_1111,
        16'b1111_0110_0100_1111,
        16'b1000_0011_1100_0001,
        16'b1001_1100_0101_1000,
        16'b0110_1010_0100_1100
    };
parameter  [15:0] answer_arr [0:4] = '{
        16'b1111_0010_1100_1111,
        16'b1111_0110_0100_1111,
        16'b1000_0011_1100_0001,
        16'b1001_1100_0101_1000,
        16'b0110_1010_0100_1100
    };

reg           clk, rst, over, stop, start, done;
reg   [83:0]   data;
wire  [4:0]  out;
reg   [4:0]  out_temp;   
reg   [15:0]  err;

integer       iter, counter, process, pattern_num;


Decorder decorder0(
        .i_rst_n(rst), 
        .i_clk(clk),
        .i_start(start),
        .i_data(data),
        .o_data(out)
        .done(done)
    );       
   
initial	$readmemh (`INPUT,  input_mem);
initial	$readmemh (`EXPECT, out_mem);

initial begin
    clk         = 1'b1;
    rst         = 1'b1;
    stop        = 1'b0;
    counter     = 0;
    iter        = 0;
    err         = 1'd0;
    over        = 1'b0;
    pattern_num = 0; 
    #2.5 reset=1'b0;                       
    #2.5 reset=1'b1;

end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
	$dumpfile("decoder.fsdb");
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
            start       = 1;
            data        = input_mem[(counter+1)*7: counter*7];
            iter        = iter + 1;
            counter     = counter+1;
        end
        else begin
            start = 0;
        end
        out_temp    = out_mem[counter];
        if(done) begin
            counter  = counter + 1;
            iter = 0;
        end
    end
    else begin                                  
       iter = 0;
       counter = 0;
       stop = 1'd1;
    end
end

always @(posedge clk)begin
    if(done) begin
        if(out !== out_temp) begin
            $display("ERROR at %d:output %d !=expect %d ", pattern_num, out, out_temp);
            $fdisplay(out_error_f, "ERROR at %d:output %h !=expect %h ",pattern_num, out, out_temp);
            err = err + 1;
        end
        else begin
            $display("GREAT! You get %d and the output is %d", out, out_temp);
        end
        $fdisplay(out_f, "%d    output %h    expect %h ",pattern_num, out, out_temp);
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









