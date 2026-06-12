![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# 8-bit RISC CPU for Tiny Tapeout GF

This repository contains a small 8-bit RISC CPU implemented in Verilog for Tiny
Tapeout GF. The CPU receives a 16-bit instruction from the external input pins,
executes it, and returns an 8-bit result on `uo_out`.

The full project documentation is in [docs/info.md](docs/info.md).

## What The Design Contains

- 8-bit program counter
- 8 x 8-bit register file
- 8-bit ALU
- immediate generator
- branch-control logic
- 16-byte data memory
- external 16-bit instruction interface using `{ui_in, uio_in}`

The top module is:

```text
tt_um_8bit_risc_cpu
```

## Quick Start: RTL Simulation

From the repository root:

```sh
cd test
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
make
```

Expected result:

```text
TESTS=1 PASS=1 FAIL=0
```

The cocotb testbench checks reset behavior, ALU instructions, immediate
instructions, load/store behavior, branch behavior, PC updates, and the Tiny
Tapeout bidirectional pin configuration.

## Instruction Input

The CPU instruction is split across the Tiny Tapeout input pins:

```text
ui_in[7:0]  = instruction[15:8]
uio_in[7:0] = instruction[7:0]
```

Hold each instruction stable for two clock cycles. During the execute phase,
`uo_out` shows the instruction result. During the following NOP / PC phase,
`uo_out` shows the updated program counter.

## Example Instruction Sequence

| Instruction | Encoding | Result |
| --- | --- | --- |
| `LI r1, 4` | `0x2204` | `r1 = 4` |
| `ADDI r4, r1, 3` | `0x1843` | `r4 = 7` |
| `ADDI r5, r4, 2` | `0x1B02` | `r5 = 9` |
| `ADD r6, r4, r5` | `0x0D28` | `r6 = 16` |

## Local Hardening

This is a Tiny Tapeout GF project, so use the `--gf` flag with the Tiny Tapeout
tools.

If `tt/` is not already present:

```sh
git clone https://github.com/TinyTapeout/tt-support-tools tt
```

Typical environment:

```sh
python3 -m venv ~/ttsetup/venv
source ~/ttsetup/venv/bin/activate
pip install --upgrade pip
pip install -r tt/requirements.txt

export PDK_ROOT=~/ttsetup/pdk
export PDK=gf180mcuD
export LIBRELANE_TAG=3.0.3
pip install librelane==$LIBRELANE_TAG
```

Run hardening:

```sh
./tt/tt_tool.py --create-user-config --gf
./tt/tt_tool.py --harden --gf
./tt/tt_tool.py --print-warnings --gf
```

Final generated files are placed under:

```text
runs/wokwi/final/
```

## Gate-Level Simulation

After local hardening, copy the powered netlist into the test directory:

```sh
cp runs/wokwi/final/pnl/tt_um_8bit_risc_cpu.pnl.v test/gate_level_netlist.v
cd test
make -B GATES=yes
```

Expected result:

```text
TESTS=1 PASS=1 FAIL=0
```

## Repository Notes

Generated local hardening output is intentionally ignored by git. In particular,
the `tt/`, `runs/`, `tt_submission/`, waveform, simulation-build, and temporary
gate-level netlist files should not be committed.

## Tiny Tapeout Resources

- [Tiny Tapeout](https://tinytapeout.com)
- [Local hardening guide](https://www.tinytapeout.com/guides/local-hardening/)
- [Testing HDL projects](https://tinytapeout.com/hdl/testing/)
