const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input/day05_input.txt", .{});
    const input = try f.readToEndAlloc(allocator, std.math.maxInt(u64));
    var line_iterator = std.mem.tokenize(input, "\n");

    var ids = [_]bool{false} ** (128 * 8 + 8);

    var part1_ans: u64 = 0;
    while (line_iterator.next()) |line| {
        var i: usize = 0;

        var row_min: u64 = 0;
        var row_max: u64 = 127;
        while (i < 7) : (i += 1) {
            if (line[i] == 'F') row_max = (row_min + row_max + 1) / 2 - 1;
            if (line[i] == 'B') row_min = (row_min + row_max + 1) / 2;
        }
        assert(row_min == row_max);
        const row = row_min;

        var col_min: u64 = 0;
        var col_max: u64 = 7;
        while (i < 10) : (i += 1) {
            if (line[i] == 'L') col_max = (col_min + col_max + 1) / 2 - 1;
            if (line[i] == 'R') col_min = (col_min + col_max + 1) / 2;
        }
        assert(col_min == col_max);
        const col = col_min;

        const id = row * 8 + col;

        ids[@intCast(usize, id)] = true;

        if (part1_ans < id)
            part1_ans = id;
    }

    var part2_ans: u64 = 0;
    {
        var i: usize = 1;
        while (i < ids.len - 1) : (i += 1) {
            if (ids[i - 1] and ids[i + 1] and !ids[i]) {
                part2_ans = @intCast(u64, i);
                break;
            }
        }
    }

    print("=== Day 05 ===\n", .{});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
