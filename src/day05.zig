const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day05_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, "\n");

    var ids = [_]bool{false} ** (128 * 8 + 8);

    var part1_ans: u64 = 0;
    while (line_iterator.next()) |line| {
        var i: usize = 0;

        var row_min: u64 = 0;
        var row_max: u64 = 127;
        while (i < 7) : (i += 1) {
            if (line[i] == 'F') row_max = (row_min + row_max + 1) / 2 - 1;
            if (line[i] == 'B') row_min = (row_min + row_max + 1) / 2;
        }
        assert(row_min == row_max);
        const row = row_min;

        var col_min: u64 = 0;
        var col_max: u64 = 7;
        while (i < 10) : (i += 1) {
            if (line[i] == 'L') col_max = (col_min + col_max + 1) / 2 - 1;
            if (line[i] == 'R') col_min = (col_min + col_max + 1) / 2;
        }
        assert(col_min == col_max);
        const col = col_min;

        const id = row * 8 + col;

        ids[@intCast(usize, id)] = true;

        if (part1_ans < id)
            part1_ans = id;
    }

    var part2_ans: u64 = 0;
    {
        var i: usize = 1;
        while (i < ids.len - 1) : (i += 1) {
            if (ids[i - 1] and ids[i + 1] and !ids[i]) {
                part2_ans = @intCast(u64, i);
                break;
            }
        }
    }

    print("=== Day 01 === ({} µs) \n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
