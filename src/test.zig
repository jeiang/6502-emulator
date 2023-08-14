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

test "LDA (Absolute) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_absolute));
    mem.WriteByteAtAddress(0x0201, 0x69);
    mem.WriteByteAtAddress(0x0202, 0x21);
    mem.WriteByteAtAddress(0x2169, 0x84);

    cpu.Reset(&mem);
    var cpu_copy = cpu;

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

test "LDA (Absolute, X) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_absolute_x));
    mem.WriteByteAtAddress(0x0201, 0x80);
    mem.WriteByteAtAddress(0x0202, 0x44); // 0x4480
    mem.WriteByteAtAddress(0x4481, 0x84);

    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.X = 1;

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

test "LDA (Absolute, X) can load a value into the A register when the reading address crosses the page boundary" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_absolute_x));
    mem.WriteByteAtAddress(0x0201, 0x02);
    mem.WriteByteAtAddress(0x0202, 0x44); // 0x4402
    mem.WriteByteAtAddress(0x4501, 0x84);
    mem.WriteByteAtAddress(0x4502, 0xFF);

    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.X = 0xFF;

    // when:
    var expected_cycles: u32 = 5;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x84), cpu.A);
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

test "LDA (Absolute, Y) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_absolute_y));
    mem.WriteByteAtAddress(0x0201, 0x80);
    mem.WriteByteAtAddress(0x0202, 0x44); // 0x4480
    mem.WriteByteAtAddress(0x4481, 0x84);

    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.Y = 1;

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

test "LDA (Absolute, Y) can load a value into the A register when the reading address crosses the page boundary" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_absolute_y));
    mem.WriteByteAtAddress(0x0201, 0x02);
    mem.WriteByteAtAddress(0x0202, 0x44); // 0x4402
    mem.WriteByteAtAddress(0x4501, 0x84);
    mem.WriteByteAtAddress(0x4502, 0xFF);

    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.Y = 0xFF;

    // when:
    var expected_cycles: u32 = 5;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x84), cpu.A);
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

test "LDA ((Indirect, X)) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_indirect_x));
    mem.WriteByteAtAddress(0x0201, 0x02);
    mem.WriteByteAtAddress(0x0006, 0x00);
    mem.WriteByteAtAddress(0x0007, 0x80);
    mem.WriteByteAtAddress(0x8000, 0x84);

    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.X = 0x04;

    // when:
    var expected_cycles: u32 = 6;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x84), cpu.A);
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

test "LDA ((Indirect, X)) can load a value into the A register when the reading address wraps around" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_indirect_x));
    mem.WriteByteAtAddress(0x0201, 0x06);
    mem.WriteByteAtAddress(0x0005, 0x00);
    mem.WriteByteAtAddress(0x0006, 0x80);
    mem.WriteByteAtAddress(0x8000, 0x84);

    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.X = 0xFF;

    // when:
    var expected_cycles: u32 = 6;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x84), cpu.A);
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

test "LDA ((Indirect), Y) can load a value into the A register" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_indirect_y));
    mem.WriteByteAtAddress(0x0201, 0x02);
    mem.WriteByteAtAddress(0x0002, 0x00);
    mem.WriteByteAtAddress(0x0003, 0x80);
    mem.WriteByteAtAddress(0x8004, 0x84);

    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.Y = 0x04;

    // when:
    var expected_cycles: u32 = 5;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x84), cpu.A);
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}

test "LDA ((Indirect), Y) can load a value into the A register when the reading address crosses a page boundary" {
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.lda_indirect_y));
    mem.WriteByteAtAddress(0x0201, 0x02);
    mem.WriteByteAtAddress(0x0002, 0x02);
    mem.WriteByteAtAddress(0x0003, 0x80);
    mem.WriteByteAtAddress(0x8101, 0x84);

    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.Y = 0xFF;

    // when:
    var expected_cycles: u32 = 6;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    try testing.expectEqual(expected_cycles, cycles_used);
    try testing.expectEqual(@as(u8, 0x84), cpu.A);
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try testing.expectEqual(cpu_copy.PS, cpu.PS);
}
