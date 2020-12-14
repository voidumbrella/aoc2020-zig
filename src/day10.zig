const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day10_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, "\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    var jolts_list = ArrayList(u64).init(allocator);
    while (line_iterator.next()) |line| {
        const n = try std.fmt.parseInt(u64, line, 10);
        try jolts_list.append(n);
    }
    try jolts_list.append(0); // outlet
    std.sort.sort(u64, jolts_list.items, {}, comptime std.sort.asc(u64));
    try jolts_list.append(jolts_list.items[jolts_list.items.len - 1] + 3); // final joltage

    const jolts = jolts_list.items;

    {
        var cur_jolt: u64 = 0;
        var diff_1: u64 = 0;
        var diff_3: u64 = 0;
        for (jolts) |jolt| {
            if (jolt - cur_jolt == 1) diff_1 += 1;
            if (jolt - cur_jolt == 3) diff_3 += 1;
            cur_jolt = jolt;
        }
        part1_ans = diff_1 * diff_3;
    }

    const N = jolts.len;
    var branch_map = try allocator.alloc(u64, jolts.len);

    branch_map[N - 1] = 1;

    var i: usize = N - 2;
    while (true) : (i -= 1) {
        var branches: u64 = 0;
        if (i + 1 < N and jolts[i + 1] - jolts[i] <= 3) branches += branch_map[i + 1];
        if (i + 2 < N and jolts[i + 2] - jolts[i] <= 3) branches += branch_map[i + 2];
        if (i + 3 < N and jolts[i + 3] - jolts[i] <= 3) branches += branch_map[i + 3];
        branch_map[i] = branches;

        if (i == 0) break;
    }
    part2_ans = branch_map[0];

    print("=== Day 10 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
