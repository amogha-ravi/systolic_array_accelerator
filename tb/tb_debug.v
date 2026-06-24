`timescale 1ns/1ps

module tb_debug;

parameter N = 4;
parameter DATA_WIDTH = 8;
parameter ACC_WIDTH = 32;

reg clk;
reg rst;

reg valid_in;
reg clear_acc;

reg signed [N*DATA_WIDTH-1:0] a_bus;
reg signed [N*DATA_WIDTH-1:0] b_bus;

wire signed [(N*N*ACC_WIDTH)-1:0] c_bus;

wire output_valid;

///////////////////////////////////////////////////////////////
// DUT
///////////////////////////////////////////////////////////////

systolic_array #(
    .N(N),
    .DATA_WIDTH(DATA_WIDTH),
    .ACC_WIDTH(ACC_WIDTH)
)

dut(

    .clk(clk),
    .rst(rst),

    .valid_in(valid_in),
    .clear_acc(clear_acc),

    .a_bus(a_bus),
    .b_bus(b_bus),

    .c_bus(c_bus),

    .output_valid(output_valid)

);

///////////////////////////////////////////////////////////////
// clock
///////////////////////////////////////////////////////////////

initial clk = 0;

always #5 clk = ~clk;

///////////////////////////////////////////////////////////////
// waveform
///////////////////////////////////////////////////////////////

initial begin

    $dumpfile("sim/debug.vcd");

    $dumpvars(0,tb_debug);

end

///////////////////////////////////////////////////////////////
// wait helper
///////////////////////////////////////////////////////////////

task wait_cycles;

input integer n;

integer q;

begin

    for(q=0;q<n;q=q+1)

        @(posedge clk);

    #1;

end

endtask

///////////////////////////////////////////////////////////////
// Debug monitor
///////////////////////////////////////////////////////////////

always @(posedge clk)

begin

    $display(

    "t=%0t | a00=%0d a01=%0d a02=%0d a10=%0d a11=%0d a20=%0d | b00=%0d b01=%0d b02=%0d b10=%0d b11=%0d b20=%0d | c00=%0d c01=%0d c10=%0d c11=%0d",

    $time,

    dut.a_wire[0][0],
    dut.a_wire[0][1],
    dut.a_wire[0][2],

    dut.a_wire[1][0],
    dut.a_wire[1][1],

    dut.a_wire[2][0],

    dut.b_wire[0][0],
    dut.b_wire[0][1],
    dut.b_wire[0][2],

    dut.b_wire[1][0],
    dut.b_wire[1][1],

    dut.b_wire[2][0],

    dut.c_wire[0][0],
    dut.c_wire[0][1],

    dut.c_wire[1][0],
    dut.c_wire[1][1]

    );

end

///////////////////////////////////////////////////////////////
// MAIN
///////////////////////////////////////////////////////////////

initial begin

    rst = 1;

    valid_in = 0;

    clear_acc = 0;

    a_bus = 0;
    b_bus = 0;

    wait_cycles(5);

    rst = 0;

    ///////////////////////////////////////////////////////////
    // clear accumulators
    ///////////////////////////////////////////////////////////

    clear_acc = 1;

    wait_cycles(1);

    clear_acc = 0;

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
// MANUAL 2x2 SYSTOLIC TEST
//
// A = [1 2]
//     [3 4]
//
// B = [1 2]
//     [3 4]
//
// Expected:
//
// C = [7 10]
//     [15 22]
//
///////////////////////////////////////////////////////////

valid_in = 1;

///////////////////////////////////////////////////////////
// cycle 0
///////////////////////////////////////////////////////////

a_bus = {
    8'd0,
    8'd0,
    8'd0,
    8'd1
};

b_bus = {
    8'd0,
    8'd0,
    8'd0,
    8'd1
};

wait_cycles(1);

///////////////////////////////////////////////////////////
// cycle 1
///////////////////////////////////////////////////////////

a_bus = {
    8'd0,
    8'd0,
    8'd3,
    8'd2
};

b_bus = {
    8'd0,
    8'd0,
    8'd2,
    8'd3
};

wait_cycles(1);

///////////////////////////////////////////////////////////
// cycle 2
///////////////////////////////////////////////////////////

a_bus = {
    8'd0,
    8'd0,
    8'd4,
    8'd0
};

b_bus = {
    8'd0,
    8'd0,
    8'd4,
    8'd0
};

wait_cycles(1);

///////////////////////////////////////////////////////////
// drain
///////////////////////////////////////////////////////////

a_bus = 0;
b_bus = 0;

wait_cycles(10);

valid_in = 0;
    
    ///////////////////////////////////////////////////////////
    // drain pipeline
    ///////////////////////////////////////////////////////////

    wait_cycles(20);

    ///////////////////////////////////////////////////////////
    // print outputs
    ///////////////////////////////////////////////////////////

    $display("--------------------------------");

    $display(
    "c00=%0d c01=%0d c02=%0d c03=%0d",
    $signed(c_bus[(0*4+0)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(0*4+1)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(0*4+2)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(0*4+3)*ACC_WIDTH +: ACC_WIDTH])
    );

    $display(
    "c10=%0d c11=%0d c12=%0d c13=%0d",
    $signed(c_bus[(1*4+0)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(1*4+1)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(1*4+2)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(1*4+3)*ACC_WIDTH +: ACC_WIDTH])
    );

    $display(
    "c20=%0d c21=%0d c22=%0d c23=%0d",
    $signed(c_bus[(2*4+0)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(2*4+1)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(2*4+2)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(2*4+3)*ACC_WIDTH +: ACC_WIDTH])
    );

    $display(
    "c30=%0d c31=%0d c32=%0d c33=%0d",
    $signed(c_bus[(3*4+0)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(3*4+1)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(3*4+2)*ACC_WIDTH +: ACC_WIDTH]),
    $signed(c_bus[(3*4+3)*ACC_WIDTH +: ACC_WIDTH])
    );

    $display("--------------------------------");

    $finish;

end

endmodule