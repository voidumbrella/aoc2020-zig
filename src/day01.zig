const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day01_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.split(input, "\n");

    var nums = ArrayList(u32).init(allocator);
    while (line_iterator.next()) |line| {
        if (line.len == 0) break;
        try nums.append(try std.fmt.parseInt(u32, line, 10));
    }

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    // O(n^2) go brrrr
    outer: for (nums.items) |a, ai| {
        for (nums.items[ai + 1 ..]) |b| {
            if (a + b == 2020) {
                part1_ans = a * b;
                break :outer;
            }
        }
    }

    // O(n^3) go BRRRRRRRRRR
    outer: for (nums.items) |a, ai| {
        for (nums.items[ai + 1 ..]) |b, bi| {
            for (nums.items[bi + 1 ..]) |c, ci| {
                if (a + b + c == 2020) {
                    part2_ans = a * b * c;
                    break :outer;
                }
            }
        }
    }

    print("=== Day 01 === ({} µs) \n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
