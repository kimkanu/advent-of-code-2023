const std = @import("std");

const mods = .{
    @import("problems/day_01.zig"),
    @import("problems/day_02.zig"),
    @import("problems/day_03.zig"),
};

pub fn main() !void {
    std.debug.print("Advent of Code 2023!\n", .{});

    inline for (mods, 0..) |mod, i| {
        std.debug.print("\nDay {d:0>2}, Part 1: ", .{i + 1});
        try mod.part_1();

        std.debug.print("\n        Part 2: ", .{});
        try mod.part_2();
    }

    std.debug.print("\n", .{});
}
