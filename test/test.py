# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


OP_R_TYPE = 0x0
OP_ADDI = 0x1
OP_LW = 0x3
OP_SW = 0x4
OP_BEQ = 0x5
OP_BNE = 0x6
OP_BLT = 0x7
OP_ANDI = 0x8
OP_ORI = 0x9
OP_XORI = 0xA
OP_SLLI = 0xB
OP_SLRI = 0xC

FUNCT_ADD = 0x0
FUNCT_SUB = 0x1


def r_type(rd, rs1, rs2, funct3):
    return (OP_R_TYPE << 12) | (rd << 9) | (rs1 << 6) | (rs2 << 3) | funct3


def i_type(opcode, rd, rs1, imm6):
    return (opcode << 12) | (rd << 9) | (rs1 << 6) | (imm6 & 0x3F)


def drive_instruction(dut, instruction):
    dut.ui_in.value = (instruction >> 8) & 0xFF
    dut.uio_in.value = instruction & 0xFF


async def execute_and_check(dut, instruction, expected, expected_pc=None):
    drive_instruction(dut, instruction)

    # The CPU alternates between a NOP/PC phase and an execute phase.
    await ClockCycles(dut.clk, 1)
    await Timer(1, unit="ns")

    observed = dut.uo_out.value.to_unsigned()
    assert observed == expected, (
        f"instruction 0x{instruction:04x}: expected {expected}, got {observed}"
    )

    await ClockCycles(dut.clk, 1)
    await Timer(1, unit="ns")

    if expected_pc is not None:
        observed_pc = dut.uo_out.value.to_unsigned()
        assert observed_pc == expected_pc, (
            f"instruction 0x{instruction:04x}: expected PC {expected_pc}, "
            f"got {observed_pc}"
        )


async def reset_dut(dut):
    drive_instruction(dut, 0xF000)
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await Timer(1, unit="ns")


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut._log.info("Reset")
    dut.ena.value = 1
    await reset_dut(dut)

    assert dut.uio_out.value.to_unsigned() == 0
    assert dut.uio_oe.value.to_unsigned() == 0

    dut._log.info("Run ALU and register sequence")

    # Registers after reset: r1 = 4, r4 = 0.
    await execute_and_check(dut, i_type(OP_ADDI, rd=4, rs1=1, imm6=3), 7, expected_pc=1)
    await execute_and_check(dut, i_type(OP_ADDI, rd=5, rs1=4, imm6=2), 9, expected_pc=2)
    await execute_and_check(dut, r_type(rd=6, rs1=4, rs2=5, funct3=FUNCT_ADD), 16, expected_pc=3)
    await execute_and_check(dut, r_type(rd=7, rs1=5, rs2=4, funct3=FUNCT_SUB), 2, expected_pc=4)
    await execute_and_check(dut, i_type(OP_ANDI, rd=6, rs1=5, imm6=6), 0, expected_pc=5)
    await execute_and_check(dut, i_type(OP_ORI, rd=6, rs1=4, imm6=8), 15, expected_pc=6)
    await execute_and_check(dut, i_type(OP_XORI, rd=6, rs1=5, imm6=3), 10, expected_pc=7)
    await execute_and_check(dut, i_type(OP_SLLI, rd=6, rs1=2, imm6=2), 8, expected_pc=8)
    await execute_and_check(dut, i_type(OP_SLRI, rd=6, rs1=3, imm6=3), 3, expected_pc=9)
    await execute_and_check(dut, i_type(OP_ADDI, rd=6, rs1=1, imm6=0x3F), 3, expected_pc=10)

    dut._log.info("Run memory and branch side-effect sequence")
    await reset_dut(dut)

    # Move r4 to 16, then store r1 at address r4 + 8 = 24.
    # Data memory has 16 entries, so address 24 should use index 8.
    await execute_and_check(dut, i_type(OP_ADDI, rd=4, rs1=4, imm6=16), 16, expected_pc=1)
    await execute_and_check(dut, i_type(OP_SW, rd=0, rs1=4, imm6=8), 0, expected_pc=2)

    # This false BEQ produces ALU address 24 - 16 = 8. Before the fix, branch
    # instructions incorrectly asserted MemWrite and corrupted memory[8].
    await execute_and_check(dut, i_type(OP_BEQ, rd=0, rs1=3, imm6=16), 0, expected_pc=3)

    await execute_and_check(dut, i_type(OP_LW, rd=6, rs1=4, imm6=8), 4, expected_pc=4)
    await execute_and_check(dut, r_type(rd=7, rs1=6, rs2=1, funct3=FUNCT_ADD), 8, expected_pc=5)

    dut._log.info("Run branch PC sequence")
    await reset_dut(dut)

    await execute_and_check(dut, i_type(OP_BEQ, rd=0, rs1=1, imm6=4), 0, expected_pc=4)
    await execute_and_check(dut, i_type(OP_BNE, rd=0, rs1=0, imm6=0x3F), 0, expected_pc=3)
    await execute_and_check(dut, i_type(OP_BLT, rd=0, rs1=2, imm6=5), 0, expected_pc=8)
