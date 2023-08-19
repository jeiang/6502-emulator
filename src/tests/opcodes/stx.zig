const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "STX (Zero Page) can store a value from the X register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.stx_zero_page), 0x20 } },
    });
    cpu.Reset(&mem);
    cpu.X = 0xAA;

    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 3;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 2;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u8, 0xAA), mem.ReadByteAtAddress(0x0020));
}

test "STX (Zero Page, Y) can store a value from the X register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.stx_zero_page_y), 0x20 } },
    });
    cpu.Reset(&mem);
    cpu.X = 0xAA;
    cpu.Y = 0x04;

    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 2;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u8, 0xAA), mem.ReadByteAtAddress(0x0024));
}

test "STX (Absolute) can store a value from the X register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.stx_absolute), 0x8000 } },
    });
    cpu.Reset(&mem);
    cpu.X = 0xAA;

    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 3;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u8, 0xAA), mem.ReadByteAtAddress(0x8000));
}
