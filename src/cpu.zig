// CPU
const Self = @This();

const std = @import("std");

const Mem = @import("./mem.zig");

// format: (assembly instruction)_(addressing mode)
pub const Opcode = enum(u8) {
    // Add with Carry
    adc_immediate = 0x69,
    adc_zero_page = 0x65,
    adc_zero_page_x = 0x75,
    adc_absolute = 0x6D,
    adc_absolute_x = 0x7D,
    adc_absolute_y = 0x79,
    adc_indirect_x = 0x61,
    adc_indirect_y = 0x71,

    // Logical And
    and_immediate = 0x29,
    and_zero_page = 0x25,
    and_zero_page_x = 0x35,
    and_absolute = 0x2D,
    and_absolute_x = 0x3D,
    and_absolute_y = 0x39,
    and_indirect_x = 0x21,
    and_indirect_y = 0x31,

    // Arithmetic Left Shift
    asl_accumulator = 0x0A,
    asl_zero_page = 0x06,
    asl_zero_page_x = 0x16,
    asl_absolute = 0x0E,
    asl_absolute_x = 0x1E,

    // Branch if Carry Clear
    bcc_relative = 0x90,

    // Branch if Carry Set
    bcs_relative = 0xB0,

    // Branch if Equal
    beq_relative = 0xF0,

    // Bit Test
    bit_zero_page = 0x24,
    bit_absolute = 0x2C,

    // Branch if Minus
    bmi_relative = 0x30,

    // Branch if Not Equal
    bne_relative = 0xD0,

    // Branch if Positive
    bpl_relative = 0x10,

    // Force Interrupt
    brk_implied = 0x00,

    // Branch if Overflow Clear
    bvc_relative = 0x50,

    // Branch if Overflow Set
    bvs_relative = 0x70,

    // Clear Carry Flag
    clc_implied = 0x18,

    // Clear Decimal Mode
    cld_implied = 0xD8,

    // Clear Interrupt Disable
    cli_implied = 0x58,

    // Clear Overflow Flag
    clv_implied = 0xB8,

    // Compare
    cmp_immediate = 0xC9,
    cmp_zero_page = 0xC5,
    cmp_zero_page_x = 0xD5,
    cmp_absolute = 0xCD,
    cmp_absolute_x = 0xDD,
    cmp_absolute_y = 0xD9,
    cmp_indirect_x = 0xC1,
    cmp_indirect_y = 0xD1,

    // Compare X Register
    cpx_immediate = 0xE0,
    cpx_zero_page = 0xE4,
    cpx_absolute = 0xEC,

    // Compare Y Register
    cpy_immediate = 0xC0,
    cpy_zero_page = 0xC4,
    cpy_absolute = 0xCC,

    // Decrement Memory
    dec_zero_page = 0xC6,
    dec_zero_page_x = 0xD6,
    dec_absolute = 0xCE,
    dec_absolute_x = 0xDE,

    // Decrement X Register
    dex_implied = 0xCA,

    // Decrement Y Register
    dey_implied = 0x88,

    // Exclusive OR
    eor_immediate = 0x49,
    eor_zero_page = 0x45,
    eor_zero_page_x = 0x55,
    eor_absolute = 0x4D,
    eor_absolute_x = 0x5D,
    eor_absolute_y = 0x59,
    eor_indirect_x = 0x41,
    eor_indirect_y = 0x51,

    // Increment Memory
    inc_zero_page = 0xE6,
    inc_zero_page_x = 0xF6,
    inc_absolute = 0xEE,
    inc_absolute_x = 0xFE,

    // Increment X Register
    inx_implied = 0xE8,

    // Increment Y Register
    iny_implied = 0xC8,

    // Jump
    jmp_absolute = 0x4C,
    jmp_indirect = 0x6C,

    // Jump to Subroutine
    jsr_absolute = 0x20,

    // Load Accumulator
    lda_immediate = 0xA9,
    lda_zero_page = 0xA5,
    lda_zero_page_x = 0xB5,
    lda_absolute = 0xAD,
    lda_absolute_x = 0xBD,
    lda_absolute_y = 0xB9,
    lda_indirect_x = 0xA1,
    lda_indirect_y = 0xB1,

    // Load X Register
    ldx_immediate = 0xA2,
    ldx_zero_page = 0xA6,
    ldx_zero_page_y = 0xB6,
    ldx_absolute = 0xAE,
    ldx_absolute_y = 0xBE,

    // Load Y Register
    ldy_immediate = 0xA0,
    ldy_zero_page = 0xA4,
    ldy_zero_page_x = 0xB4,
    ldy_absolute = 0xAC,
    ldy_absolute_x = 0xBC,

    // Logical Right Shift
    lsr_accumulator = 0x4A,
    lsr_zero_page = 0x46,
    lsr_zero_page_x = 0x56,
    lsr_absolute = 0x4E,
    lsr_absolute_x = 0x5E,

    // No Operation
    nop_implied = 0xEA,

    // Logical Inclusive OR
    ora_immediate = 0x09,
    ora_zero_page = 0x05,
    ora_zero_page_x = 0x15,
    ora_absolute = 0x0D,
    ora_absolute_x = 0x1D,
    ora_absolute_y = 0x19,
    ora_indirect_x = 0x01,
    ora_indirect_y = 0x11,

    // Push Accumulator
    pha_implied = 0x48,

    // Push Processor Status
    php_implied = 0x08,

    // Pull Accumulator
    pla_implied = 0x68,

    // Pull Processor Status
    plp_implied = 0x28,

    // Rotate Left
    rol_accumulator = 0x2A,
    rol_zero_page = 0x26,
    rol_zero_page_x = 0x36,
    rol_absolute = 0x2E,
    rol_absolute_x = 0x3E,

    // Rotate Right
    ror_accumulator = 0x6A,
    ror_zero_page = 0x66,
    ror_zero_page_x = 0x76,
    ror_absolute = 0x6E,
    ror_absolute_x = 0x7E,

    // Return from Interrupt
    rti_implied = 0x40,

    // Return from Subroutine
    rts_implied = 0x60,

    // Subtract with Carry
    sbc_immediate = 0xE9,
    sbc_zero_page = 0xE5,
    sbc_zero_page_x = 0xF5,
    sbc_absolute = 0xED,
    sbc_absolute_x = 0xFD,
    sbc_absolute_y = 0xF9,
    sbc_indirect_x = 0xE1,
    sbc_indirect_y = 0xF1,

    // Set Carry Flag
    sec_implied = 0x38,

    // Set Decimal Flag
    sed_implied = 0xF8,

    // Set Interrupt Disable
    sei_implied = 0x78,

    // Store Accumulator
    sta_zero_page = 0x85,
    sta_zero_page_x = 0x95,
    sta_absolute = 0x8D,
    sta_absolute_x = 0x9D,
    sta_absolute_y = 0x99,
    sta_indirect_x = 0x81,
    sta_indirect_y = 0x91,

    // Store X Register
    stx_zero_page = 0x86,
    stx_zero_page_y = 0x96,
    stx_absolute = 0x8E,

    // Store Y Register
    sty_zero_page = 0x84,
    sty_zero_page_x = 0x94,
    sty_absolute = 0x8C,

    // Transfer Accumulator to X
    tax_implied = 0xAA,

    // Transfer Accumulator to Y
    tay_implied = 0xA8,

    // Transfer Stack Pointer to X
    tsx_implied = 0xBA,

    // Transfer X to Accumulator
    txa_implied = 0x8A,

    // Transfer X to Stack Pointer
    txs_implied = 0x9A,

    // Transfer Y to Accumulator
    tya_implied = 0x98,
};

pub const StatusRegister = packed struct(u7) {
    C: u1 = 0,
    Z: u1 = 0,
    I: u1 = 0,
    D: u1 = 0,
    B: u1 = 0,
    V: u1 = 0,
    N: u1 = 0,
};

PC: u16 = 0xFFFC, // Program Counter
SP: u8 = 0xFF, // Stack Pointer

// Registers
A: u8 = 0, // Accumulator
X: u8 = 0, // X register
Y: u8 = 0, // Y register

// Processor Status Flags
PS: StatusRegister = StatusRegister{},

pub fn Reset(self: *Self, mem: *Mem) void {
    const pc_lower: u16 = mem.ReadByteAtAddress(0xFFFC);
    const pc_upper: u16 = mem.ReadByteAtAddress(0xFFFD);

    self.PC = (pc_upper << 8) | pc_lower;
    self.SP = 0x00;
    self.A = 0;
    self.X = 0;
    self.Y = 0;
    self.PS = StatusRegister{};
}

fn SetStatus(self: *Self, opcode: Opcode) void {
    switch (opcode) {
        .jsr_absolute => {},
        .lda_immediate, .lda_zero_page, .lda_zero_page_x, .lda_absolute, .lda_absolute_x, .lda_absolute_y, .lda_indirect_x, .lda_indirect_y => {
            self.PS.Z = @intFromBool(self.A == 0);
            self.PS.N = @intFromBool((self.A & 0b1000_0000) > 0);
        },
        .ldx_immediate, .ldx_zero_page, .ldx_zero_page_y, .ldx_absolute, .ldx_absolute_y => {
            self.PS.Z = @intFromBool(self.X == 0);
            self.PS.N = @intFromBool((self.X & 0b1000_0000) > 0);
        },
        .ldy_immediate, .ldy_zero_page, .ldy_zero_page_x, .ldy_absolute, .ldy_absolute_x => {
            self.PS.Z = @intFromBool(self.Y == 0);
            self.PS.N = @intFromBool((self.Y & 0b1000_0000) > 0);
        },
        else => {},
    }
}

pub const ExecuteError = error{
    InvalidInstruction,
    UnhandledOpcode,
    InsufficientCycles,
};

// TODO: make cycles not reliant on an input number
// either
// 1 - idk some sort of state machine???
// 2 - suspend/resume (async my beloved where are you)
// 3 - optional cycles count, have it go ham?
pub fn Execute(self: *Self, requested_cycles: u32, mem: *Mem) ExecuteError!void {
    var cycles: u32 = 0; // mutable
    while (cycles < requested_cycles) {
        var instruction: u8 = self.FetchByte(&cycles, mem);
        const possible_opcode = std.meta.intToEnum(Opcode, instruction);
        var op: Opcode = possible_opcode catch return ExecuteError.InvalidInstruction;
        switch (op) {
            .jsr_absolute => {
                var subroutine_address = self.FetchWord(&cycles, mem);
                // save current address on the stack
                // TODO: add func for the stack |  The second page of memory ($0100-$01FF) is reserved for the system stack and which cannot be relocated.
                WriteWord(&cycles, mem, self.SP, self.PC - 1);
                self.SP += 2;
                self.PC = subroutine_address;
                cycles += 1;
            },
            .lda_immediate => {
                const addr = self.GetAddressFromImmediate(&cycles, mem);
                self.A = ReadByte(&cycles, mem, addr);
            },
            .lda_zero_page => {
                const addr = self.GetAddressFromZeroPage(&cycles, mem);
                self.A = ReadByte(&cycles, mem, addr);
            },
            .lda_zero_page_x => {
                const addr = self.GetAddressFromZeroPageX(&cycles, mem);
                self.A = ReadByte(&cycles, mem, addr);
            },
            .lda_absolute => {
                const addr = self.GetAddressFromAbsolute(&cycles, mem);
                self.A = ReadByte(&cycles, mem, addr);
            },
            .lda_absolute_x => {
                const addr = self.GetAddressFromAbsoluteX(&cycles, mem);
                self.A = ReadByte(&cycles, mem, addr);
            },
            .lda_absolute_y => {
                const addr = self.GetAddressFromAbsoluteY(&cycles, mem);
                self.A = ReadByte(&cycles, mem, addr);
            },
            .lda_indirect_x => {
                const addr = self.GetAddressFromIndirectX(&cycles, mem);
                self.A = ReadByte(&cycles, mem, addr);
            },
            .lda_indirect_y => {
                const addr = self.GetAddressFromIndirectY(&cycles, mem);
                self.A = ReadByte(&cycles, mem, addr);
            },
            .ldx_immediate => {
                const addr = self.GetAddressFromImmediate(&cycles, mem);
                self.X = ReadByte(&cycles, mem, addr);
            },
            .ldx_zero_page => {
                const addr = self.GetAddressFromZeroPage(&cycles, mem);
                self.X = ReadByte(&cycles, mem, addr);
            },
            .ldx_zero_page_y => {
                const addr = self.GetAddressFromZeroPageY(&cycles, mem);
                self.X = ReadByte(&cycles, mem, addr);
            },
            .ldx_absolute => {
                const addr = self.GetAddressFromAbsolute(&cycles, mem);
                self.X = ReadByte(&cycles, mem, addr);
            },
            .ldx_absolute_y => {
                const addr = self.GetAddressFromAbsoluteY(&cycles, mem);
                self.X = ReadByte(&cycles, mem, addr);
            },
            .ldy_immediate => {
                const addr = self.GetAddressFromImmediate(&cycles, mem);
                self.Y = ReadByte(&cycles, mem, addr);
            },
            .ldy_zero_page => {
                const addr = self.GetAddressFromZeroPage(&cycles, mem);
                self.Y = ReadByte(&cycles, mem, addr);
            },
            .ldy_zero_page_x => {
                const addr = self.GetAddressFromZeroPageX(&cycles, mem);
                self.Y = ReadByte(&cycles, mem, addr);
            },
            .ldy_absolute => {
                const addr = self.GetAddressFromAbsolute(&cycles, mem);
                self.Y = ReadByte(&cycles, mem, addr);
            },
            .ldy_absolute_x => {
                const addr = self.GetAddressFromAbsoluteX(&cycles, mem);
                self.Y = ReadByte(&cycles, mem, addr);
            },
            else => {
                return ExecuteError.UnhandledOpcode;
            },
        }
        self.SetStatus(op);
        if (cycles > requested_cycles) {
            return ExecuteError.InsufficientCycles;
        }
    }
}

//==================================
// Addressing Memory
//==================================
// TODO: document what takes how many cycles

// NOTE: this is just to match the other instructions
fn GetAddressFromImmediate(self: *Self, _: *u32, _: *Mem) u16 {
    const addr = self.PC;
    self.PC += 1;
    return addr;
}

fn GetAddressFromZeroPage(self: *Self, cycles: *u32, mem: *Mem) u16 {
    return self.FetchByte(cycles, mem);
}

fn GetAddressFromZeroPageX(self: *Self, cycles: *u32, mem: *Mem) u16 {
    const byte = self.FetchByte(cycles, mem);
    const add_result = @addWithOverflow(byte, self.X);
    const addr = add_result[0];
    cycles.* += 1;
    return addr;
}

fn GetAddressFromZeroPageY(self: *Self, cycles: *u32, mem: *Mem) u16 {
    const byte = self.FetchByte(cycles, mem);
    const add_result = @addWithOverflow(byte, self.Y);
    const addr = add_result[0];
    cycles.* += 1;
    return addr;
}

fn GetAddressFromAbsolute(self: *Self, cycles: *u32, mem: *Mem) u16 {
    const addr = self.FetchWord(cycles, mem);
    return addr;
}

fn GetAddressFromAbsoluteX(self: *Self, cycles: *u32, mem: *Mem) u16 {
    var addr: u16 = self.FetchWord(cycles, mem);
    const upper = addr & 0xFF00;
    addr += self.X;
    if (upper != (addr & 0xFF00)) {
        cycles.* += 1;
    }
    return addr;
}

fn GetAddressFromAbsoluteY(self: *Self, cycles: *u32, mem: *Mem) u16 {
    var addr: u16 = self.FetchWord(cycles, mem);
    const upper = addr & 0xFF00;
    addr += self.Y;
    if (upper != (addr & 0xFF00)) {
        cycles.* += 1;
    }
    return addr;
}

fn GetAddressFromIndirectX(self: *Self, cycles: *u32, mem: *Mem) u16 {
    var indirect_address: u8 = self.FetchByte(cycles, mem); // 1 cycle
    const add_result = @addWithOverflow(indirect_address, self.X); // 1 cycle
    indirect_address = add_result[0];
    cycles.* += 1;
    var addr: u16 = ReadWord(cycles, mem, @intCast(indirect_address)); // 2 cycles
    return addr; // 1 cycle
}

fn GetAddressFromIndirectY(self: *Self, cycles: *u32, mem: *Mem) u16 {
    var indirect_address: u16 = @intCast(self.FetchByte(cycles, mem)); // 1 cycle
    var addr: u16 = ReadWord(cycles, mem, indirect_address); // 2 cycles
    const upper_effective_address: u16 = addr & 0xFF00;
    const add_result = @addWithOverflow(addr, self.Y); // 1 cycle
    addr = add_result[0];
    if (upper_effective_address != (addr & 0xFF00)) {
        cycles.* += 1;
    }
    return addr;
}

//==================================
// Reading from Memory
//==================================

fn FetchByte(self: *Self, cycles: *u32, mem: *Mem) u8 {
    const byte = ReadByte(cycles, mem, self.PC);
    self.PC += 1;
    return byte;
}

fn FetchWord(self: *Self, cycles: *u32, mem: *Mem) u16 {
    var byte = ReadWord(cycles, mem, self.PC);
    self.PC += 2;
    return byte;
}

fn ReadByte(cycles: *u32, mem: *Mem, address: u16) u8 {
    const data = mem.ReadByteAtAddress(address);
    cycles.* += 1;
    return data;
}

fn ReadWord(cycles: *u32, mem: *Mem, start_address: u16) u16 {
    var byte: u16 = ReadByte(cycles, mem, start_address);
    byte |= (@as(u16, ReadByte(cycles, mem, start_address + 1)) << 8);
    return byte;
}

//==================================
// Writing to Memory
//==================================

fn WriteByte(cycles: *u32, mem: *Mem, address: u16, data: u8) void {
    mem.WriteByteAtAddress(address, data);
    cycles.* += 1;
}

fn WriteWord(cycles: *u32, mem: *Mem, start_address: u16, data: u16) void {
    const upper: u8 = @truncate(data >> 8);
    const lower: u8 = @truncate(data);
    WriteByte(cycles, mem, start_address, lower);
    WriteByte(cycles, mem, start_address + 1, upper);
}
