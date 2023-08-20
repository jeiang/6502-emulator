const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "JSR can jump to address and save last address on stack" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0xA3A4 } },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 6;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC = 0xA3A4;
    expected_cpu.SP = 0xFC;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u16, @intCast(0x0202)), cpu.peekWordOnStack(&mem));
}

test "JSR can jump to address and save last address on stack multiple times" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0280 } },
        .{ .start_address = 0x0280, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0300 } },
        .{ .start_address = 0x0300, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0380 } },
        .{ .start_address = 0x0380, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0400 } },
        .{ .start_address = 0x0400, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0480 } },
        .{ .start_address = 0x0480, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0500 } },
        .{ .start_address = 0x0500, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0580 } },
        .{ .start_address = 0x0580, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0600 } },
        .{ .start_address = 0x0600, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0680 } },
        .{ .start_address = 0x0680, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0700 } },
        .{ .start_address = 0x0700, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0780 } },
        .{ .start_address = 0x0780, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0800 } },
        .{ .start_address = 0x0800, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0880 } },
        .{ .start_address = 0x0880, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0900 } },
        .{ .start_address = 0x0900, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0980 } },
        .{ .start_address = 0x0980, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0A00 } },
        .{ .start_address = 0x0A00, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0A80 } },
        .{ .start_address = 0x0A80, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0B00 } },
        .{ .start_address = 0x0B00, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0B80 } },
        .{ .start_address = 0x0B80, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0C00 } },
        .{ .start_address = 0x0C00, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0x0C80 } },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 6 * 21;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC = 0x0C80;
    expected_cpu.SP = 0xD4; // 21 pushes, so 21 * 2 = 42 = 0x2A, 0xFE - 0x2A = 0xD4
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u16, @intCast(0x0C02)), cpu.peekWordOnStack(&mem));
}
