const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "LDX (Immediate) can load a value into the X register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.ldx_immediate), 0x84 } },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.X = 0x84;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDX (Immediate) can load zero into the X register and set the Zero Flag" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.ldx_immediate), 0x00 } },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.X = 0;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 1;
    expected_cpu.PS.N = 0;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDX (Zero Page) can load a value into the X register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.ldx_zero_page), 0x69 } },
        .{ .start_address = 0x0069, .bytes = .{0x34} },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 3;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.X = 0x34;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 0;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDX (Zero Page, Y) can load a value into the X register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.ldx_zero_page_y), 0x48 } },
        .{ .start_address = 0x0069, .bytes = .{0x84} },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;
    cpu.Y = 0x21;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.X = 0x84;
    expected_cpu.Y = 0x21;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDX (Zero Page, Y) can load a value into the X register when it wraps" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.ldx_zero_page_y), 0xED } },
        .{ .start_address = 0x0056, .bytes = .{0x84} },
    });
    cpu.reset(&mem);
    var expected_cpu = cpu;
    cpu.Y = 0x69;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.X = 0x84;
    expected_cpu.Y = 0x69;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDX (Absolute) can load a value into the X register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.ldx_absolute), 0x2169 } },
        .{ .start_address = 0x2169, .bytes = .{0x84} },
    });

    cpu.reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.X = 0x84;
    expected_cpu.PC = 0x0203;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDX (Absolute, Y) can load a value into the X register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.ldx_absolute_y), 0x4480 } },
        .{ .start_address = 0x4481, .bytes = .{0x84} },
    });

    cpu.reset(&mem);
    var expected_cpu = cpu;
    cpu.Y = 1;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.X = 0x84;
    expected_cpu.Y = 0x01;
    expected_cpu.PC = 0x0203;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDX (Absolute, Y) can load a value into the X register when the reading address crosses the page boundary" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.ldx_absolute_y), 0x4480 } },
        .{ .start_address = 0x457F, .bytes = .{0x84} },
    });

    cpu.reset(&mem);
    var expected_cpu = cpu;
    cpu.Y = 0xFF;

    // when:
    var expected_cycles: u32 = 5;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.X = 0x84;
    expected_cpu.Y = 0xFF;
    expected_cpu.PC = 0x0203;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}
