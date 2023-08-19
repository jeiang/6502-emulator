const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "CPU does nothing when executing zero cycles" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    cpu.reset(&mem);

    // when:
    var expected_cycles: u32 = 0;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    result catch |err| return err; // i.e. no error
}

test "CPU cannot execute more cycles than requested if instruction needs more cycles" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.setMemory(.{
        .{ .start_address = 0xFFFC, .bytes = .{0x0200} },
        .{ .start_address = 0x0200, .bytes = .{ @intFromEnum(Cpu.Opcode.lda_immediate), 0x84 } },
    });
    cpu.reset(&mem);

    // when:
    var expected_cycles: u32 = 1;
    var result = cpu.execute(expected_cycles, &mem);

    // then:
    try std.testing.expectError(Cpu.ExecuteError.InsufficientCycles, result);
}
