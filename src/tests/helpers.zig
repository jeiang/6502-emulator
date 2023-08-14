const std = @import("std");

// TODO: expand comparison to allow for multiple types of tests (eq, neq, gt, gte, lt, lte, err)
pub fn batchCompareEqual(tests: anytype) !void {
    const ArgsType = @TypeOf(tests);
    const args_type_info = @typeInfo(ArgsType);
    if (args_type_info != .Struct) {
        @compileError("expected tuple or struct argument, found " ++ @typeName(ArgsType));
    }
    inline for (args_type_info.Struct.fields, 0..) |field, idx| {
        const items_to_test = @field(tests, field.name);
        const FieldType = @TypeOf(items_to_test);
        const field_type_info = @typeInfo(FieldType);
        if (field_type_info != .Struct) {
            @compileError("expected tuple or struct argument, found " ++ @typeName(FieldType));
        }
        if (!@hasField(FieldType, "expected")) {
            @compileError("argument does not have a field named expected");
        }
        if (!@hasField(FieldType, "actual")) {
            @compileError("argument does not have a field named actual");
        }
        const expected = @field(items_to_test, "expected");
        const actual = @field(items_to_test, "actual");
        comptime if (@TypeOf(expected) != @TypeOf(actual)) {
            @compileError("the type of expected and actual is not the same. expected is " ++ @typeName(@TypeOf(expected)) ++ " and the type of actual is " ++ @typeName(@TypeOf(actual)));
        };
        std.testing.expectEqual(expected, actual) catch |err| {
            std.debug.print("item {d} was not equal\n", .{idx});
            return err;
        };
    }
}
