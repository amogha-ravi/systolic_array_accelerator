import random

NUM_TESTS = 500
N = 4

OUTFILE = "vectors/test_vectors.mem"

def matmul(A, B):

    C = [[0 for _ in range(N)] for _ in range(N)]

    for i in range(N):
        for j in range(N):
            for k in range(N):

                C[i][j] += A[i][k] * B[k][j]

    return C

with open(OUTFILE, "w") as f:

    for test in range(NUM_TESTS):

        #######################################################
        # Random matrices
        #######################################################

        A = [
            [random.randint(-8, 8) for _ in range(N)]
            for _ in range(N)
        ]

        B = [
            [random.randint(-8, 8) for _ in range(N)]
            for _ in range(N)
        ]

        #######################################################
        # Golden result
        #######################################################

        C = matmul(A, B)

        #######################################################
        # Write A
        #######################################################

        for row in A:

            f.write(
                "A "
                + " ".join(str(x) for x in row)
                + "\n"
            )

        #######################################################
        # Write B
        #######################################################

        for row in B:

            f.write(
                "B "
                + " ".join(str(x) for x in row)
                + "\n"
            )

        #######################################################
        # Write C
        #######################################################

        for row in C:

            f.write(
                "C "
                + " ".join(str(x) for x in row)
                + "\n"
            )

        #######################################################
        # Separator
        #######################################################

        f.write("END\n")

print(f"Generated {NUM_TESTS} test vectors")