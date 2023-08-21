const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "PHP can push the processor status register to the stack (all zero)" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{@intFromEnum(Cpu.Opcode.php_implied)} },
    });
    cpu.reset(&mem);
    cpu.PS = Cpu.StatusRegister{
        .N = 0,
        .V = 0,
        ._ = 1, // always 1
        .B = 0,
        .D = 0,
        .I = 0,
        .Z = 0,
        .C = 0,
    };
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 3;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 1;
    expected_cpu.SP = 0xFD;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u8, @bitCast(expected_cpu.PS)), cpu.peekByteOnStack(&mem));
    try std.testing.expectEqual(@as(u8, 0b00100000), cpu.peekByteOnStack(&mem));
}

test "PHP can push the processor status register to the stack (all ones)" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{@intFromEnum(Cpu.Opcode.php_implied)} },
    });
    cpu.reset(&mem);
    cpu.PS = Cpu.StatusRegister{
        .N = 1,
        .V = 1,
        ._ = 1, // always 1
        .B = 1,
        .D = 1,
        .I = 1,
        .Z = 1,
        .C = 1,
    };
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 3;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 1;
    expected_cpu.SP = 0xFD;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u8, @bitCast(expected_cpu.PS)), cpu.peekByteOnStack(&mem));
    try std.testing.expectEqual(@as(u8, 0b11111111), cpu.peekByteOnStack(&mem));
}
