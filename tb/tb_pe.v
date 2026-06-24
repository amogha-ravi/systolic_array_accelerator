module tb_pe;

parameter DATA_WIDTH = 8;

reg clk;
reg rst;

reg valid_in;
reg clear_acc;

reg signed [DATA_WIDTH-1:0] a_in;
reg signed [DATA_WIDTH-1:0] b_in;

wire valid_out;

wire signed [DATA_WIDTH-1:0] a_out;
wire signed [DATA_WIDTH-1:0] b_out;

wire signed [(2*DATA_WIDTH)-1:0] sum_out;

wire overflow;

integer pass_count;

pe #(
    .DATA_WIDTH(DATA_WIDTH),
    .ACC_WIDTH(16)
) dut (
    .clk(clk),
    .rst(rst),

    .valid_in(valid_in),
    .clear_acc(clear_acc),

    .a_in(a_in),
    .b_in(b_in),

    .valid_out(valid_out),

    .a_out(a_out),
    .b_out(b_out),

    .sum_out(sum_out),

    .overflow(overflow)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    pass_count = 0;

    rst = 1;

    valid_in = 0;
    clear_acc = 0;

    a_in = 0;
    b_in = 0;

    #12;
    rst = 0;

    // ====================================
    // TEST 1
    // 3 × 4 for 3 cycles
    // Expect 36
    // ====================================

    clear_acc = 1;
    #10;
    clear_acc = 0;

    valid_in = 1;

    a_in = 3;
    b_in = 4;

    #30;

    valid_in = 0;

    #10;

    if (sum_out == 36) begin
        $display("TEST 1 PASS");
        pass_count = pass_count + 1;
    end
    else
        $display("TEST 1 FAIL: sum_out = %d", sum_out);

    // ====================================
    // TEST 2
    // Forwarding delay
    // ====================================

    a_in = 7;
    b_in = 9;

    valid_in = 1;

    #10;

    if (a_out == 7 && b_out == 9) begin
        $display("TEST 2 PASS");
        pass_count = pass_count + 1;
    end
    else
        $display("TEST 2 FAIL");

    // ====================================
    // TEST 3
    // clear_acc reset
    // ====================================

    clear_acc = 1;

    #10;

    clear_acc = 0;

    if (sum_out == 0) begin
        $display("TEST 3 PASS");
        pass_count = pass_count + 1;
    end
    else
        $display("TEST 3 FAIL");

    // ====================================
    // TEST 4
    // Negative arithmetic
    // (-5 × 3) × 4 cycles = -60
    // ====================================

    valid_in = 1;

    a_in = -5;
    b_in = 3;

    #40;

    valid_in = 0;

    #10;

    if (sum_out == -60) begin
        $display("TEST 4 PASS");
        pass_count = pass_count + 1;
    end
    else
        $display("TEST 4 FAIL: sum_out = %d", sum_out);

    // ====================================
    // TEST 5
    // Overflow detection
    // ====================================

    clear_acc = 1;
    #10;
    clear_acc = 0;

    valid_in = 1;

    a_in = 127;
    b_in = 127;

    #500;

    if (overflow == 1) begin
        $display("TEST 5 PASS");
        pass_count = pass_count + 1;
    end
    else
        $display("TEST 5 FAIL");

    // ====================================
    // FINAL SUMMARY
    // ====================================

    $display("----------------------");
    $display("TOTAL PASSED = %d / 5", pass_count);
    $display("----------------------");

    #20;

    $finish;

end

initial begin
    $dumpfile("sim/tb_pe.vcd");
    $dumpvars(0, tb_pe);
end

endmodule