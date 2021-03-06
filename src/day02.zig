const std = @import("std");
const ArrayList = std.ArrayList;
const Timer = std.time.Timer;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day02_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, "\n");

    var part1_ans: u32 = 0;
    var part2_ans: u32 = 0;
    while (line_iterator.next()) |line| {
        var iterator = std.mem.tokenize(line, "- :");
        const i = try std.fmt.parseInt(u32, iterator.next().?, 10);
        const j = try std.fmt.parseInt(u32, iterator.next().?, 10);
        const c: u8 = iterator.next().?[0];
        const pw = iterator.next().?;
        assert(iterator.next() == null);

        // Part 1
        var count: u32 = 0;
        for (pw) |char| {
            if (char == c)
                count += 1;
        }
        if (i <= count and count <= j) part1_ans += 1;

        // Part 2
        if ((pw[i - 1] == c) != (pw[j - 1] == c)) part2_ans += 1;
    }

    print("=== Day 01 === ({} µs) \n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
