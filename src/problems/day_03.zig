const std = @import("std");

const PartNumber = struct {
    value: u32,
    y: usize,
    x1: usize,
    x2: usize,
    has_adjacent_symbol: bool,
};
const Symbol = struct {
    x: usize,
    y: usize,
};
const Gear = struct {
    x: usize,
    y: usize,
};

pub fn part_1() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("inputs/day_03.txt", .{});
    defer file.close();

    const reader = file.reader();

    const buffer: []u8 = try allocator.alloc(u8, 256);

    var part_numbers = std.fifo.LinearFifo(*PartNumber, .Dynamic).init(allocator);
    var symbols = std.fifo.LinearFifo(*Symbol, .Dynamic).init(allocator);

    var y: usize = 0;
    while (try reader.readUntilDelimiterOrEof(buffer, '\n')) |line| {
        var i: usize = 0;

        while (i < line.len) {
            const c = line[i];

            switch (c) {
                '0'...'9' => {
                    const part_number: *PartNumber = try allocator.create(PartNumber);
                    try part_numbers.writeItem(part_number);

                    part_number.value = 0;
                    part_number.x1 = i;
                    part_number.x2 = i;
                    part_number.y = y;

                    while (i < line.len and line[i] >= '0' and line[i] <= '9') : (i += 1) {
                        part_number.value *= 10;
                        part_number.value += line[i] - '0';
                        part_number.x2 += 1;
                    }

                    part_number.x2 -= 1;
                },
                '.' => i += 1,
                else => {
                    const symbol: *Symbol = try allocator.create(Symbol);
                    try symbols.writeItem(symbol);

                    symbol.x = i;
                    symbol.y = y;

                    i += 1;
                },
            }
        }

        y += 1;
    }

    var result: u32 = 0;
    for (part_numbers.readableSlice(0)) |part_number| {
        const has_adjacent_symbol = inner: for (symbols.readableSlice(0)) |symbol| {
            if (part_number.x2 >= symbol.x - 1 and part_number.x1 <= symbol.x + 1 and part_number.y >= symbol.y - 1 and part_number.y <= symbol.y + 1) {
                break :inner true;
            }
        } else false;

        if (has_adjacent_symbol) {
            result += part_number.value;
        }
    }

    std.debug.print("{}", .{result});
}

pub fn part_2() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("inputs/day_03.txt", .{});
    defer file.close();

    const reader = file.reader();

    const buffer: []u8 = try allocator.alloc(u8, 256);

    var part_numbers = std.fifo.LinearFifo(*PartNumber, .Dynamic).init(allocator);
    var gears = std.fifo.LinearFifo(*Gear, .Dynamic).init(allocator);

    var y: usize = 0;
    while (try reader.readUntilDelimiterOrEof(buffer, '\n')) |line| {
        var i: usize = 0;

        while (i < line.len) {
            const c = line[i];

            switch (c) {
                '0'...'9' => {
                    const part_number: *PartNumber = try allocator.create(PartNumber);
                    try part_numbers.writeItem(part_number);

                    part_number.value = 0;
                    part_number.x1 = i;
                    part_number.x2 = i;
                    part_number.y = y;

                    while (i < line.len and line[i] >= '0' and line[i] <= '9') : (i += 1) {
                        part_number.value *= 10;
                        part_number.value += line[i] - '0';
                        part_number.x2 += 1;
                    }

                    part_number.x2 -= 1;
                },
                '*' => {
                    const gear: *Gear = try allocator.create(Gear);
                    try gears.writeItem(gear);

                    gear.x = i;
                    gear.y = y;

                    i += 1;
                },
                else => i += 1,
            }
        }

        y += 1;
    }

    var result: u32 = 0;
    for (gears.readableSlice(0)) |gear| {
        var gear_product: u32 = 1;
        var gear_neighbor_count: usize = 0;

        inner: for (part_numbers.readableSlice(0)) |part_number| {
            if (part_number.x2 >= gear.x - 1 and part_number.x1 <= gear.x + 1 and part_number.y >= gear.y - 1 and part_number.y <= gear.y + 1) {
                if (gear_neighbor_count < 2) {
                    gear_neighbor_count += 1;
                    gear_product *= part_number.value;
                } else {
                    break :inner;
                }
            }
        }

        if (gear_neighbor_count == 2) {
            result += gear_product;
        }
    }

    std.debug.print("{}", .{result});
}
