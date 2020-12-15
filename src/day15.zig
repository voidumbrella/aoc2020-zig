const std = @import("std");
const ArrayList = std.ArrayList;
const Map = std.AutoHashMap;
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

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    var numbers = Map(u64, u64).init(allocator);

    var last_said: u64 = undefined;
    var age: u64 = 0;
    var turn: u64 = 1;

    // Say the starting numbers first
    while (part_iterator.next()) |part| {
        last_said = try std.fmt.parseInt(u64, part, 10);
        try numbers.put(last_said, turn);
        turn += 1;
    }

    while (turn < 2020) : (turn += 1) {
        // We are going to say the age of the last number,
        // but before doing that let's be nice for the next person
        // and find when this age was last said
        const new_age = if (numbers.get(age)) |prev_turn|
            turn - prev_turn
        else
            0;

        try numbers.put(age, turn);
        age = new_age;
        last_said = age;
    }
    part1_ans = last_said;

    while (turn < 30000000) : (turn += 1) {
        const new_age = if (numbers.get(age)) |prev_turn|
            turn - prev_turn
        else
            0;

        try numbers.put(age, turn);
        age = new_age;
        last_said = age;
    }
    part1_ans = last_said;

    print("=== Day 15 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
