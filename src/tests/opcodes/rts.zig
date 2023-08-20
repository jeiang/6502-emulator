const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "RTS can load an address back and jump to it, removing from stack" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{@intFromEnum(Cpu.Opcode.rts_implied)} },
        .{ .start_address = 0x01FE, .bytes = .{0xABCC} },
    });
    cpu.reset(&mem);
    cpu.SP -= 2; // simulate 1 value having been pushed
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 6;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC = 0xABCD; // 0xABCC + 1 = 0xABCD
    expected_cpu.SP = 0xFE;
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    // Given initial memory conditions, beyond the top of stack will be 0
    try std.testing.expectEqual(@as(u16, @intCast(0x0000)), cpu.peekWordOnStack(&mem));
}
