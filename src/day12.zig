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

    const Step = struct {
        cmd: u8,
        arg: i16,
    };

    var steps = ArrayList(Step).init(allocator);

    var line_iterator = std.mem.tokenize(input, "\n");
    while (line_iterator.next()) |line| {
        var cmd = line[0];
        var arg = try std.fmt.parseInt(i16, line[1..], 10);
        try steps.append(.{ .cmd = cmd, .arg = arg });
    }

    var part1_ans: u64 = 0;
    {
        var x: i64 = 0;
        var y: i64 = 0;
        var dx: i64 = 1;
        var dy: i64 = 0;
        for (steps.items) |step| {
            const cmd = step.cmd;
            const arg = step.arg;

            switch (cmd) {
                'F' => {
                    x += arg * dx;
                    y += arg * dy;
                },

                'N' => y += arg,
                'S' => y -= arg,

                'E' => x += arg,
                'W' => x -= arg,

                'R' => if (arg == 90) {
                    const tmp = dy;
                    dy = -dx;
                    dx = tmp;
                } else if (arg == 180) {
                    dx = -dx;
                    dy = -dy;
                } else if (arg == 270) {
                    const tmp = dy;
                    dy = dx;
                    dx = -tmp;
                } else unreachable,
                'L' => if (arg == 90) {
                    const tmp = dy;
                    dy = dx;
                    dx = -tmp;
                } else if (arg == 180) {
                    dx = -dx;
                    dy = -dy;
                } else if (arg == 270) {
                    const tmp = dy;
                    dy = -dx;
                    dx = tmp;
                } else unreachable,
                else => unreachable,
            }
        }
        part1_ans = @intCast(u64, (try std.math.absInt(x)) + (try std.math.absInt(y)));
    }

    var part2_ans: u64 = 0;
    {
        var x: i64 = 0;
        var y: i64 = 0;
        var dx: i64 = 10;
        var dy: i64 = 1;

        for (steps.items) |step| {
            const cmd = step.cmd;
            const arg = step.arg;

            switch (cmd) {
                'F' => {
                    var i: i64 = 0;
                    while (i < arg) : (i += 1) {
                        x += dx;
                        y += dy;
                    }
                },

                'N' => dy += arg,
                'S' => dy -= arg,

                'E' => dx += arg,
                'W' => dx -= arg,

                'R' => if (arg == 90) {
                    const tmp = dy;
                    dy = -dx;
                    dx = tmp;
                } else if (arg == 180) {
                    dx = -dx;
                    dy = -dy;
                } else if (arg == 270) {
                    const tmp = dy;
                    dy = dx;
                    dx = -tmp;
                } else unreachable,
                'L' => if (arg == 90) {
                    const tmp = dy;
                    dy = dx;
                    dx = -tmp;
                } else if (arg == 180) {
                    dx = -dx;
                    dy = -dy;
                } else if (arg == 270) {
                    const tmp = dy;
                    dy = -dx;
                    dx = tmp;
                } else unreachable,

                else => unreachable,
            }
        }
        part2_ans = @intCast(u64, (try std.math.absInt(x)) + (try std.math.absInt(y)));
    }

    print("=== Day 12 ({} µs) ===\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
