const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "LDA (Immediate) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_immediate), 0x84 } },
    });
    cpu.Reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA (Immediate) can load zero into the A register and set the Zero Flag" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_immediate), 0x00 } },
    });
    cpu.Reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 1;
    expected_cpu.PS.N = 0;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA (Zero Page) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_zero_page), 0x69 } },
        .{ .start_address = 0x0069, .bytes = .{0x34} },
    });
    cpu.Reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 3;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x34;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 0;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA (Zero Page, X) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_zero_page_x), 0x48 } },
        .{ .start_address = 0x0069, .bytes = .{0x84} },
    });
    cpu.Reset(&mem);
    var expected_cpu = cpu;
    cpu.X = 0x21;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.X = 0x21;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA (Zero Page, X) can load a value into the A register when it wraps" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_zero_page_x), 0xED } },
        .{ .start_address = 0x0056, .bytes = .{0x84} },
    });
    cpu.Reset(&mem);
    var expected_cpu = cpu;
    cpu.X = 0x69;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.X = 0x69;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA (Absolute) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_absolute), 0x2169 } },
        .{ .start_address = 0x2169, .bytes = .{0x84} },
    });

    cpu.Reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.PC = 0x0203;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA (Absolute, X) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_absolute_x), 0x4480 } },
        .{ .start_address = 0x4481, .bytes = .{0x84} },
    });

    cpu.Reset(&mem);
    var expected_cpu = cpu;
    cpu.X = 1;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.X = 0x01;
    expected_cpu.PC = 0x0203;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA (Absolute, X) can load a value into the A register when the reading address crosses the page boundary" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_absolute_x), 0x4480 } },
        .{ .start_address = 0x457F, .bytes = .{0x84} },
    });

    cpu.Reset(&mem);
    var expected_cpu = cpu;
    cpu.X = 0xFF;

    // when:
    var expected_cycles: u32 = 5;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.X = 0xFF;
    expected_cpu.PC = 0x0203;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA (Absolute, Y) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_absolute_y), 0x4480 } },
        .{ .start_address = 0x4481, .bytes = .{0x84} },
    });

    cpu.Reset(&mem);
    var expected_cpu = cpu;
    cpu.Y = 1;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.Y = 0x01;
    expected_cpu.PC = 0x0203;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA (Absolute, Y) can load a value into the A register when the reading address crosses the page boundary" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_absolute_y), 0x4480 } },
        .{ .start_address = 0x457F, .bytes = .{0x84} },
    });

    cpu.Reset(&mem);
    var expected_cpu = cpu;
    cpu.Y = 0xFF;

    // when:
    var expected_cycles: u32 = 5;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.Y = 0xFF;
    expected_cpu.PC = 0x0203;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

// TODO: what the nani?
// TODO: Check that PC is supposed to increment by 2
test "LDA ((Indirect, X)) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_indirect_x), 0x0002 } },
        .{ .start_address = 0x0006, .bytes = .{0x8000} },
        .{ .start_address = 0x8000, .bytes = .{0x84} },
    });

    cpu.Reset(&mem);
    var expected_cpu = cpu;
    cpu.X = 0x04;

    // when:
    var expected_cycles: u32 = 6;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.X = 0x04;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA ((Indirect, X)) can load a value into the A register when the reading address wraps around" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_indirect_x), 0x00FE } },
        .{ .start_address = 0x0002, .bytes = .{0x8000} },
        .{ .start_address = 0x8000, .bytes = .{0x84} },
    });

    cpu.Reset(&mem);
    var expected_cpu = cpu;
    cpu.X = 0x04;

    // when:
    var expected_cycles: u32 = 6;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.X = 0x04;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA ((Indirect), Y) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_indirect_y), 0x0002 } },
        .{ .start_address = 0x0002, .bytes = .{0x8000} },
        .{ .start_address = 0x8004, .bytes = .{0x84} },
    });

    cpu.Reset(&mem);
    var expected_cpu = cpu;
    cpu.Y = 0x04;

    // when:
    var expected_cycles: u32 = 5;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.Y = 0x04;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "LDA ((Indirect), Y) can load a value into the A register when the reading address crosses a page boundary" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_indirect_y), 0x0002 } },
        .{ .start_address = 0x0002, .bytes = .{0x7FFE} },
        .{ .start_address = 0x8002, .bytes = .{0x84} },
        .{ .start_address = 0x8002, .bytes = .{0x84} },
    });

    cpu.Reset(&mem);
    var expected_cpu = cpu;
    cpu.Y = 0x04;

    // when:
    var expected_cycles: u32 = 6;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.A = 0x84;
    expected_cpu.Y = 0x04;
    expected_cpu.PC = 0x0202;
    expected_cpu.PS.Z = 0;
    expected_cpu.PS.N = 1;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}
