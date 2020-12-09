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

    const N = nums.items.len;
    var subsets = try allocator.alloc(u64, N * N);
    for (nums.items) |n, i| {
        subsets[i * N + i] = n;
    }

    var size: usize = 2;

    search: while (size < nums.items.len) : (size += 1) {
        for (nums.items[0 .. nums.items.len - size + 1]) |n, i| {
            const sub = subsets[(i + 1) * N + (i + size - 1)];

            if (n + sub == part1_ans) {
                var min: u64 = std.math.maxInt(u64);
                var max: u64 = 0;
                for (nums.items[i .. i + size]) |m| {
                    if (m < min) min = m;
                    if (m > max) max = m;
                }

                part2_ans = min + max;
                break :search;
            }

            subsets[(i * N) + (i + size - 1)] = n + sub;
        }
    }

    print("=== Day 09 === ({} µs) \n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
