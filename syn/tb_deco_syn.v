`timescale 1ns/10ps
`define CYCLE    10
`define SDFFILE    "./deco.sdf"	      // Modify your sdf file name
`define INPUT    "../data/golden.dat"                         
`define EXPECT   "../data/actual.dat"
`define SDFFILE  "./deco.sdf"	          // Modify your sdf file name

module decoder_tb;

parameter ITERATE       = 10'd16;
parameter INPUT_SIZE    = 8'd160;

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

reg           clk, rst, over, stop, start;
wire          done_o;
reg   [20:0]   data;
wire  [4:0]  out;
reg   [4:0]  out_temp;   
reg   [15:0]  err;
reg   [83:0] input_buffer;
reg   [83:0] input_mem	[0:INPUT_SIZE-1];
reg   [4:0] out_mem	    [0:INPUT_SIZE-1];


integer       iter, counter, process, pattern_num, out_f, out_error_f;


Deco decorder0(
        .reset_n_i(rst), 
        .clk_p_i(clk),
        .start_i(start),
        .data_i(data),
        .data_o(out),
        .done_o(done_o)
    );       
   
`ifdef SDF
initial $sdf_annotate(`SDFFILE, decorder0);
`endif 
initial	$readmemb (`INPUT,  input_mem);
initial	$readmemb (`EXPECT, out_mem);

initial begin
    clk            = 1'b1;
    rst            = 1'b1;
    stop           = 1'b0;
    counter        = 0;
    iter           = 0;
    err            = 1'd0;
    over           = 1'b0;
    pattern_num    = 0; 
    #2.5 rst = 1'b0;                       
    #7.5 rst = 1'b1;

end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
	$fsdbDumpfile("decoder.fsdb");
    $fsdbDumpvars("+mda");
	// $dumpvars;
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
    if(counter == INPUT_SIZE-1 && done_o) begin
        out_temp = out_mem[counter];
        stop = 1'd1;
    end
    else if(counter < INPUT_SIZE) begin
        if(done_o) begin 
            start = 0;
            iter = 0;
            out_temp = out_mem[counter];
            counter = counter + 1;
            iter = 0;
        end
        else begin
            if(iter < 4) begin
                start       = 1;
                input_buffer= input_mem[(counter)];
                data        = input_buffer[(iter+1)*21-1-:21];
                iter        = iter+1;
            end
            else if(iter == 4) begin
                start = 1;
                // iter = ite;
            end
            else begin
                start = 0;
                iter  = 0;
            end
        end
    end
    else begin                                  
       iter = 0;
       counter = 0;
       start = 0;
    end
end

always @(posedge clk)begin
    if(done_o) begin
        if(out !== out_temp) begin
            $display("ERROR at %d:output %b !=expect %b ", pattern_num, out, out_temp);
            $fdisplay(out_error_f, "ERROR at %d:output %b !=expect %b ",pattern_num, out, out_temp);
            err = err + 1;
        end
        else begin
            $display("GREAT! You get %b and the output is %b", out, out_temp);
        end
        $fdisplay(out_f, "%d    output %b    expect %b ",pattern_num, out, out_temp);
        pattern_num = pattern_num + 1; 
        $display("---------------------------------------------\n");
    end
end
initial begin
      @(posedge stop)      
      if(stop) begin
            if(out !== out_temp) begin
                $display("ERROR at %d:output %b !=expect %b ", pattern_num, out, out_temp);
                $fdisplay(out_error_f, "ERROR at %d:output %b !=expect %b ",pattern_num, out, out_temp);
                err = err + 1;
            end
            else begin
                $display("GREAT! You get %b and the output is %b", out, out_temp);
            end
            $fdisplay(out_f, "%d    output %b    expect %b ",pattern_num, out, out_temp);
            pattern_num = pattern_num + 1; 
            $display("---------------------------------------------\n");
            $display("There are %d errors!\n", err);
            $display("The total accuracy is %d/%d\n", INPUT_SIZE-err, INPUT_SIZE);
            $display("---------------------------------------------\n");
      end
      else begin
        $display("---------------------------------------------\n");
        $display("-------------SIMULATION FAILED!!!------------\n");
        $display("---------------------------------------------\n");
        $display("---------------------------------------------\n");
    end
      $finish;
end
 
endmodule









