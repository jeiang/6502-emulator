// CPU
const Self = @This();

const std = @import("std");

const Mem = @import("./mem.zig");

pub const Opcode = @import("./opcodes.zig").Opcode;
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
