const main = @import("main");
const std = @import("std");
const helpers = @import("./helpers.zig");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "CPU does nothing when executing zero cycles" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    cpu.Reset(&mem);

    // when:
    var expected_cycles: u32 = 0;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:

    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
    });
}

// TODO: change to error checking version
test "CPU can execute more cycles than requested if instruction needs more cycles" {
    if (@import("builtin").is_test) {
        return error.SkipZigTest;
    }
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_immediate));
    mem.WriteByteAtAddress(0x0201, 0x84);
    cpu.Reset(&mem);

    // when:
    var expected_cycles: u32 = 1;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
    });
}
