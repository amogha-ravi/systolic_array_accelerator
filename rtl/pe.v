module pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input clk,
    input rst,

    input valid_in,
    input clear_acc,

    input  signed [DATA_WIDTH-1:0] a_in,
    input  signed [DATA_WIDTH-1:0] b_in,

    output reg signed [DATA_WIDTH-1:0] a_out,
    output reg signed [DATA_WIDTH-1:0] b_out,

    output reg signed [ACC_WIDTH-1:0] sum_out
);

wire signed [(2*DATA_WIDTH)-1:0] mult;

assign mult = a_in * b_in;

wire signed [ACC_WIDTH-1:0] mult_ext;

assign mult_ext =
{{(ACC_WIDTH-2*DATA_WIDTH){mult[2*DATA_WIDTH-1]}},mult};

always @(posedge clk)

begin

    if(rst)

    begin

        a_out <= 0;
        b_out <= 0;

        sum_out <= 0;

    end

    else

    begin

        ///////////////////////////////////////////////////////
        // propagate
        ///////////////////////////////////////////////////////

        a_out <= a_in;

        b_out <= b_in;

        ///////////////////////////////////////////////////////
        // clear
        ///////////////////////////////////////////////////////

        if(clear_acc)

        begin

            sum_out <= 0;

        end

        ///////////////////////////////////////////////////////
        // MAC
        ///////////////////////////////////////////////////////

        else if(valid_in)

        begin

            sum_out <= sum_out + mult_ext;

        end

    end

end

endmodule