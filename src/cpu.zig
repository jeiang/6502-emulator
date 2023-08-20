// CPU
const Self = @This();

const std = @import("std");

const Mem = @import("./mem.zig");

const stack_base_addr: u16 = 0x0100;

pub const Opcode = @import("./opcodes.zig").Opcode;
pub const Instruction = @import("./opcodes.zig").Instruction;
pub const AddressingMode = @import("./opcodes.zig").AddressingMode;
pub const StatusRegister = packed struct(u8) {
    C: u1 = 0, // Bit 0
    Z: u1 = 0,
    I: u1 = 0,
    D: u1 = 0,
    B: u1 = 0,
    _: u1 = 1,
    V: u1 = 0,
    N: u1 = 0, // Bit 7
};

PC: u16 = 0xFFFC, // Program Counter
SP: u8 = 0xFE, // Stack Pointer

// Registers
A: u8 = 0, // Accumulator
X: u8 = 0, // X register
Y: u8 = 0, // Y register

// Processor Status Flags
PS: StatusRegister = StatusRegister{},

pub fn reset(self: *Self, mem: *Mem) void {
    const pc_lower: u16 = mem.readByteAtAddress(0xFFFC);
    const pc_upper: u16 = mem.readByteAtAddress(0xFFFD);

    self.PC = (pc_upper << 8) | pc_lower;
    self.SP = 0xFE;
    self.A = 0;
    self.X = 0;
    self.Y = 0;
    self.PS = StatusRegister{};
}

fn setZeroAndNegativeFlags(self: *Self, byte: u8) void {
    self.PS.Z = @intFromBool(byte == 0);
    self.PS.N = @intFromBool((byte & 0x80) > 0);
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
pub fn execute(self: *Self, requested_cycles: u32, mem: *Mem) ExecuteError!void {
    var cycles: u32 = 0; // mutable
    while (cycles < requested_cycles) {
        var raw_opcode: u8 = self.fetchByte(&cycles, mem);
        const possible_opcode = std.meta.intToEnum(Opcode, raw_opcode);
        var op: Opcode = possible_opcode catch return ExecuteError.InvalidInstruction;
        const addr = self.getOperandAddress(&cycles, mem, op);
        const instruction = op.instruction();
        switch (instruction) {
            .jsr => {
                self.pushWordToStack(&cycles, mem, self.PC);
                self.PC = addr;
            },
            .lda => {
                self.A = readByte(&cycles, mem, addr);
                self.setZeroAndNegativeFlags(self.A);
            },
            .ldx => {
                self.X = readByte(&cycles, mem, addr);
                self.setZeroAndNegativeFlags(self.X);
            },
            .ldy => {
                self.Y = readByte(&cycles, mem, addr);
                self.setZeroAndNegativeFlags(self.Y);
            },
            .rts => {
                _ = readByte(&cycles, mem, addr); // wasted cycle since since instr
                const return_address = self.popWordFromStack(&cycles, mem);
                self.PC = return_address + 1;
                cycles += 1; // penalty for incrementing
            },
            .sta => {
                writeByte(&cycles, mem, addr, self.A);
            },
            .stx => {
                writeByte(&cycles, mem, addr, self.X);
            },
            .sty => {
                writeByte(&cycles, mem, addr, self.Y);
            },
            .brk => { // TODO: implement this last
                std.debug.print("Completed Instruction set in {d} cycles.\n", .{cycles - 1}); // temp handler for too many instructions
                return ExecuteError.UnhandledInstruction;
            },
            else => {
                std.debug.print("Reached instruction called {any} with opcode {any}(0x{X:0>2}) at PC=0x{X:0>4}\n", .{
                    instruction,
                    op,
                    raw_opcode,
                    self.PC,
                });
                return ExecuteError.UnhandledInstruction;
            },
        }
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
            addr = self.fetchByte(cycles, mem);
        },
        .zero_page_x => {
            const byte = self.fetchByte(cycles, mem);
            const add_result = @addWithOverflow(byte, self.X);
            addr = add_result[0];
            cycles.* += 1;
        },
        .zero_page_y => {
            const byte = self.fetchByte(cycles, mem);
            const add_result = @addWithOverflow(byte, self.Y);
            addr = add_result[0];
            cycles.* += 1;
        },
        .relative => {},
        .absolute => {
            addr = self.fetchWord(cycles, mem);
        },
        .absolute_x => {
            addr = self.fetchWord(cycles, mem);
            const upper = addr & 0xFF00;
            addr += self.X;
            if (will_store_data or upper != (addr & 0xFF00)) {
                cycles.* += 1;
            }
        },
        .absolute_y => {
            addr = self.fetchWord(cycles, mem);
            const upper = addr & 0xFF00;
            addr += self.Y;
            if (will_store_data or upper != (addr & 0xFF00)) {
                cycles.* += 1;
            }
        },
        .indirect => {},
        .indexed_indirect => {
            var indirect_address: u8 = self.fetchByte(cycles, mem); // 1 cycle
            const add_result = @addWithOverflow(indirect_address, self.X); // 1 cycle
            indirect_address = add_result[0];
            cycles.* += 1;
            addr = readWord(cycles, mem, @intCast(indirect_address)); // 2 cycles
        },
        .indirect_indexed => {
            var indirect_address: u16 = @intCast(self.fetchByte(cycles, mem)); // 1 cycle
            addr = readWord(cycles, mem, indirect_address); // 2 cycles
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

fn fetchByte(self: *Self, cycles: *u32, mem: *Mem) u8 {
    const byte = readByte(cycles, mem, self.PC);
    self.PC += 1;
    return byte;
}

fn fetchWord(self: *Self, cycles: *u32, mem: *Mem) u16 {
    var byte = readWord(cycles, mem, self.PC);
    self.PC += 2;
    return byte;
}

fn readByte(cycles: *u32, mem: *Mem, address: u16) u8 {
    const data = mem.readByteAtAddress(address);
    cycles.* += 1;
    return data;
}

fn readWord(cycles: *u32, mem: *Mem, start_address: u16) u16 {
    var byte: u16 = readByte(cycles, mem, start_address);
    byte |= (@as(u16, readByte(cycles, mem, start_address + 1)) << 8);
    return byte;
}

//==================================
// Writing to Memory
//==================================

fn writeByte(cycles: *u32, mem: *Mem, address: u16, data: u8) void {
    mem.writeByteAtAddress(address, data);
    cycles.* += 1;
}

fn writeWord(cycles: *u32, mem: *Mem, start_address: u16, data: u16) void {
    const upper: u8 = @truncate(data >> 8);
    const lower: u8 = @truncate(data);
    writeByte(cycles, mem, start_address, lower);
    writeByte(cycles, mem, start_address + 1, upper);
}

//==================================
// Stack Manipulation
//==================================
// The second page of memory ($0100-$01FF) is reserved for the system stack and which cannot be relocated.

fn pushByteToStack(self: *Self, cycles: *u32, mem: *Mem, data: u8) void {
    const addr = self.getTopOfStack();
    const result = @subWithOverflow(self.SP, 1);
    self.SP = result[0];
    cycles.* += 1;
    writeByte(cycles, mem, addr, data);
}

fn pushWordToStack(self: *Self, cycles: *u32, mem: *Mem, data: u16) void {
    const addr = self.getTopOfStack();
    const result = @subWithOverflow(self.SP, 2);
    self.SP = result[0];
    cycles.* += 1;
    writeWord(cycles, mem, addr, data);
}

fn popByteFromStack(self: *Self, cycles: *u32, mem: *Mem) u8 {
    const result = @addWithOverflow(self.SP, 1);
    const addr = stack_base_addr | @as(u16, @intCast(result[0]));
    self.SP = result[0];
    cycles.* += 1;
    return readByte(cycles, mem, addr);
}

fn popWordFromStack(self: *Self, cycles: *u32, mem: *Mem) u16 {
    const result = @addWithOverflow(self.SP, 2);
    const addr = stack_base_addr | @as(u16, @intCast(result[0]));
    self.SP = result[0];
    cycles.* += 1;
    return readWord(cycles, mem, addr);
}

pub fn getTopOfStack(self: *Self) u16 {
    return stack_base_addr | @as(u16, @intCast(self.SP));
}

pub fn peekByteOnStack(self: *Self, mem: *Mem) u8 {
    const result = @addWithOverflow(self.SP, 1);
    const addr = stack_base_addr | @as(u16, @intCast(result[0]));
    return mem.readByteAtAddress(addr);
}

pub fn peekWordOnStack(self: *Self, mem: *Mem) u16 {
    const result = @addWithOverflow(self.SP, 2);
    const addr = stack_base_addr | @as(u16, @intCast(result[0]));
    return mem.readWordAtAddress(addr);
}
