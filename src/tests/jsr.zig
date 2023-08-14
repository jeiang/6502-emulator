const main = @import("main");
const std = @import("std");
const helpers = @import("./helpers.zig");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "JSR can jump to address and save last address on stack" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.jsr_absolute));
    mem.WriteByteAtAddress(0x0201, 0xA4);
    mem.WriteByteAtAddress(0x0202, 0xA3);
    mem.WriteByteAtAddress(0xA3A4, 0x84);
    cpu.Reset(&mem);

    // when:
    var expected_cycles: u32 = 6;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
        .{ .expected = @as(u8, 0x02), .actual = cpu.SP },
        .{ .expected = @as(u16, 0xA3A4), .actual = cpu.PC },
    });
}

test "JSR can does not affect processor flags" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.jsr_absolute));
    mem.WriteByteAtAddress(0x0201, 0xA4);
    mem.WriteByteAtAddress(0x0202, 0xA3);
    mem.WriteByteAtAddress(0xA3A4, 0x84);
    cpu.Reset(&mem);
    var cpu_copy = cpu;

    // when:
    var expected_cycles: u32 = 6;
    _ = cpu.Execute(expected_cycles, &mem);

    // then:
    try helpers.batchCompareEqual(.{
        .{ .expected = cpu_copy.PS, .actual = cpu.PS },
    });
}
