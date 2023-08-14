const main = @import("main");
const std = @import("std");
const helpers = @import("./helpers.zig");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "LDX (Immediate) can load a value into the X register" {
    // Skip tests without error due to unreachable code
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.ldx_immediate));
    mem.WriteByteAtAddress(0x0201, 0x84);
    cpu.Reset(&mem);
    var cpu_copy = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
        .{ .expected = cpu_copy.PS, .actual = cpu.PS },
        .{ .expected = @as(u8, 0x00), .actual = cpu.A },
        .{ .expected = @as(u8, 0x84), .actual = cpu.X },
        .{ .expected = @as(u8, 0x00), .actual = cpu.Y },
        .{ .expected = @as(u16, 0x0202), .actual = cpu.PC },
        .{ .expected = @as(u8, 0x02), .actual = cpu.SP },
    });
}

test "LDX (Immediate) can load zero into the X register and set the Zero Flag" {
    // Skip tests without error due to unreachable code
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.ldx_immediate));
    mem.WriteByteAtAddress(0x0201, 0x00);
    cpu.Reset(&mem);
    var cpu_copy = cpu;

    // when:
    var expected_cycles: u32 = 2;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    cpu_copy.PS.Z = 1;
    cpu_copy.PS.N = 0;
    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
        .{ .expected = cpu_copy.PS, .actual = cpu.PS },
        .{ .expected = @as(u8, 0x00), .actual = cpu.A },
        .{ .expected = @as(u8, 0x00), .actual = cpu.X },
        .{ .expected = @as(u8, 0x00), .actual = cpu.Y },
        .{ .expected = @as(u16, 0x0202), .actual = cpu.PC },
        .{ .expected = @as(u8, 0x02), .actual = cpu.SP },
    });
}

test "LDX (Zero Page) can load a value into the X register" {
    // Skip tests without error due to unreachable code
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.ldx_zero_page));
    mem.WriteByteAtAddress(0x0201, 0x69);
    mem.WriteByteAtAddress(0x0069, 0x34);
    cpu.Reset(&mem);
    var cpu_copy = cpu;

    // when:
    var expected_cycles: u32 = 3;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 0;
    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
        .{ .expected = cpu_copy.PS, .actual = cpu.PS },
        .{ .expected = @as(u8, 0x00), .actual = cpu.A },
        .{ .expected = @as(u8, 0x34), .actual = cpu.X },
        .{ .expected = @as(u8, 0x00), .actual = cpu.Y },
        .{ .expected = @as(u16, 0x0202), .actual = cpu.PC },
        .{ .expected = @as(u8, 0x02), .actual = cpu.SP },
    });
}

test "LDX (Zero Page, Y) can load a value into the X register" {
    // Skip tests without error due to unreachable code
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.ldx_zero_page_y));
    mem.WriteByteAtAddress(0x0201, 0x48);
    mem.WriteByteAtAddress(0x0069, 0x84);
    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.Y = 0x21;

    // when:
    var expected_cycles: u32 = 4;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
        .{ .expected = cpu_copy.PS, .actual = cpu.PS },
        .{ .expected = @as(u8, 0x00), .actual = cpu.A },
        .{ .expected = @as(u8, 0x84), .actual = cpu.X },
        .{ .expected = @as(u8, 0x21), .actual = cpu.Y },
        .{ .expected = @as(u16, 0x0202), .actual = cpu.PC },
        .{ .expected = @as(u8, 0x02), .actual = cpu.SP },
    });
}

test "LDX (Zero Page, Y) can load a value into the X register when it wraps" {
    // Skip tests without error due to unreachable code
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.ldx_zero_page_y));
    mem.WriteByteAtAddress(0x0201, 0xED);
    mem.WriteByteAtAddress(0x0056, 0x84);
    cpu.Reset(&mem);
    var cpu_copy = cpu;
    cpu.X = 0x69;

    // when:
    var expected_cycles: u32 = 4;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
        .{ .expected = cpu_copy.PS, .actual = cpu.PS },
        .{ .expected = @as(u8, 0x00), .actual = cpu.A },
        .{ .expected = @as(u8, 0x84), .actual = cpu.X },
        .{ .expected = @as(u8, 0x69), .actual = cpu.Y },
        .{ .expected = @as(u16, 0x0202), .actual = cpu.PC },
        .{ .expected = @as(u8, 0x02), .actual = cpu.SP },
    });
}

test "LDX (Absolute) can load a value into the X register" {
    // Skip tests without error due to unreachable code
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.ldx_absolute));
    mem.WriteByteAtAddress(0x0201, 0x69);
    mem.WriteByteAtAddress(0x0202, 0x21);
    mem.WriteByteAtAddress(0x2169, 0x84);

    cpu.Reset(&mem);
    var cpu_copy = cpu;

    // when:
    var expected_cycles: u32 = 4;
    var cycles_used = cpu.Execute(expected_cycles, &mem);

    // then:
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
        .{ .expected = cpu_copy.PS, .actual = cpu.PS },
        .{ .expected = @as(u8, 0x00), .actual = cpu.A },
        .{ .expected = @as(u8, 0x84), .actual = cpu.X },
        .{ .expected = @as(u8, 0x00), .actual = cpu.Y },
        .{ .expected = @as(u16, 0x0203), .actual = cpu.PC },
        .{ .expected = @as(u8, 0x02), .actual = cpu.SP },
    });
}

test "LDX (Absolute, Y) can load a value into the X register" {
    // Skip tests without error due to unreachable code
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.ldx_absolute_y));
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
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
        .{ .expected = cpu_copy.PS, .actual = cpu.PS },
        .{ .expected = @as(u8, 0x00), .actual = cpu.A },
        .{ .expected = @as(u8, 0x84), .actual = cpu.X },
        .{ .expected = @as(u8, 0x01), .actual = cpu.Y },
        .{ .expected = @as(u16, 0x0203), .actual = cpu.PC },
        .{ .expected = @as(u8, 0x02), .actual = cpu.SP },
    });
}

test "LDX (Absolute, Y) can load a value into the X register when the reading address crosses the page boundary" {
    // Skip tests without error due to unreachable code
    var mem: Mem = Mem{};
    var cpu: Cpu = Cpu{};

    // given:
    mem.WriteByteAtAddress(0xFFFC, 0x00);
    mem.WriteByteAtAddress(0xFFFD, 0x02);
    mem.WriteByteAtAddress(0x0200, @intFromEnum(Cpu.Opcode.ldx_absolute_y));
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
    cpu_copy.PS.Z = 0;
    cpu_copy.PS.N = 1;
    try helpers.batchCompareEqual(.{
        .{ .expected = expected_cycles, .actual = cycles_used },
        .{ .expected = cpu_copy.PS, .actual = cpu.PS },
        .{ .expected = @as(u8, 0x00), .actual = cpu.A },
        .{ .expected = @as(u8, 0x84), .actual = cpu.X },
        .{ .expected = @as(u8, 0xFF), .actual = cpu.Y },
        .{ .expected = @as(u16, 0x0203), .actual = cpu.PC },
        .{ .expected = @as(u8, 0x02), .actual = cpu.SP },
    });
}
