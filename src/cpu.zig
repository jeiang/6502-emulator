// CPU
const Self = @This();

const std = @import("std");

const Mem = @import("./mem.zig");

const stack_base_addr: u16 = 0x0100;

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
        .lda_immediate, .lda_zero_page, .lda_zero_page_x, .lda_absolute, .lda_absolute_x, .lda_absolute_y, .lda_indexed_indirect, .lda_indirect_indexed => {
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
    UnhandledInstruction,
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
        const addr = self.getOperandAddress(&cycles, mem, op);
        switch (op.instruction()) {
            .jsr => {
                self.PushWordToStack(&cycles, mem, self.PC);
                self.PC = addr;
                cycles += 1;
            },
            .lda => {
                self.A = ReadByte(&cycles, mem, addr);
            },
            .ldx => {
                self.X = ReadByte(&cycles, mem, addr);
            },
            .ldy => {
                self.Y = ReadByte(&cycles, mem, addr);
            },
            .sta => {
                WriteByte(&cycles, mem, addr, self.A);
            },
            .stx => {
                WriteByte(&cycles, mem, addr, self.X);
            },
            .sty => {
                WriteByte(&cycles, mem, addr, self.Y);
            },
            else => {
                return ExecuteError.UnhandledInstruction;
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

// See https://llx.com/Neil/a2/opcodes.html#ins02 under instruction timing
fn getOperandAddress(self: *Self, cycles: *u32, mem: *Mem, op: Opcode) u16 {
    const mode = op.addressingMode();
    const will_store_data = switch (op.instruction()) {
        // idk where to put this logic otherwise
        .asl, .dec, .inc, .lsr, .rol, .ror, .sta => true,
        else => false,
    };
    var addr: u16 = undefined;
    switch (mode) {
        .implied, .accumulator, .immediate => {
            addr = self.PC;
            self.PC += 1;
        },
        .zero_page => {
            addr = self.FetchByte(cycles, mem);
        },
        .zero_page_x => {
            const byte = self.FetchByte(cycles, mem);
            const add_result = @addWithOverflow(byte, self.X);
            addr = add_result[0];
            cycles.* += 1;
        },
        .zero_page_y => {
            const byte = self.FetchByte(cycles, mem);
            const add_result = @addWithOverflow(byte, self.Y);
            addr = add_result[0];
            cycles.* += 1;
        },
        .relative => {},
        .absolute => {
            addr = self.FetchWord(cycles, mem);
        },
        .absolute_x => {
            addr = self.FetchWord(cycles, mem);
            const upper = addr & 0xFF00;
            addr += self.X;
            if (will_store_data or upper != (addr & 0xFF00)) {
                cycles.* += 1;
            }
        },
        .absolute_y => {
            addr = self.FetchWord(cycles, mem);
            const upper = addr & 0xFF00;
            addr += self.Y;
            if (will_store_data or upper != (addr & 0xFF00)) {
                cycles.* += 1;
            }
        },
        .indirect => {},
        .indexed_indirect => {
            var indirect_address: u8 = self.FetchByte(cycles, mem); // 1 cycle
            const add_result = @addWithOverflow(indirect_address, self.X); // 1 cycle
            indirect_address = add_result[0];
            cycles.* += 1;
            addr = ReadWord(cycles, mem, @intCast(indirect_address)); // 2 cycles
        },
        .indirect_indexed => {
            var indirect_address: u16 = @intCast(self.FetchByte(cycles, mem)); // 1 cycle
            addr = ReadWord(cycles, mem, indirect_address); // 2 cycles
            const upper: u16 = addr & 0xFF00;
            const add_result = @addWithOverflow(addr, self.Y); // 1 cycle
            addr = add_result[0];
            if (will_store_data or upper != (addr & 0xFF00)) {
                cycles.* += 1;
            }
        },
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

//==================================
// Stack Manipulation
//==================================
// The second page of memory ($0100-$01FF) is reserved for the system stack and which cannot be relocated.

fn PushByteToStack(self: *Self, cycles: *u32, mem: *Mem, data: u8) void {
    const addr = stack_base_addr | @as(u16, @intCast(self.SP));
    const result = @addWithOverflow(self.SP, 1);
    self.SP = result[0];
    WriteByte(cycles, mem, addr, data);
}

fn PushWordToStack(self: *Self, cycles: *u32, mem: *Mem, data: u16) void {
    const addr = stack_base_addr | @as(u16, @intCast(self.SP));
    const result = @addWithOverflow(self.SP, 2);
    self.SP = result[0];
    WriteWord(cycles, mem, addr, data);
}

fn PopByteFromStack(self: *Self, cycles: *u32, mem: *Mem) u8 {
    const addr = stack_base_addr | @as(u16, @intCast(self.SP));
    const result = @subWithOverflow(self.SP, 1);
    self.SP = result[0];
    return ReadByte(cycles, mem, addr);
}

fn PopWordFromStack(self: *Self, cycles: *u32, mem: *Mem) u8 {
    const addr = stack_base_addr | @as(u16, @intCast(self.SP));
    const result = @subWithOverflow(self.SP, 2);
    self.SP = result[0];
    return ReadWord(cycles, mem, addr);
}

pub fn GetTopOfStack(self: *Self) u16 {
    return stack_base_addr | @as(u16, @intCast(self.SP));
}
