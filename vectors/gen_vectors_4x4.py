import random

NUM_TESTS = 500

ACC_WIDTH=32

SAT_MAX=(2**(ACC_WIDTH-1))-1
SAT_MIN=-(2**(ACC_WIDTH-1))


def saturate(x):

    if x>SAT_MAX:
        return SAT_MAX

    if x<SAT_MIN:
        return SAT_MIN

    return x


def matmul(A,B):

    C=[[0]*4 for _ in range(4)]

    for i in range(4):

        for j in range(4):

            s=0

            for k in range(4):

                s+=A[i][k]*B[k][j]

            C[i][j]=saturate(s)

    return C


f=open(
"vectors/4x4_tests.txt",
"w"
)


###################################################
# edge cases first
###################################################

cases=[]


# all zero

cases.append(

(
[[0]*4 for _ in range(4)],
[[0]*4 for _ in range(4)]

)

)


# identity

I=[

[1,0,0,0],
[0,1,0,0],
[0,0,1,0],
[0,0,0,1]

]

R=[

[random.randint(-8,7)
for _ in range(4)]

for _ in range(4)

]

cases.append((I,R))


# all max

cases.append(

(
[[127]*4 for _ in range(4)],
[[127]*4 for _ in range(4)]

)

)


# all min

cases.append(

(
[[-128]*4 for _ in range(4)],
[[-128]*4 for _ in range(4)]

)

)


# alternating

A=[]

for i in range(4):

    row=[]

    for j in range(4):

        if (i+j)%2:
            row.append(127)

        else:
            row.append(-128)

    A.append(row)

cases.append((A,A))


###################################################
# random tests
###################################################

while len(cases)<NUM_TESTS:

    A=[

    [random.randint(-8,7)
    for _ in range(4)]

    for _ in range(4)

    ]

    B=[

    [random.randint(-8,7)
    for _ in range(4)]

    for _ in range(4)

    ]

    cases.append((A,B))


###################################################
# write file
###################################################

for A,B in cases:

    C=matmul(A,B)

    nums=[]

    for r in A:
        nums+=r

    for r in B:
        nums+=r

    for r in C:
        nums+=r


    f.write(

    " ".join(
    str(x)
    for x in nums
    )

    +"\n"

    )


f.close()

print(
"Generated",
NUM_TESTS,
"4x4 vectors"
)