const std = @import("std");

pub fn part_1() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("inputs/day_04.txt", .{});
    defer file.close();

    const reader = file.reader();

    const buffer: []u8 = try allocator.alloc(u8, 1024);
    const line_buffer: []u8 = try allocator.alloc(u8, 1024);

    var result: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(buffer, '\n')) |line| {
        var winning_numbers = std.ArrayList(u32).init(allocator);
        defer winning_numbers.deinit();

        var stream = std.io.fixedBufferStream(line);
        const line_reader = stream.reader();

        var flag = false;
        var matching_card_count: u32 = 0;

        while (try line_reader.readUntilDelimiterOrEof(line_buffer, ' ')) |token| {
            if (token.len == 0) continue;
            if (token[token.len - 1] == ':') continue;
            if (std.mem.eql(u8, token, "Card")) continue;
            if (std.mem.eql(u8, token, "|")) {
                flag = true;
                continue;
            }

            const number = std.fmt.parseInt(u32, token, 10) catch continue;

            if (!flag) {
                try winning_numbers.append(number);
            } else {
                const found = for (winning_numbers.items) |winning_number| {
                    if (winning_number == number) {
                        break true;
                    }
                } else false;

                if (found) {
                    matching_card_count += 1;
                }
            }
        }

        if (matching_card_count > 0) {
            result += std.math.pow(u32, 2, matching_card_count - 1);
        }
    }

    std.debug.print("{}", .{result});
}

pub fn part_2() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("inputs/day_04.txt", .{});
    defer file.close();

    const reader = file.reader();

    const buffer: []u8 = try allocator.alloc(u8, 1024);
    const line_buffer: []u8 = try allocator.alloc(u8, 1024);

    var cards: [256]u128 = .{0} ** 256;

    var line_count: usize = 0;
    while (try reader.readUntilDelimiterOrEof(buffer, '\n')) |line| {
        if (line.len == 0) continue;

        cards[line_count] = 1;
        line_count += 1;
    }

    try file.seekTo(0);

    var line_number: usize = 0;
    while (try reader.readUntilDelimiterOrEof(buffer, '\n')) |line| {
        var winning_numbers = std.ArrayList(u32).init(allocator);
        defer winning_numbers.deinit();

        var stream = std.io.fixedBufferStream(line);
        const line_reader = stream.reader();

        var flag = false;
        var matching_card_count: u32 = 0;

        while (try line_reader.readUntilDelimiterOrEof(line_buffer, ' ')) |token| {
            if (token.len == 0) continue;
            if (token[token.len - 1] == ':') continue;
            if (std.mem.eql(u8, token, "Card")) continue;
            if (std.mem.eql(u8, token, "|")) {
                flag = true;
                continue;
            }

            const number = std.fmt.parseInt(u32, token, 10) catch continue;

            if (!flag) {
                try winning_numbers.append(number);
            } else {
                const found = for (winning_numbers.items) |winning_number| {
                    if (winning_number == number) {
                        break true;
                    }
                } else false;

                if (found) {
                    matching_card_count += 1;
                }
            }
        }

        for (line_number + 1..line_number + matching_card_count + 1) |l| {
            if (cards[l] > 0) {
                cards[l] += cards[line_number];
            }
        }

        line_number += 1;
    }

    var result: u128 = 0;
    for (cards) |card| {
        result += card;
    }

    std.debug.print("{}", .{result});
}
