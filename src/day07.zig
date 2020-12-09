const std = @import("std");
const ArrayList = std.ArrayList;
const HashMap = std.StringHashMap;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day07_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

const Child = struct { count: usize, color: []const u8 };
var rules = HashMap([]Child).init(allocator);

fn search(bag: []const u8) bool {
    if (std.mem.eql(u8, bag, "shiny gold")) return true;
    for (rules.get(bag).?) |inside|
        if (search(inside.color)) return true;
    return false;
}

fn bags_inside(bag: []const u8) u64 {
    var count: u64 = 0;
    for (rules.get(bag).?) |inside|
        count += (1 + bags_inside(inside.color)) * inside.count;
    return count;
}

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.split(input, "\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    while (line_iterator.next()) |line| {
        if (line.len == 0) break;
        var children = ArrayList(Child).init(allocator);

        var part_iterator = std.mem.split(line, " bags contain ");
        const bag = part_iterator.next().?;
        const children_parts = part_iterator.next().?;
        assert(part_iterator.next() == null);

        var child_iterator = std.mem.split(children_parts, ", ");
        while (child_iterator.next()) |child| {
            if (child[0] == 'n') break; // "no other bags"
            try children.append(Child{ .count = child[0] - '0', .color = std.mem.split(child[2..], " bag").next().? });
        }

        try rules.put(bag, children.items);
    }

    var rules_iterator = rules.iterator();
    while (rules_iterator.next()) |bag| {
        if (std.mem.eql(u8, bag.key, "shiny gold")) continue;
        if (search(bag.key)) part1_ans += 1;
    }

    part2_ans = bags_inside("shiny gold");

    print("=== Day 07 === ({} µs) \n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
