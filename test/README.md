# Testbench

This directory contains the cocotb testbench for `tt_um_8bit_risc_cpu`.

The testbench instantiates the Tiny Tapeout top module through `tb.v` and drives
16-bit CPU instructions using:

```text
ui_in[7:0]  = instruction[15:8]
uio_in[7:0] = instruction[7:0]
```

## What The Test Covers

The included `test.py` test checks:

- reset values for all eight registers
- NOP and unsupported-opcode behavior
- `LI` and signed 6-bit immediates
- R-type ALU operations
- I-type ALU operations
- data memory store/load behavior
- branch behavior and PC updates
- `uio_out = 0` and `uio_oe = 0`

## Run RTL Simulation

From this directory:

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
make
```

or from the repository root:

```sh
cd test
make
```

A passing run ends with:

```text
TESTS=1 PASS=1 FAIL=0
```

## Run Gate-Level Simulation

First run local hardening or download the GDS action artifacts so that a powered
netlist is available.

For a local GF180 hardening run, the netlist is normally here:

```text
../runs/wokwi/final/pnl/tt_um_8bit_risc_cpu.pnl.v
```

Copy it into this directory:

```sh
cp ../runs/wokwi/final/pnl/tt_um_8bit_risc_cpu.pnl.v gate_level_netlist.v
```

Set the GF180 PDK environment and run:

```sh
export PDK=gf180mcuD
export PDK_ROOT=/path/to/pdk/root

make -B GATES=yes
```

`PDK_ROOT` must point to a directory that contains `gf180mcuD`. If the PDK was
installed through Ciel, run `ciel enable` first or point `PDK_ROOT` at the
enabled Ciel version directory.

Expected result:

```text
TESTS=1 PASS=1 FAIL=0
```

## Waveforms

The testbench writes `tb.fst`.

Open it with GTKWave:

```sh
gtkwave tb.fst tb.gtkw
```

or with Surfer:

```sh
surfer tb.fst
```
