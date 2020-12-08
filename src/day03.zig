const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

fn count(map: ArrayList([]const u8), slope_x: usize, slope_y: usize) u64 {
    var width = map.items[0].len;
    var height = map.items.len;

    var trees: u64 = 0;
    var x: usize = 0;
    var y: usize = 0;
    while (y < height) : ({
        x += slope_x;
        x %= width;
        y += slope_y;
    }) {
        if (map.items[y][x] == '#') trees += 1;
    }
    return trees;
}

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input/day03_input.txt", .{});
    const input = try f.readToEndAlloc(allocator, std.math.maxInt(u64));
    var line_iterator = std.mem.tokenize(input, "\n");

    var map = ArrayList([]const u8).init(allocator);
    while (line_iterator.next()) |line| {
        try map.append(line);
    }
    const part1_ans = count(map, 3, 1);
    const part2_ans = count(map, 1, 1) *
        count(map, 3, 1) *
        count(map, 5, 1) *
        count(map, 7, 1) *
        count(map, 1, 2);

    print("=== Day 03 ===\n", .{});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
