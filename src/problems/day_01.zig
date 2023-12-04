const std = @import("std");

const NEWLINE = 10;

pub fn part_1() !void {
    const allocator = std.heap.page_allocator;

    const buffer = try allocator.alloc(u8, 1);
    defer allocator.free(buffer);

    const file = try std.fs.cwd().openFile("inputs/day_01.txt", .{});
    defer file.close();

    const reader = file.reader();

    var first_digit_of_line: ?u4 = null;
    var last_digit_of_line: ?u4 = null;

    var result: u32 = 0;

    while (true) {
        const digit = readDigit(reader, buffer, null) catch null;
        if (digit == null or digit.? == NEWLINE) {
            if (first_digit_of_line) |first_digit| {
                if (last_digit_of_line) |last_digit| {
                    const value = @as(u32, first_digit) * 10 + @as(u32, last_digit);
                    result += value;
                }
            }

            first_digit_of_line = null;
            last_digit_of_line = null;

            if (digit == null) {
                break;
            }
        } else {
            if (first_digit_of_line == null) {
                first_digit_of_line = digit;
            }
            last_digit_of_line = digit;
        }
    }

    std.debug.print("{}", .{result});
}

pub fn part_2() !void {
    const allocator = std.heap.page_allocator;

    const buffer = try allocator.alloc(u8, 1);
    defer allocator.free(buffer);

    const file = try std.fs.cwd().openFile("inputs/day_01.txt", .{});
    defer file.close();

    const reader = file.reader();

    var first_digit_of_line: ?u4 = null;
    var last_digit_of_line: ?u4 = null;

    var result: u32 = 0;

    var queue = try Queue(5).create(&allocator);
    defer queue.free(&allocator);

    while (true) {
        const digit = readDigit(reader, buffer, &queue) catch null;
        if (digit == null or digit.? == NEWLINE) {
            if (first_digit_of_line) |first_digit| {
                if (last_digit_of_line) |last_digit| {
                    const value = @as(u32, first_digit) * 10 + @as(u32, last_digit);
                    result += value;
                }
            }

            first_digit_of_line = null;
            last_digit_of_line = null;

            if (digit == null) {
                break;
            }
        } else {
            if (first_digit_of_line == null) {
                first_digit_of_line = digit;
            }
            last_digit_of_line = digit;
        }
    }

    std.debug.print("{}", .{result});
}

fn Queue(comptime L: comptime_int) type {
    return struct {
        buffer: []u8,
        len: usize,
        index: usize,

        pub fn create(allocator: *const std.mem.Allocator) !Queue(L) {
            const buffer = try allocator.alloc(u8, L);
            const queue = Queue(L){
                .buffer = buffer,
                .len = 0,
                .index = 0,
            };
            return queue;
        }

        pub fn free(self: *Queue(L), allocator: *const std.mem.Allocator) void {
            allocator.free(self.buffer);
        }

        pub fn zero(self: *Queue(L)) void {
            self.len = 0;
            self.index = 0;
        }

        pub fn push(self: *Queue(L), value: u8) void {
            self.index = (self.index + 1) % L;
            self.buffer[self.index] = value;
            if (self.len < L) {
                self.len += 1;
            }
        }

        pub fn pop(self: *Queue(L)) void {
            if (self.len > 0) {
                self.len -= 1;
            }
        }

        pub fn is_included(self: *const Queue(L), other: []const u8) bool {
            if (self.len > other.len) {
                return false;
            }

            for (0..self.len) |i| {
                if (self.buffer[(i + (L - self.len + 1 + self.index)) % L] != other[i]) {
                    return false;
                }
            }

            return true;
        }

        pub fn print(self: *const Queue(L)) void {
            for (0..self.len) |i| {
                std.debug.print("{c}", .{self.buffer[(i + (L - self.len + 1 + self.index)) % L]});
            }
        }
    };
}

const digit_strings = .{
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
};

fn readDigit(reader: std.fs.File.Reader, buffer: []u8, queueOrNull: ?*Queue(5)) !?u4 {
    var len: usize = 0;

    while (reader.read(buffer)) |size| {
        if (size > 0) {
            if (buffer[0] >= '0' and buffer[0] <= '9') {
                const digit: u4 = @intCast(buffer[0] - '0');
                return digit;
            }
            if (buffer[0] == '\n') {
                return 10;
            }

            if (queueOrNull) |queue| {
                queue.push(buffer[0]);
                len += 1;

                while (queue.len > 0) {
                    const valid: ?struct { [:0]const u8, u4 } = inner: inline for (digit_strings, 0..) |digit_string, digit| {
                        if (queue.is_included(digit_string)) {
                            break :inner .{ digit_string, digit };
                        }
                        continue :inner;
                    } else null;

                    if (valid) |tuple| {
                        if (tuple[0].len == queue.len) {
                            return tuple[1];
                        }
                        break;
                    } else {
                        queue.pop();
                    }
                }
            }
        } else {
            return null;
        }
    } else |err| {
        return err;
    }
}
