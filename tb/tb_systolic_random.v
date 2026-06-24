`timescale 1ns/1ps

module tb_systolic_random;

parameter N = 4;
parameter DATA_WIDTH = 8;
parameter ACC_WIDTH = 32;
parameter NUM_TESTS = 500;

///////////////////////////////////////////////////////////////
// DUT signals
///////////////////////////////////////////////////////////////

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
// waveform dump
///////////////////////////////////////////////////////////////

initial begin

    $dumpfile("sim/random.vcd");

    $dumpvars(0,tb_systolic_random);

end

///////////////////////////////////////////////////////////////
// matrix storage
///////////////////////////////////////////////////////////////

reg signed [DATA_WIDTH-1:0]
A [0:N-1][0:N-1];

reg signed [DATA_WIDTH-1:0]
B [0:N-1][0:N-1];

reg signed [ACC_WIDTH-1:0]
CEXP [0:N-1][0:N-1];

///////////////////////////////////////////////////////////////
// bookkeeping
///////////////////////////////////////////////////////////////

integer total_pass;
integer total_fail;

integer test_num;

integer fh;
integer ret;

reg [8*8-1:0] tag;

integer v0,v1,v2,v3;

integer i,j;

integer got;
integer exp;

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
// feed matrix wavefront
///////////////////////////////////////////////////////////////

task feed_matrix;

integer kk,rr,cc;

begin

    valid_in = 1;

    ///////////////////////////////////////////////////////////
    // diagonal wavefront
    ///////////////////////////////////////////////////////////

    for(kk=0;kk<(2*N-1);kk=kk+1)

    begin

        a_bus = 0;
        b_bus = 0;

        ///////////////////////////////////////////////////////
        // A wavefront
        ///////////////////////////////////////////////////////

        for(rr=0;rr<N;rr=rr+1)

        begin

            if((kk-rr)>=0 && (kk-rr)<N)

            begin

                a_bus[
                    (rr*DATA_WIDTH)+:DATA_WIDTH
                ]
                =
                A[rr][kk-rr];

            end

        end

        ///////////////////////////////////////////////////////
        // B wavefront
        ///////////////////////////////////////////////////////

        for(cc=0;cc<N;cc=cc+1)

        begin

            if((kk-cc)>=0 && (kk-cc)<N)

            begin

                b_bus[
                    (cc*DATA_WIDTH)+:DATA_WIDTH
                ]
                =
                B[kk-cc][cc];

            end

        end

        @(posedge clk);
        #1;

    end

    ///////////////////////////////////////////////////////////
    // keep valid active while data drains
    ///////////////////////////////////////////////////////////

    a_bus = 0;
    b_bus = 0;

    repeat(2*N)

    begin

        @(posedge clk);
        #1;

    end

    valid_in = 0;

end

endtask
///////////////////////////////////////////////////////////////
// MAIN
///////////////////////////////////////////////////////////////

initial begin

    total_pass = 0;
    total_fail = 0;

    rst = 1;

    valid_in = 0;

    clear_acc = 0;

    a_bus = 0;
    b_bus = 0;

    ///////////////////////////////////////////////////////////
    // reset
    ///////////////////////////////////////////////////////////

    wait_cycles(5);

    rst = 0;

    wait_cycles(2);

    ///////////////////////////////////////////////////////////
    // open vector file
    ///////////////////////////////////////////////////////////

    fh = $fopen("vectors/test_vectors.mem","r");

    if(fh == 0)

    begin

        $display("ERROR opening vector file");

        $finish;

    end

    ///////////////////////////////////////////////////////////
    // main test loop
    ///////////////////////////////////////////////////////////

    for(test_num=0;test_num<NUM_TESTS;test_num=test_num+1)

    begin

        ///////////////////////////////////////////////////////
        // read A
        ///////////////////////////////////////////////////////

        for(i=0;i<N;i=i+1)

        begin

            ret = $fscanf(
            fh,
            "%s %d %d %d %d\n",
            tag,
            v0,v1,v2,v3
            );

            A[i][0]=v0;
            A[i][1]=v1;
            A[i][2]=v2;
            A[i][3]=v3;

        end

        ///////////////////////////////////////////////////////
        // read B
        ///////////////////////////////////////////////////////

        for(i=0;i<N;i=i+1)

        begin

            ret = $fscanf(
            fh,
            "%s %d %d %d %d\n",
            tag,
            v0,v1,v2,v3
            );

            B[i][0]=v0;
            B[i][1]=v1;
            B[i][2]=v2;
            B[i][3]=v3;

        end

        ///////////////////////////////////////////////////////
        // read expected C
        ///////////////////////////////////////////////////////

        for(i=0;i<N;i=i+1)

        begin

            ret = $fscanf(
            fh,
            "%s %d %d %d %d\n",
            tag,
            v0,v1,v2,v3
            );

            CEXP[i][0]=v0;
            CEXP[i][1]=v1;
            CEXP[i][2]=v2;
            CEXP[i][3]=v3;

        end

        ///////////////////////////////////////////////////////
        // consume END line
        ///////////////////////////////////////////////////////

        ret = $fscanf(fh,"%s\n",tag);

        ///////////////////////////////////////////////////////
        // clear accumulators
        ///////////////////////////////////////////////////////

        clear_acc = 1;

        wait_cycles(1);

        clear_acc = 0;

        wait_cycles(1);

        ///////////////////////////////////////////////////////
        // feed matrix
        ///////////////////////////////////////////////////////

        feed_matrix;

        ///////////////////////////////////////////////////////
        // wait for pipeline drain
        ///////////////////////////////////////////////////////

        wait_cycles(10);

        ///////////////////////////////////////////////////////
        // compare outputs
        ///////////////////////////////////////////////////////

        for(i=0;i<N;i=i+1)

        begin

            for(j=0;j<N;j=j+1)

            begin

                got =
                $signed(
                c_bus[
                ((i*N+j)*ACC_WIDTH)
                +:ACC_WIDTH
                ]
                );

                exp = CEXP[i][j];

                if(got === exp)

                begin

                    total_pass =
                    total_pass + 1;

                end

                else

                begin

                    total_fail =
                    total_fail + 1;

                    if(total_fail < 40)

                    begin

                        $display(
                        "FAIL test=%0d c[%0d][%0d] exp=%0d got=%0d",
                        test_num,
                        i,
                        j,
                        exp,
                        got
                        );

                    end

                end

            end

        end

    end

    ///////////////////////////////////////////////////////////
    // final report
    ///////////////////////////////////////////////////////////

    $display("================================");

    $display(
    "TOTAL PASS : %0d / %0d",
    total_pass,
    NUM_TESTS*N*N
    );

    $display(
    "TOTAL FAIL : %0d / %0d",
    total_fail,
    NUM_TESTS*N*N
    );

    $display("================================");

    if(total_fail == 0)

        $display("ALL TESTS PASSED");

    else

        $display("FAILURES DETECTED");

    $finish;

end

endmodule