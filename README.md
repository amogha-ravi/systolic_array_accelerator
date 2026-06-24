# Systolic Array Accelerator

A parameterized 4×4 systolic-array matrix multiplication accelerator implemented in Verilog.

## Features

- Signed 8-bit inputs
- 32-bit accumulation
- Parameterized Processing Element (PE)
- 4×4 systolic mesh architecture
- Randomized verification environment

## Verification

- 500 randomized matrix multiplication tests
- 8000 output comparisons
- 100% pass rate

## Directory Structure

rtl/      -> RTL source files
tb/       -> Testbenches
vectors/  -> Verification vectors
sim/      -> Simulation outputs