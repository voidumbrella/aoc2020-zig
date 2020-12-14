const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day17_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, "\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    while (line_iterator.next()) |line| {
        //
    }

    print("=== Day 17 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
