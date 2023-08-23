const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "PLA can pull the accumulator from the stack" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{@intFromEnum(Cpu.Opcode.pla_implied)} },
    });
    cpu.reset(&mem);
    var cycles: u32 = 1;
    cpu.pushByteToStack(&cycles, &mem, 0x34);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 1;
    expected_cpu.A = 0x34;
    expected_cpu.SP = 0xFE;
    expected_cpu.PS.N = 0;
    expected_cpu.PS.Z = 0;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "PLA can pull the accumulator from the stack and set the zero flag" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{@intFromEnum(Cpu.Opcode.pla_implied)} },
    });
    cpu.reset(&mem);
    var cycles: u32 = 1;
    cpu.pushByteToStack(&cycles, &mem, 0x00);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 1;
    expected_cpu.A = 0x00;
    expected_cpu.SP = 0xFE;
    expected_cpu.PS.N = 0;
    expected_cpu.PS.Z = 1;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}

test "PLA can pull the accumulator from the stack and set the negative flag" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{@intFromEnum(Cpu.Opcode.pla_implied)} },
    });
    cpu.reset(&mem);
    var cycles: u32 = 1;
    cpu.pushByteToStack(&cycles, &mem, 0x84);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 4;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 1;
    expected_cpu.A = 0x84;
    expected_cpu.SP = 0xFE;
    expected_cpu.PS.N = 1;
    expected_cpu.PS.Z = 0;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
}
