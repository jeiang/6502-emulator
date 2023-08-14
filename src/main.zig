const std = @import("std");

const Cpu = @import("./cpu.zig");
const Mem = @import("./mem.zig");

pub fn main() !void {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};
    cpu.Reset(&mem);

    // testing inline program
    mem.WriteByteAtAddress(0xFFFC, @intFromEnum(Cpu.Opcode.jsr_absolute));
    mem.WriteByteAtAddress(0xFFFD, 0x42);
    mem.WriteByteAtAddress(0xFFFE, 0x42);
    mem.WriteByteAtAddress(0x4242, @intFromEnum(Cpu.Opcode.lda_immediate));
    mem.WriteByteAtAddress(0x4243, 0x84);
    cpu.Execute(8, &mem);

    std.debug.print("{any}\n", .{cpu});
    std.debug.print("{any}", .{mem});
}
