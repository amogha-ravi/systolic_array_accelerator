import random

NUM_TESTS = 200

ACC_WIDTH = 32

SAT_MAX=(2**(ACC_WIDTH-1))-1
SAT_MIN=-(2**(ACC_WIDTH-1))


def saturate(x):

    if x>SAT_MAX:
        return SAT_MAX

    if x<SAT_MIN:
        return SAT_MIN

    return x


outfile=open(
"vectors/2x2_tests.txt",
"w"
)

for _ in range(NUM_TESTS):

    A00=random.randint(-8,7)
    A01=random.randint(-8,7)

    A10=random.randint(-8,7)
    A11=random.randint(-8,7)

    B00=random.randint(-8,7)
    B01=random.randint(-8,7)

    B10=random.randint(-8,7)
    B11=random.randint(-8,7)


    C00=saturate(
        A00*B00+A01*B10
    )

    C01=saturate(
        A00*B01+A01*B11
    )

    C10=saturate(
        A10*B00+A11*B10
    )

    C11=saturate(
        A10*B01+A11*B11
    )


    outfile.write(

f"{A00} {A01} {A10} {A11} "
f"{B00} {B01} {B10} {B11} "
f"{C00} {C01} {C10} {C11}\n"

)

outfile.close()

print("Generated 200 vectors")