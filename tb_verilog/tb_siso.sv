`timescale 1ns/10ps
`define CYCLE    10

module siso_tb;

parameter ITERATE       = 10'd16;
parameter INPUT_SIZE    = 3'd5;

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

reg           clk, rst, over, stop;
reg   [7:0]   data;
wire  [15:0]  out;
reg   [15:0]  out_temp;       

integer       iter, counter;


Siso siso0(
        .i_rst_n(rst), 
        .i_clk(clk),
        .i_start(start),
        .i_data(data),
        .o_data(out)
    );       
   

initial begin
   clk         = 1'b1;
   rst         = 1'b1;
   stop        = 1'b0;
   counter     = 0;
   data        = data_arr[0];
    #2.5 reset=1'b0;                       
    #2.5 reset=1'b1;

end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
	$dumpfile("decoder.fsdb");
	$dumpvars;
end


always @(negedge clk)begin
    if(counter < INPUT_SIZE) begin
        out_temp    = answer_arr[counter];
        data        = data_arr[counter+1];
        counter     = counter+1;
    end
    else begin                                  
       counter = 1;
       stop = 1'd1;
    end
end

always @(posedge clk)begin
    if(stop) begin
        if(out !== out_temp) begin
            $display("ERROR at %d:output %h !=expect %h ", out, out_temp);
        end
        else begin
            $display("GREAT! You get %d and the output is %d", out, out_temp);
        end
        $display("---------------------------------------------\n");
    end
    else begin
        $display("---------------------------------------------\n");
        $display("-------------SIMULATION FUCK!!!-------------\n");
        $display("-------------------FAIL-------------------\n");
        $display("---------------------------------------------\n");
    end
    $finish
end
 
endmodule



















