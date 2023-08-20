const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "JMP (Absolute) can jump to address" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.jmp_absolute), 0x8000 } },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 3;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC = 0x8000;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "JMP (Absolute) can jump to address in a loop" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.jmp_absolute), 0x8000 } },
        .{ .start_address = 0x8000, .bytes = .{ @intFromEnum(Cpu.Opcode.jmp_absolute), 0x0200 } },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 3 * 20;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC = 0x0200;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "JMP (Indirect) can jump to address" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.jmp_indirect), 0xA3A4 } },
        .{ .start_address = 0xA3A4, .bytes = .{0x8000} },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 5;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC = 0x8000;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "JMP (Indirect) can jump to address in a loop" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.jmp_indirect), 0xA3A4 } },
        .{ .start_address = 0x8000, .bytes = .{ @intFromEnum(Cpu.Opcode.jmp_indirect), 0xB3B4 } },
        .{ .start_address = 0xA3A4, .bytes = .{0x8000} },
        .{ .start_address = 0xB3B4, .bytes = .{0x0200} },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 5 * 20;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC = 0x0200;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "JMP (Absolute) and JMP (Indirect) can jump to each other in a loop" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.jmp_absolute), 0x8000 } },
        .{ .start_address = 0x8000, .bytes = .{ @intFromEnum(Cpu.Opcode.jmp_indirect), 0xA3A4 } },
        .{ .start_address = 0xA3A4, .bytes = .{0x0200} },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = (5 + 3) * 10;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC = 0x0200;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}
