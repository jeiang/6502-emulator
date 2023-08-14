const std = @import("std");

const Cpu = @import("./cpu.zig");
const Mem = @import("./mem.zig");

pub fn main() !void {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // testing inline program
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.jsr_absolute));
    mem.WriteByteAtAddress(0x0201, 0x42);
    mem.WriteByteAtAddress(0x0202, 0x42);
    mem.WriteByteAtAddress(0x4242, @intFromEnum(Cpu.Opcode.lda_immediate));
    mem.WriteByteAtAddress(0x4243, 0x84);
    cpu.Reset(&mem);
    _ = cpu.Execute(8, &mem);

    std.debug.print("{any}\n", .{cpu});
    std.debug.print("{any}\n", .{mem});
}
