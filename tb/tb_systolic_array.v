module tb_systolic_array;

parameter DATA_WIDTH=8;
parameter ACC_WIDTH=32;

reg clk;
reg rst;
reg clear_acc;
reg valid_in;

reg signed [DATA_WIDTH-1:0] a0,a1;
reg signed [DATA_WIDTH-1:0] b0,b1;

wire signed [ACC_WIDTH-1:0] sum00;
wire signed [ACC_WIDTH-1:0] sum01;
wire signed [ACC_WIDTH-1:0] sum10;
wire signed [ACC_WIDTH-1:0] sum11;

integer pass_count;
integer test_num;

integer file;
integer r;

integer A00,A01,A10,A11;
integer B00,B01,B10,B11;

integer EXP00,EXP01,EXP10,EXP11;


systolic_array #(
.N(2),
.DATA_WIDTH(DATA_WIDTH),
.ACC_WIDTH(ACC_WIDTH)
)
dut(
.clk(clk),
.rst(rst),
.clear_acc(clear_acc),
.valid_in(valid_in),

.a0(a0),
.a1(a1),

.b0(b0),
.b1(b1),

.sum00(sum00),
.sum01(sum01),
.sum10(sum10),
.sum11(sum11)
);


always #5 clk=~clk;


initial begin

$dumpfile("sim/tb_systolic.vcd");
$dumpvars(0,tb_systolic_array);

clk=0;

rst=1;

clear_acc=0;

valid_in=0;

a0=0;
a1=0;

b0=0;
b1=0;

pass_count=0;

file=$fopen(
"vectors/2x2_tests.txt",
"r"
);

if(file==0)
begin
    $display("ERROR opening vector file");
    $finish;
end

#20;
rst=0;


for(
test_num=0;
test_num<200;
test_num=test_num+1
)

begin

r=$fscanf(

file,

"%d %d %d %d %d %d %d %d %d %d %d %d\n",

A00,A01,A10,A11,
B00,B01,B10,B11,
EXP00,EXP01,EXP10,EXP11

);

clear_acc=1;

#10;

clear_acc=0;


valid_in=1;


// cycle1

a0=A00;
a1=0;

b0=B00;
b1=0;

#10;


// cycle2

a0=A01;
a1=A10;

b0=B10;
b1=B01;

#10;


// cycle3

a0=0;
a1=A11;

b0=0;
b1=B11;

#10;


valid_in=0;

a0=0;
a1=0;

b0=0;
b1=0;


// wait 5 cycles:
// 2N−1 required + extra margin

#50;


if(

(sum00==EXP00)

&&

(sum01==EXP01)

&&

(sum10==EXP10)

&&

(sum11==EXP11)

)

begin

pass_count=
pass_count+1;

end

else

begin

$display(
"FAIL TEST=%0d",
test_num
);

$display(

"Expected: %0d %0d %0d %0d",

EXP00,
EXP01,
EXP10,
EXP11

);

$display(

"Got: %0d %0d %0d %0d",

sum00,
sum01,
sum10,
sum11

);

end

end


$display("----------------");

$display(
"PASS: %0d / 200",
pass_count
);

$display("----------------");

$fclose(file);

$finish;

end

endmodule