const std = @import("std");
const ArrayList = std.ArrayList;
const HashMap = std.HashMap;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input/day01_input.txt", .{});
    const input = try f.readToEndAlloc(allocator, std.math.maxInt(u32));
    var line_iterator = std.mem.split(input, "\n");

    var nums = ArrayList(u32).init(allocator);
    while (line_iterator.next()) |line| {
        if (line.len == 0) break;
        try nums.append(try std.fmt.parseInt(u32, line, 10));
    }

    print("=== Day 01 ===\n", .{});
    // O(n^2) go brrrr
    outer: for (nums.items) |a, ai| {
        for (nums.items[ai + 1 ..]) |b| {
            if (a + b == 2020) {
                print("Part 1: {}\n", .{a * b});
                break :outer;
            }
        }
    }

    // O(n^3) go BRRRRRRRRRR
    outer: for (nums.items) |a, ai| {
        for (nums.items[ai + 1 ..]) |b, bi| {
            for (nums.items[bi + 1 ..]) |c, ci| {
                if (a + b + c == 2020) {
                    print("Part 2: {}\n", .{a * b * c});
                    break :outer;
                }
            }
        }
    }
}
