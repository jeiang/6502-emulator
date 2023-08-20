const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "TXS can store a value from the X register in the stack pointer" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{@intFromEnum(Cpu.Opcode.txs_implied)} },
    });
    cpu.reset(&mem);
    cpu.X = 0x11;
    cpu.SP = 0xFF;

    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 1;
    expected_cpu.SP = 0x11;
    expected_cpu.PS.N = 0;
    expected_cpu.PS.Z = 0;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "TXS can store a value from the X register in the stack pointer and does not set the Zero Flag" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{@intFromEnum(Cpu.Opcode.txs_implied)} },
    });
    cpu.reset(&mem);
    cpu.X = 0x00;
    cpu.SP = 0xFF;

    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 1;
    expected_cpu.SP = 0x00;
    expected_cpu.PS.N = 0;
    expected_cpu.PS.Z = 0;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "TXS can store a value from the X register in the stack pointer and does not set the Negative Flag" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{@intFromEnum(Cpu.Opcode.txs_implied)} },
    });
    cpu.reset(&mem);
    cpu.X = 0x81;
    cpu.SP = 0xFF;

    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 1;
    expected_cpu.SP = 0x81;
    expected_cpu.PS.N = 0;
    expected_cpu.PS.Z = 0;

    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}
