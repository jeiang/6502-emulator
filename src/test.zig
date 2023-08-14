const std = @import("std");
const testing = std.testing;

const Cpu = @import("./cpu.zig");
const Mem = @import("./mem.zig");

test "CPU does nothing when executing zero cycles" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    cpu.Reset(&mem);

    // when:
    var expected_cycles: u32 = 0;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
}

test "CPU can execute more cycles than requested if instruction needs more cycles" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_immediate));
    mem.WriteByteAtAddress(0x0201, 0x84);
    cpu.Reset(&mem);

    // when:
    var requested_cycles: u32 = 1;
    var cycles_used = cpu.Execute(requested_cycles, &mem);

    // then:
    try testing.expectEqual(@as(u32, 2), cycles_used);
}

test "CPU does not panic or loop forever when invalid instruction provided" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0201, 0xFF);
    cpu.Reset(&mem);

    // when:
    var requested_cycles: u32 = 1;
    var cycles_used = cpu.Execute(requested_cycles, &mem);

    // then:
    try testing.expectEqual(@as(u32, 1), cycles_used);
}

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
    var cpu_copy = cpu;

    // when:
    var expected_cycles: u32 = 6;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x02), cpu.SP);
    try testing.expectEqual(@as(u16, 0xA3A4), cpu.PC);
    // expecting no change in flags
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

test "LDA (Immediate) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_immediate));
    mem.WriteByteAtAddress(0x0201, 0x84);
    cpu.Reset(&mem);
    var cpu_copy = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x84), cpu.A);
    try testing.expectEqual(Cpu.StatusRegister{ .Z = 0, .N = 1 }, cpu.PS);
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

test "LDA (Immediate) can load zero into the A register and set the Zero Flag" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_immediate));
    mem.WriteByteAtAddress(0x0201, 0x00);
    cpu.Reset(&mem);
    var cpu_copy = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x00), cpu.A);
    cpu_copy.PS.Z = 1;
    cpu_copy.PS.N = 0;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

test "LDA (Zero Page) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_zero_page));
    mem.WriteByteAtAddress(0x0201, 0x69);
    mem.WriteByteAtAddress(0x0069, 0x34);
    cpu.Reset(&mem);
    var cpu_copy = cpu;

    // when:
    var expected_cycles: u32 = 3;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x34), cpu.A);
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 0;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

test "LDA (Zero Page, X) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_zero_page_x));
    mem.WriteByteAtAddress(0x0201, 0x48);
    mem.WriteByteAtAddress(0x0069, 0x84);
    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.X = 0x21;

    // when:
    var expected_cycles: u32 = 4;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x84), cpu.A);
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

test "LDA (Zero Page, X) can load a value into the A register when it wraps" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_zero_page_x));
    mem.WriteByteAtAddress(0x0201, 0xED);
    mem.WriteByteAtAddress(0x0056, 0x84);
    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.X = 0x69;

    // when:
    var expected_cycles: u32 = 4;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x84), cpu.A);
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

// test "LDA (Absolute) can load a value into the A register" {
//     var mem: Mem = Mem{};
//     var cpu: Cpu = Cpu{};

//     // given:
//     mem.WriteByteAtAddress(0xFFFC, 0x00);
//     mem.WriteByteAtAddress(0xFFFD, 0x02);
//     mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_absolute));
//     mem.WriteByteAtAddress(0x0201, 0x69);
//     mem.WriteByteAtAddress(0x0202, 0x21);
//     mem.WriteByteAtAddress(0x2169, 0x84);

//     cpu.Reset(&mem);
//     var cpu_copy = cpu;

//     // when:
//     var expected_cycles: u32 = 4;
//     var cycles_used = cpu.Execute(expected_cycles, &mem);

//     // then:
//     try testing.expectEqual(expected_cycles, cycles_used);
//     try testing.expectEqual(@as(u8, 0x84), cpu.A);
//     cpu_copy.PS.Z = 0;
//     cpu_copy.PS.N = 1;
//     try testing.expectEqual(cpu_copy.PS, cpu.PS);
// }
