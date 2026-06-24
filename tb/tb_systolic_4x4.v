module tb_systolic_4x4;

parameter N          = 4;
parameter DATA_WIDTH = 8;
parameter ACC_WIDTH  = 32;

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

dut (
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
// Clock
///////////////////////////////////////////////////////////////

initial clk = 0;

always #5 clk = ~clk;

///////////////////////////////////////////////////////////////
// Waveform
///////////////////////////////////////////////////////////////

initial begin

    $dumpfile("sim/tb_systolic_4x4.vcd");

    $dumpvars(0, tb_systolic_4x4);

end

///////////////////////////////////////////////////////////////
// Bus packing tasks
///////////////////////////////////////////////////////////////

task set_a;

input [7:0] r0,r1,r2,r3;

begin

    a_bus[(0*DATA_WIDTH)+:DATA_WIDTH] = r0;
    a_bus[(1*DATA_WIDTH)+:DATA_WIDTH] = r1;
    a_bus[(2*DATA_WIDTH)+:DATA_WIDTH] = r2;
    a_bus[(3*DATA_WIDTH)+:DATA_WIDTH] = r3;

end

endtask


task set_b;

input [7:0] c0,c1,c2,c3;

begin

    b_bus[(0*DATA_WIDTH)+:DATA_WIDTH] = c0;
    b_bus[(1*DATA_WIDTH)+:DATA_WIDTH] = c1;
    b_bus[(2*DATA_WIDTH)+:DATA_WIDTH] = c2;
    b_bus[(3*DATA_WIDTH)+:DATA_WIDTH] = c3;

end

endtask

///////////////////////////////////////////////////////////////
// Wait helper
///////////////////////////////////////////////////////////////

task wait_cycles;

input integer n;

integer k;

begin

    for(k=0;k<n;k=k+1)

        @(posedge clk);

    #1;

end

endtask

///////////////////////////////////////////////////////////////
// Checker
///////////////////////////////////////////////////////////////

integer pass_count;
integer fail_count;

task check;

input integer row;
input integer col;
input integer expected;

integer got;

begin

    got =
    $signed(
    c_bus[((row*N+col)*ACC_WIDTH)+:ACC_WIDTH]
    );

    if(got === expected)

    begin

        $display(
        "PASS c[%0d][%0d] = %0d",
        row,
        col,
        got
        );

        pass_count = pass_count + 1;

    end

    else

    begin

        $display(
        "FAIL c[%0d][%0d] expected=%0d got=%0d",
        row,
        col,
        expected,
        got
        );

        fail_count = fail_count + 1;

    end

end

endtask

///////////////////////////////////////////////////////////////
// Main
///////////////////////////////////////////////////////////////

initial begin

    pass_count = 0;
    fail_count = 0;

    rst       = 1;
    valid_in  = 0;
    clear_acc = 0;

    a_bus = 0;
    b_bus = 0;

    wait_cycles(3);

    rst = 0;

    ///////////////////////////////////////////////////////////
    // Clear accumulators
    ///////////////////////////////////////////////////////////

    clear_acc = 1;

    wait_cycles(1);

    clear_acc = 0;

    ///////////////////////////////////////////////////////////
    // Begin feed
    ///////////////////////////////////////////////////////////

    valid_in = 1;

    ///////////////////////////////////////////////////////////
    // cycle 0
    ///////////////////////////////////////////////////////////

    set_a(1,0,0,0);
    set_b(1,0,0,0);

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
    // cycle 1
    ///////////////////////////////////////////////////////////

    set_a(2,5,0,0);
    set_b(0,0,0,0);

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
    // cycle 2
    ///////////////////////////////////////////////////////////

    set_a(3,6,1,0);
    set_b(0,1,0,0);

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
    // cycle 3
    ///////////////////////////////////////////////////////////

    set_a(4,7,1,2);
    set_b(0,0,0,0);

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
    // cycle 4
    ///////////////////////////////////////////////////////////

    set_a(0,8,1,2);
    set_b(0,0,1,0);

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
    // cycle 5
    ///////////////////////////////////////////////////////////

    set_a(0,0,1,2);
    set_b(0,0,0,0);

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
    // cycle 6
    ///////////////////////////////////////////////////////////

    set_a(0,0,0,2);
    set_b(0,0,0,1);

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
    // cycle 7
    ///////////////////////////////////////////////////////////

    set_a(0,0,0,0);
    set_b(0,0,0,0);

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
    // cycle 8
    ///////////////////////////////////////////////////////////

    set_a(0,0,0,0);
    set_b(0,0,0,0);

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
    // cycle 9
    ///////////////////////////////////////////////////////////

    set_a(0,0,0,0);
    set_b(0,0,0,0);

    wait_cycles(1);

    ///////////////////////////////////////////////////////////
    // Stop feeding
    ///////////////////////////////////////////////////////////

    valid_in = 0;

    ///////////////////////////////////////////////////////////
    // Drain pipeline
    ///////////////////////////////////////////////////////////

    wait_cycles(10);

    ///////////////////////////////////////////////////////////
    // Results
    ///////////////////////////////////////////////////////////

    $display("------------------------------------------------");

    $display("output_valid = %b", output_valid);

    $display("------------------------------------------------");

    $display(
    "c00=%0d c01=%0d c02=%0d c03=%0d",

    $signed(c_bus[(0*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(1*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(2*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(3*ACC_WIDTH)+:ACC_WIDTH])

    );

    $display(
    "c10=%0d c11=%0d c12=%0d c13=%0d",

    $signed(c_bus[(4*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(5*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(6*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(7*ACC_WIDTH)+:ACC_WIDTH])

    );

    $display(
    "c20=%0d c21=%0d c22=%0d c23=%0d",

    $signed(c_bus[(8*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(9*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(10*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(11*ACC_WIDTH)+:ACC_WIDTH])

    );

    $display(
    "c30=%0d c31=%0d c32=%0d c33=%0d",

    $signed(c_bus[(12*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(13*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(14*ACC_WIDTH)+:ACC_WIDTH]),
    $signed(c_bus[(15*ACC_WIDTH)+:ACC_WIDTH])

    );

    $display("------------------------------------------------");

    ///////////////////////////////////////////////////////////
    // Self-check
    ///////////////////////////////////////////////////////////

    check(0,0,1);
    check(0,1,2);
    check(0,2,3);
    check(0,3,4);

    check(1,0,5);
    check(1,1,6);
    check(1,2,7);
    check(1,3,8);

    check(2,0,1);
    check(2,1,1);
    check(2,2,1);
    check(2,3,1);

    check(3,0,2);
    check(3,1,2);
    check(3,2,2);
    check(3,3,2);

    $display("------------------------------------------------");

    $display("PASSED: %0d / 16", pass_count);

    $display("FAILED: %0d / 16", fail_count);

    $display("------------------------------------------------");

    if(fail_count == 0)

        $display("ALL 16 OUTPUTS CORRECT");

    else

        $display("FAILURES DETECTED");

    $finish;

end

endmodule