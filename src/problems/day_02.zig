const std = @import("std");

const max_cubes_map = std.ComptimeStringMap(u32, .{
    .{ "red", 12 },
    .{ "green", 13 },
    .{ "blue", 14 },
});

pub fn part_1() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("inputs/day_02.txt", .{});
    defer file.close();

    const reader = file.reader();

    const buffer: []u8 = try allocator.alloc(u8, 4096);
    defer allocator.free(buffer);

    var result: u32 = 0;

    outer: while (try reader.readUntilDelimiterOrEof(buffer, '\n')) |line| {
        var game_it = std.mem.splitSequence(u8, line, ": ");
        const game = try std.fmt.parseInt(u32, game_it.next().?[5..], 10);

        const rest = game_it.next().?;
        var pairs_it = std.mem.splitSequence(u8, rest, "; ");
        while (pairs_it.next()) |pairs| {
            var pair_it = std.mem.splitSequence(u8, pairs, ", ");
            inner: while (pair_it.next()) |pair| {
                var kv_it = std.mem.splitSequence(u8, pair, " ");

                const count = try std.fmt.parseInt(u32, kv_it.next().?, 10);
                const color = kv_it.next().?;

                const max_count = max_cubes_map.get(color) orelse continue :inner;
                if (count > max_count) {
                    continue :outer;
                }
            }
        }

        result += game;
    }

    std.debug.print("{}", .{result});
}

pub fn part_2() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("inputs/day_02.txt", .{});
    defer file.close();

    const reader = file.reader();

    const buffer: []u8 = try allocator.alloc(u8, 4096);
    defer allocator.free(buffer);

    var result: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(buffer, '\n')) |line| {
        var max_red: u32 = 0;
        var max_green: u32 = 0;
        var max_blue: u32 = 0;

        var game_it = std.mem.splitSequence(u8, line, ": ");
        _ = game_it.next();

        const rest = game_it.next().?;
        var pairs_it = std.mem.splitSequence(u8, rest, "; ");
        while (pairs_it.next()) |pairs| {
            var pair_it = std.mem.splitSequence(u8, pairs, ", ");
            inner: while (pair_it.next()) |pair| {
                var kv_it = std.mem.splitSequence(u8, pair, " ");

                const count = try std.fmt.parseInt(u32, kv_it.next().?, 10);
                const color = kv_it.next().?;

                if (std.mem.eql(u8, color, "red") and max_red < count) {
                    max_red = count;
                    continue :inner;
                }

                if (std.mem.eql(u8, color, "green") and max_green < count) {
                    max_green = count;
                    continue :inner;
                }

                if (std.mem.eql(u8, color, "blue") and max_blue < count) {
                    max_blue = count;
                    continue :inner;
                }
            }
        }

        result += max_red * max_green * max_blue;
    }

    std.debug.print("{}", .{result});
}
