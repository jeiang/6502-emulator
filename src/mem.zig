const std = @import("std");

pub const MAX_MEM = 1024 * 64;
const Self = @This();

data: [MAX_MEM]u8 = [_]u8{0} ** MAX_MEM,

pub fn Initialize(self: *Self) void {
    @memset(self.data, 0);
}

pub fn WriteByteAtAddress(self: *Self, address: u16, data: u8) void {
    self.data[address] = data;
}

pub fn WriteWordAtAddress(self: *Self, address: u16, data: u16) void {
    self.data[address] = @truncate(data);
    if (address + 1 < self.data.len) {
        self.data[address + 1] = @truncate(data >> 8);
    }
}

pub fn WriteBytesStartingAt(self: *Self, address: u16, data: []u8) void {
    for (self.data[address..], data) |*addr, byte| {
        addr.* = byte;
    }
}

pub fn ReadByteAtAddress(self: *Self, address: u16) u8 {
    return self.data[address];
}

pub fn ReadWordAtAddress(self: *Self, address: u16) u16 {
    var word: u16 = 0;
    if (address + 1 < self.data.len) {
        word = self.data[address + 1];
        word = word << 8;
    }
    word |= @intCast(self.data[address]);
    return word;
}

pub fn ReadBytesStartingAt(self: *Self, address: u16, len: u16) []u8 {
    var end_addr: u16 = if (address + len >= self.data.len) {
        self.data.len - 1;
    } else {
        address + len;
    };
    return self.data[address..end_addr];
}

/// Takes in a tuple, of struct {.start_address: u16, .bytes: tuple}. bytes is a tuples of ints which will
/// be written byte by byte to a location in memory. Stores in little endian
pub fn setMemory(self: *Self, memset_array: anytype) void {
    if (@typeInfo(@TypeOf(memset_array)) != .Struct) {
        @compileError("expected tuple or struct argument, found " ++ @typeName(@TypeOf(memset_array)));
    }

    inline for (memset_array) |mem_to_write| {
        if (@typeInfo(@TypeOf(mem_to_write)) != .Struct) {
            @compileError("expected tuple or struct argument, found " ++ @typeName(@TypeOf(mem_to_write)));
        }

        var start_address: u16 = blk: {
            const field_name_start_address = "start_address";
            const address = @field(mem_to_write, field_name_start_address);
            if (@TypeOf(address) != u16 and @TypeOf(address) != comptime_int) {
                @compileError("expected start_addr_comptime to be a u16, found " ++ @typeName(@TypeOf(address)));
            }

            break :blk @as(u16, @intCast(address));
        };

        const bytes_array = blk: {
            const bytes_field_name = "bytes";
            const bytes_arr = @field(mem_to_write, bytes_field_name);
            if (@typeInfo(@TypeOf(bytes_arr)) != .Struct) {
                @compileError(bytes_field_name ++ "is not a struct or tuple argument, found " ++ @typeName(@TypeOf(bytes_arr)));
            }
            break :blk bytes_arr;
        };

        inline for (bytes_array) |bytes| {
            comptime var int_value = blk: {
                switch (@typeInfo(@TypeOf(bytes))) {
                    .ComptimeInt => {
                        const Int = std.math.IntFittingRange(bytes, bytes);
                        const bits = @sizeOf(Int) * 8;
                        comptime var int_info = @typeInfo(Int);
                        int_info.Int.bits = bits;
                        break :blk @as(@Type(int_info), bytes);
                    },
                    .Int => |info| {
                        if (info.bits < 8) {
                            break :blk @as(u8, bytes);
                        } else {
                            break :blk bytes;
                        }
                    },
                    else => {
                        @compileError("expected byte to be of type Int or ComptimeInt, found " ++ @typeName(@TypeOf(bytes)));
                    },
                }
            };

            comptime var byte_counter = @sizeOf(@TypeOf(int_value));
            inline while (byte_counter > 0) : (byte_counter -= 1) {
                const byte = @as(u8, @truncate(int_value));
                self.WriteByteAtAddress(start_address, byte);
                start_address += 1;
                if (@TypeOf(int_value) == u8) {
                    continue;
                }
                int_value = int_value >> 8;
            }
        }
    }
}

pub fn format(value: Self, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    try writer.writeAll("mem{ ");
    const showZero = std.mem.eql(u8, fmt, "0");
    const continuous = std.mem.eql(u8, fmt, "all");

    var first_value_print = true;

    for (value.data, 0..) |byte, addr| {
        if (continuous) {
            if (addr != 0) {
                try writer.writeAll(", ");
            }
            try std.fmt.format(writer, "0x{X:0>2}", .{byte});
        } else {
            if (byte == 0 and !showZero) {
                continue;
            }

            if (first_value_print) {
                first_value_print = false;
            } else {
                try writer.writeAll(", ");
            }
            try std.fmt.format(writer, "0x{X:0>2} = 0x{X:0>2}", .{ addr, byte });
        }
    }
    try writer.writeAll(" }");
}
