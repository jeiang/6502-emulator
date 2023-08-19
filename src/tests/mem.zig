const main = @import("main");
const std = @import("std");

const Cpu = main.Cpu;
const Mem = main.Mem;

test "initMem does nothing when given nothing" {
    // given
    var mem = Mem{};

    // when
    mem.setMemory(.{});

    // then
    try std.testing.expectEqualDeep(Mem{}, mem);
}

test "initMem inits 1 byte at 1 address" {
    // given
    var mem = Mem{};

    // when
    mem.setMemory(.{
        .{ .start_address = 0x00, .bytes = .{0xAA} },
    });

    // then
    var expected_mem = Mem{};
    expected_mem.writeByteAtAddress(0x00, 0xAA);
    try std.testing.expectEqualDeep(expected_mem, mem);
}

test "initMem inits 1 word at 1 address" {
    // given
    var mem = Mem{};

    // when
    mem.setMemory(.{
        .{ .start_address = 0x00, .bytes = .{0xAABB} },
    });

    // then
    var expected_mem = Mem{};
    expected_mem.writeWordAtAddress(0x00, 0xAABB);
    try std.testing.expectEqualDeep(expected_mem, mem);
}

test "initMem inits at 2 bytes at 1 address" {
    // given
    var mem = Mem{};

    // when
    mem.setMemory(.{
        .{ .start_address = 0x00, .bytes = .{ 0xBB, 0xAA } },
    });

    // then
    var expected_mem = Mem{};
    expected_mem.writeWordAtAddress(0x00, 0xAABB);
    try std.testing.expectEqualDeep(expected_mem, mem);
}

test "initMem inits at 2 bytes at 2 addresses" {
    // given
    var mem = Mem{};

    // when
    mem.setMemory(.{
        .{ .start_address = 0x00, .bytes = .{0xAA} },
        .{ .start_address = 0x02, .bytes = .{0xBB} },
    });

    // then
    var expected_mem = Mem{};
    expected_mem.writeByteAtAddress(0x00, 0xAA);
    expected_mem.writeByteAtAddress(0x02, 0xBB);
    try std.testing.expectEqualDeep(expected_mem, mem);
}

test "initMem inits at variable sets of bytes at variable addresses" {
    // given
    var mem = Mem{};

    // when
    mem.setMemory(.{
        .{ .start_address = 0x00, .bytes = .{ 0xAA, 0xBB, 0xCC } },
        .{ .start_address = 0x08, .bytes = .{ 0xDD, 0xEE } },
        .{ .start_address = 0x10, .bytes = .{0xFF} },
    });

    // then
    var expected_mem = Mem{};
    expected_mem.writeByteAtAddress(0x00, 0xAA);
    expected_mem.writeByteAtAddress(0x01, 0xBB);
    expected_mem.writeByteAtAddress(0x02, 0xCC);
    expected_mem.writeByteAtAddress(0x08, 0xDD);
    expected_mem.writeByteAtAddress(0x09, 0xEE);
    expected_mem.writeByteAtAddress(0x10, 0xFF);
    try std.testing.expectEqualDeep(expected_mem, mem);
}

test "initMem overwrites bytes when given overlapping regions with last winning" {
    // given
    var mem = Mem{};

    // when
    mem.setMemory(.{
        .{ .start_address = 0x00, .bytes = .{ 0xAA, 0xBB, 0xCC } },
        .{ .start_address = 0x02, .bytes = .{ 0xDD, 0xEE } },
        .{ .start_address = 0x03, .bytes = .{0xFF} },
    });

    // then
    var expected_mem = Mem{};
    expected_mem.writeByteAtAddress(0x00, 0xAA);
    expected_mem.writeByteAtAddress(0x01, 0xBB);
    expected_mem.writeByteAtAddress(0x02, 0xDD);
    expected_mem.writeByteAtAddress(0x03, 0xFF);
    try std.testing.expectEqualDeep(expected_mem, mem);
}
