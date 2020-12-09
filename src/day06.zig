const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day06_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    var timer = try Timer.start();

    var group_iterator = std.mem.split(input, "\n\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    while (group_iterator.next()) |group| {
        var line_iterator = std.mem.tokenize(group, "\n");

        var group_size: u8 = 0;
        var questions = [_]u8{0} ** 26;
        while (line_iterator.next()) |line| {
            group_size += 1;
            for (line) |c|
                questions[@intCast(usize, c - 'a')] += 1;
        }

        for (questions) |yeses| {
            if (yeses > 0) part1_ans += 1;
            if (yeses == group_size) part2_ans += 1;
        }
    }

    print("=== Day 06 === ({} µs) \n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
