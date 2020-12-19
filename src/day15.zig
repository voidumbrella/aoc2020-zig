const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day15_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    var timer = try Timer.start();

    var part_iterator = std.mem.tokenize(input, ",\n");

    var part1_ans: u32 = 0;
    var part2_ans: u32 = 0;

    // We can't say a number that's greater than the number of turns
    var numbers = try allocator.alloc(u32, 30000000);
    std.mem.set(u32, numbers, 0);

    var last_said: u32 = undefined;
    var age: u32 = 0;
    var turn: u32 = 1;

    while (part_iterator.next()) |part| {
        last_said = try std.fmt.parseInt(u32, part, 10);
        numbers[last_said] = turn;
        turn += 1;
    }

    while (turn < 2020) : (turn += 1) {
        const tmp = if (numbers[age] != 0) turn - numbers[age] else 0;
        numbers[age] = turn;
        age = tmp;
    }
    part1_ans = age;

    while (turn < 30000000) : (turn += 1) {
        const tmp = if (numbers[age] != 0) turn - numbers[age] else 0;
        numbers[age] = turn;
        age = tmp;
    }
    part2_ans = age;

    print("=== Day 15 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
