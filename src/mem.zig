const std = @import("std");

pub const MAX_MEM = 1024 * 64;
const Self = @This();

data: [MAX_MEM]u8 = [_]u8{0} ** MAX_MEM,

pub fn Initialize(self: *Self) void {
    @memset(self.data, 0);
}

pub fn WriteByteAtAddress(self: *Self, address: usize, data: u8) void {
    self.data[address] = data;
}

pub fn GetByteAtAddress(self: *Self, address: usize) u8 {
    // TODO: assert that address < MAX_MEM
    return self.data[address];
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
