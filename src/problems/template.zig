const std = @import("std");

pub fn part_1() !void {
    const allocator = std.heap.page_allocator;
    _ = allocator;

    const file = try std.fs.cwd().openFile("inputs/day_???.txt", .{});
    defer file.close();

    std.debug.print("Not implemented.", .{});
}

pub fn part_2() !void {
    const allocator = std.heap.page_allocator;
    _ = allocator;

    const file = try std.fs.cwd().openFile("inputs/day_???.txt", .{});
    defer file.close();

    std.debug.print("Not implemented.", .{});
}
