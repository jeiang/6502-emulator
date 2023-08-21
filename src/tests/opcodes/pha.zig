const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "PHA can push the accumulator to the stack" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{@intFromEnum(Cpu.Opcode.pha_implied)} },
    });
    cpu.reset(&mem);
    cpu.A = 0xAA;
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 3;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC += 1;
    expected_cpu.SP = 0xFD;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(u8, @intCast(0xAA)), cpu.peekByteOnStack(&mem));
}
