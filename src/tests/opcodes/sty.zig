const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "STY (Zero Page) can store a value from the Y register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.sty_zero_page), 0x20 } },
    });
    cpu.reset(&mem);
    cpu.Y = 0xAA;

    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 3;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 2;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u8, 0xAA), mem.readByteAtAddress(0x0020));
}

test "STY (Zero Page, X) can store a value from the Y register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.sty_zero_page_x), 0x20 } },
    });
    cpu.reset(&mem);
    cpu.Y = 0xAA;
    cpu.X = 0x04;

    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 2;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u8, 0xAA), mem.readByteAtAddress(0x0024));
}

test "STY (Absolute) can store a value from the Y register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.sty_absolute), 0x8000 } },
    });
    cpu.reset(&mem);
    cpu.Y = 0xAA;

    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 3;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u8, 0xAA), mem.readByteAtAddress(0x8000));
}
