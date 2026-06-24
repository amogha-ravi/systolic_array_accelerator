module systolic_array #(
    parameter N = 4,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 32
)(
    input clk,
    input rst,

    input valid_in,
    input clear_acc,

    input signed [N*DATA_WIDTH-1:0] a_bus,
    input signed [N*DATA_WIDTH-1:0] b_bus,

    output signed [(N*N*ACC_WIDTH)-1:0] c_bus,

    output output_valid
);

///////////////////////////////////////////////////////////////
// Internal mesh wires
///////////////////////////////////////////////////////////////

wire signed [DATA_WIDTH-1:0]
a_wire [0:N-1][0:N];

wire signed [DATA_WIDTH-1:0]
b_wire [0:N][0:N-1];

wire signed [ACC_WIDTH-1:0]
c_wire [0:N-1][0:N-1];

///////////////////////////////////////////////////////////////
// Inject TB inputs directly
///////////////////////////////////////////////////////////////

genvar x;

generate

for(x=0;x<N;x=x+1)

begin:INPUTS

assign a_wire[x][0] =
a_bus[(x*DATA_WIDTH)+:DATA_WIDTH];

assign b_wire[0][x] =
b_bus[(x*DATA_WIDTH)+:DATA_WIDTH];

end

endgenerate

///////////////////////////////////////////////////////////////
// PE mesh
///////////////////////////////////////////////////////////////

genvar i,j;

generate

for(i=0;i<N;i=i+1)

begin:ROWS

for(j=0;j<N;j=j+1)

begin:COLS

pe #(
    .DATA_WIDTH(DATA_WIDTH),
    .ACC_WIDTH(ACC_WIDTH)
)

pe_inst(

    .clk(clk),
    .rst(rst),

    ///////////////////////////////////////////////////////////
    // IMPORTANT
    ///////////////////////////////////////////////////////////

    .valid_in(valid_in),

    .clear_acc(clear_acc),

    .a_in(a_wire[i][j]),
    .b_in(b_wire[i][j]),

    .a_out(a_wire[i][j+1]),
    .b_out(b_wire[i+1][j]),

    .sum_out(c_wire[i][j])

);

end

end

endgenerate

///////////////////////////////////////////////////////////////
// Pack outputs
///////////////////////////////////////////////////////////////

genvar m,n;

generate

for(m=0;m<N;m=m+1)

begin:PACK_ROW

for(n=0;n<N;n=n+1)

begin:PACK_COL

assign c_bus[
((m*N+n)*ACC_WIDTH)+:ACC_WIDTH
]

=

c_wire[m][n];

end

end

endgenerate

///////////////////////////////////////////////////////////////
// Simple output timing
///////////////////////////////////////////////////////////////

reg [15:0] cycle_counter;

always @(posedge clk)

begin

    if(rst)

    begin

        cycle_counter <= 0;

    end

    else if(valid_in)

    begin

        cycle_counter <= cycle_counter + 1;

    end

end

assign output_valid =
(cycle_counter >= (2*N-1));

endmodule