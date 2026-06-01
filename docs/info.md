## How it works

This project is an 8-bit RISC CPU implemented in Verilog for Tiny Tapeout GF.
The CPU receives a 16-bit instruction from the external input pins, executes it,
and presents an 8-bit result on the dedicated output pins.

The external instruction bus is split across the Tiny Tapeout inputs:

| Signal | Meaning |
| --- | --- |
| `ui_in[7:0]` | `instruction[15:8]`, the high byte of the instruction |
| `uio_in[7:0]` | `instruction[7:0]`, the low byte of the instruction |
| `uo_out[7:0]` | CPU output/result bus |
| `uio_out[7:0]` | Always driven to `0` |
| `uio_oe[7:0]` | Always driven to `0`, so the bidirectional pins are used as inputs |

The design contains an 8-bit program counter, an 8-register by 8-bit register
file, an ALU, immediate generation logic, branch control logic, and a 16-byte
data memory. The instruction source is external; for example, a microcontroller,
FPGA, or testbench can drive the instruction bits.

The CPU alternates between an internal NOP/PC phase and an execute phase. For
normal use, keep each external instruction stable for two clock cycles. The
result is visible on `uo_out` during the execute phase, and register, memory, and
PC state updates complete on the following clock edge.

### Instruction format

The opcode is always stored in `instruction[15:12]`.

R-type instructions:

| Bits | Field |
| --- | --- |
| `[15:12]` | opcode, `0000` |
| `[11:9]` | destination register `rd` |
| `[8:6]` | source register `rs1` |
| `[5:3]` | source register `rs2` |
| `[2:0]` | ALU function |

Immediate, load/store, and branch style instructions:

| Bits | Field |
| --- | --- |
| `[15:12]` | opcode |
| `[11:9]` | destination register `rd` or unused depending on instruction |
| `[8:6]` | source/base register `rs1` |
| `[5:0]` | signed 6-bit immediate |

The `LI` instruction uses `instruction[7:0]` as its 8-bit immediate.

### Opcodes

| Opcode | Mnemonic | Operation |
| --- | --- | --- |
| `0000` | R-type | ALU operation selected by `funct3` |
| `0001` | ADDI | `rd = rs1 + imm6` |
| `0010` | LI | `rd = rs1 + imm8` |
| `0011` | LW | `rd = memory[rs1 + imm6]` |
| `0100` | SW | `memory[rs1 + imm6] = rs2` |
| `0101` | BEQ | branch when `rs1 == imm6` |
| `0110` | BNE | branch when `rs1 != imm6` |
| `0111` | BLT | branch when `rs1 < imm6` |
| `1000` | ANDI | `rd = rs1 & imm6` |
| `1001` | ORI | `rd = rs1 | imm6` |
| `1010` | XORI | `rd = rs1 ^ imm6` |
| `1011` | SLLI | `rd = rs1 << imm6` |
| `1100` | SLRI | `rd = rs1 >> imm6` |
| `1111` | NOP | no operation |

R-type `funct3` values:

| funct3 | Operation |
| --- | --- |
| `000` | ADD |
| `001` | SUB |
| `010` | AND |
| `011` | OR |
| `100` | XOR |
| `101` | shift left |
| `110` | shift right |

After reset, the register file is initialized with these values:

| Register | Reset value |
| --- | --- |
| `r0` | `1` |
| `r1` | `4` |
| `r2` | `2` |
| `r3` | `24` |
| `r4` | `0` |
| `r5` | `4` |
| `r6` | `2` |
| `r7` | `24` |

## How to test

To use the design, provide a clock on `clk`, release reset by setting `rst_n`
high, and drive one 16-bit instruction at a time on `{ui_in, uio_in}`.

Example instruction sequence:

| Instruction | Encoding | Expected result on `uo_out` |
| --- | --- | --- |
| `ADDI r4, r1, 3` | `0x1843` | `7` |
| `ADDI r5, r4, 2` | `0x1B02` | `9` |
| `ADD r6, r4, r5` | `0x0D28` | `16` |

For each instruction:

1. Put `instruction[15:8]` on `ui_in`.
2. Put `instruction[7:0]` on `uio_in`.
3. Keep the instruction stable for two clock cycles.
4. Read the 8-bit result from `uo_out` during the execute phase.

The included cocotb testbench runs the same simple sequence. From the repository
root, run:

```sh
cd test
make
```

The test passes when cocotb reports `TESTS=1 PASS=1 FAIL=0`.

## External hardware

No special external hardware is required for simulation. On real hardware, an
external controller such as a microcontroller, FPGA, or Tiny Tapeout test setup
must provide the clock, reset, and 16-bit instruction input.
