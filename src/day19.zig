const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day19_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

const Rule = struct {
    literal: ?u8 = null,
    subrules: ?[]const []const usize = null,
};

var rules: []Rule = undefined;

fn validate(str: []const u8, stack: *ArrayList(usize)) bool {
    if (str.len == 0 or stack.items.len == 0)
        return str.len == 0 and stack.items.len == 0;

    const rule = rules[stack.pop()];
    if (rule.literal) |c| {
        if (str[0] != c) return false;
        return validate(str[1..], stack);
    }

    // Can I get rid of this allocation?
    const backup = allocator.dupe(usize, stack.items[0..]) catch @panic("oom");
    for (rule.subrules.?) |sub| {
        var i: usize = 0;
        while (i < sub.len) : (i += 1) {
            stack.append(sub[sub.len - 1 - i]) catch @panic("oom");
        }
        if (validate(str, stack)) return true;
        stack.shrinkRetainingCapacity(0);
        stack.appendSlice(backup) catch @panic("oom");
    }
    return false;
}

pub fn main() !void {
    rules = try allocator.alloc(Rule, 300);

    var timer = try Timer.start();

    var parts_iterator = std.mem.split(input, "\n\n");

    const rules_part = parts_iterator.next().?;

    var rules_iterator = std.mem.tokenize(rules_part, "\n");
    while (rules_iterator.next()) |line| {
        var line_iterator = std.mem.tokenize(line, ":\" ");
        const idx = try std.fmt.parseInt(usize, line_iterator.next().?, 10);

        var rule = Rule{};
        var subrules = ArrayList([]usize).init(allocator);
        var sub = ArrayList(usize).init(allocator);

        while (line_iterator.next()) |tok| {
            if (tok[0] == 'a' or tok[0] == 'b') {
                rule = Rule{ .literal = tok[0] };
                break;
            } else if (tok[0] == '|') {
                try subrules.append(sub.toOwnedSlice());
                sub = ArrayList(usize).init(allocator);
            } else {
                try sub.append(try std.fmt.parseInt(usize, tok, 10));
            }
        }
        if (sub.items.len != 0) try subrules.append(sub.toOwnedSlice());
        if (subrules.items.len != 0) rule.subrules = subrules.toOwnedSlice();

        rules[idx] = rule;
    }

    const text_part = parts_iterator.next().?;
    assert(parts_iterator.next() == null);

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    var stack = ArrayList(usize).init(allocator);

    {
        var text_iterator = std.mem.tokenize(text_part, "\n");
        while (text_iterator.next()) |line| {
            try stack.append(0);
            if (validate(line, &stack)) part1_ans += 1;
        }
    }

    rules[8].subrules = &[_][]const usize{
        &[_]usize{42},
        &[_]usize{ 42, 8 },
    };
    rules[11].subrules = &[_][]const usize{
        &[_]usize{ 42, 31 },
        &[_]usize{ 42, 11, 31 },
    };

    {
        var text_iterator = std.mem.tokenize(text_part, "\n");
        while (text_iterator.next()) |line| {
            try stack.append(0);
            if (validate(line, &stack)) part2_ans += 1;
        }
    }

    print("=== Day 19 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
