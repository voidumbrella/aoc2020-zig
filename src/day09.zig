const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day09_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, "\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    const preamble_size = 25;

    var nums = ArrayList(u64).init(allocator);

    while (line_iterator.next()) |line| {
        const n = try std.fmt.parseInt(u64, line, 10);
        try nums.append(n);
    }

    for (nums.items) |n, i| {
        if (i < preamble_size) continue;

        var valid = false;

        const prev = nums.items[i - preamble_size .. i];
        search: for (prev) |a, j| {
            for (prev[j..]) |b| {
                if (a + b == n) {
                    valid = true;
                    break :search;
                }
            }
        }

        if (!valid) {
            part1_ans = n;
            break;
        }
    }

    var sliding_sum: u64 = 0;
    var i: usize = 0;
    var j: usize = 0;
    while (sliding_sum != part1_ans) {
        if (sliding_sum > part1_ans) {
            sliding_sum -= nums.items[i];
            i += 1;
        } else {
            sliding_sum += nums.items[j];
            j += 1;
        }
        assert(j < nums.items.len);
    }

    var min: u64 = std.math.maxInt(u64);
    var max: u64 = 0;
    for (nums.items[i .. j + 1]) |m| {
        if (m < min) min = m;
        if (m > max) max = m;
    }
    part2_ans = min + max;

    print("=== Day 09 === ({} µs) \n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
