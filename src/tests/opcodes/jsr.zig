const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "JSR can jump to address and save last address on stack" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.jsr_absolute), 0xA3A4 } },
    });
    cpu.Reset(&mem);
    var expected_cpu = cpu;

    // when:
    var expected_cycles: u32 = 6;
    var result = cpu.Execute(expected_cycles, &mem);

    // then:
    expected_cpu.PC = 0xA3A4;
    expected_cpu.SP = 0x02;
    try std.testing.expectEqualDeep(expected_cpu, cpu);
    try std.testing.expectEqual(@as(Cpu.ExecuteError!void, void{}), result);
    try std.testing.expectEqual(@as(u16, @intCast(0x0203)), mem.ReadWordAtAddress(cpu.GetTopOfStack() - 2));
}
