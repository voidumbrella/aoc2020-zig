const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day12_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, "\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    var x_1: i64 = 0;
    var y_1: i64 = 0;
    var dx_1: i64 = 1;
    var dy_1: i64 = 0;

    var x_2: i64 = 0;
    var y_2: i64 = 0;
    var dx_2: i64 = 10;
    var dy_2: i64 = 1;

    while (line_iterator.next()) |line| {
        const cmd = line[0];
        const arg = try std.fmt.parseInt(i16, line[1..], 10);

        switch (cmd) {
            'F' => {
                x_1 += arg * dx_1;
                y_1 += arg * dy_1;
                x_2 += arg * dx_2;
                y_2 += arg * dy_2;
            },

            'N' => {
                y_1 += arg;
                dy_2 += arg;
            },
            'S' => {
                y_1 -= arg;
                dy_2 -= arg;
            },

            'E' => {
                x_1 += arg;
                dx_2 += arg;
            },
            'W' => {
                x_1 -= arg;
                dx_2 -= arg;
            },

            'R' => if (arg == 90) {
                var tmp = dy_1;
                dy_1 = -dx_1;
                dx_1 = tmp;
                tmp = dy_2;
                dy_2 = -dx_2;
                dx_2 = tmp;
            } else if (arg == 180) {
                dx_1 = -dx_1;
                dy_1 = -dy_1;
                dx_2 = -dx_2;
                dy_2 = -dy_2;
            } else if (arg == 270) {
                var tmp = dy_1;
                dy_1 = dx_1;
                dx_1 = -tmp;
                tmp = dy_2;
                dy_2 = dx_2;
                dx_2 = -tmp;
            } else unreachable,
            'L' => if (arg == 90) {
                var tmp = dy_1;
                dy_1 = dx_1;
                dx_1 = -tmp;
                tmp = dy_2;
                dy_2 = dx_2;
                dx_2 = -tmp;
            } else if (arg == 180) {
                dx_1 = -dx_1;
                dy_1 = -dy_1;
                dx_2 = -dx_2;
                dy_2 = -dy_2;
            } else if (arg == 270) {
                var tmp = dy_1;
                dy_1 = -dx_1;
                dx_1 = tmp;
                tmp = dy_2;
                dy_2 = -dx_2;
                dx_2 = tmp;
            } else unreachable,
            else => unreachable,
        }
    }
    part1_ans = std.math.absCast(x_1) + std.math.absCast(y_1);
    part2_ans = std.math.absCast(x_2) + std.math.absCast(y_2);

    print("=== Day 12 ({} µs) ===\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
