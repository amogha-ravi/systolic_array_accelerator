# Parameterized Systolic Array AI/DSP Hardware Accelerator

A scalable Verilog-based hardware accelerator implementing a parameterized systolic array architecture for matrix multiplication.

## Features

- Parameterized NxN systolic array
- Signed fixed-point arithmetic support
- Pipelined MAC (Multiply-Accumulate) processing elements
- Scalable architecture
- Automated test-vector generation
- Self-checking verification environment
- Randomized regression testing
- GTKWave waveform debugging
- 8000/8000 verification tests passed

---

## Architecture

The accelerator consists of:

- Processing Elements (PEs)
- Horizontal A-data propagation
- Vertical B-data propagation
- Local MAC accumulation
- Output collection network

---

## Repository Structure

rtl/
- pe.v
- systolic_array.v

tb/
- tb_pe.v
- tb_systolic_array.v
- tb_systolic_random.v

vectors/
- random test vectors
- golden reference outputs

scripts/
- automated vector generation

---

## Verification Results

Regression Suite:

8000 / 8000 PASS

Element-Level Accuracy:

100%

---

## Tools Used

- Verilog
- Icarus Verilog
- GTKWave
- Python
- Git
- GitHub

---

## Future Work

- AXI-stream interface
- Fixed-point Q8.8 datapath
- Performance benchmarking
- FPGA implementation
- Vivado synthesis
- RISC-V integration