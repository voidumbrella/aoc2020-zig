const std = @import("std");
const ArrayList = std.ArrayList;
const Map = std.StringHashMap;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day16_input.txt");

const Range = struct { min_1: u64, max_1: u64, min_2: u64, max_2: u64 };
const Ticket = []u64;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    var timer = try Timer.start();

    var part_iterator = std.mem.split(input, "\n\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    var rules = Map(Range).init(allocator);
    {
        const rules_part = part_iterator.next().?;
        var line_iterator = std.mem.tokenize(rules_part, "\n");
        while (line_iterator.next()) |line| {
            var tokens = std.mem.tokenize(line, ":");
            const name = tokens.next().?;
            tokens.delimiter_bytes = ":-or ";
            const min_1 = try std.fmt.parseInt(u64, tokens.next().?, 10);
            const max_1 = try std.fmt.parseInt(u64, tokens.next().?, 10);
            const min_2 = try std.fmt.parseInt(u64, tokens.next().?, 10);
            const max_2 = try std.fmt.parseInt(u64, tokens.next().?, 10);
            try rules.put(name, .{ .min_1 = min_1, .max_1 = max_1, .min_2 = min_2, .max_2 = max_2 });
        }
    }

    var my_ticket: []u64 = undefined;
    {
        const my_ticket_part = part_iterator.next().?;
        var line_iterator = std.mem.tokenize(my_ticket_part, "\n");
        _ = line_iterator.next().?; // skip header
        const my_ticket_str = line_iterator.next().?;

        var ticket = ArrayList(u64).init(allocator);
        defer ticket.deinit();
        var fields = std.mem.tokenize(my_ticket_str, ",");
        while (fields.next()) |field_str|
            try ticket.append(try std.fmt.parseInt(u64, field_str, 10));
        my_ticket = ticket.toOwnedSlice();
    }

    var valid_tickets = ArrayList(Ticket).init(allocator);
    // Part 1 - find valid tickets
    {
        const nearby_tickets = part_iterator.next().?;
        var line_iterator = std.mem.tokenize(nearby_tickets, "\n");
        _ = line_iterator.next().?; // skip header
        while (line_iterator.next()) |line| {
            var ticket = ArrayList(u64).init(allocator);
            defer ticket.deinit();

            var fields = std.mem.tokenize(line, ",");
            var valid = true;
            var invalid_field: u64 = undefined;

            check: while (fields.next()) |field_str| {
                const field = try std.fmt.parseInt(u64, field_str, 10);
                var rule_iterator = rules.iterator();
                var field_ok = false;
                while (rule_iterator.next()) |e| {
                    const rule = e.value;
                    if ((rule.min_1 <= field and field <= rule.max_1) or
                        (rule.min_2 <= field and field <= rule.max_2))
                    {
                        field_ok = true;
                        try ticket.append(field);
                        break;
                    }
                }
                if (!field_ok) {
                    invalid_field = field;
                    valid = false;
                    break;
                }
            }

            if (!valid) {
                part1_ans += invalid_field;
            } else {
                try valid_tickets.append(ticket.toOwnedSlice());
            }
        }
    }

    // Part 2 is a mess
    const ticket_length = valid_tickets.items[0].len;
    var candidates = Map([]bool).init(allocator);
    {
        var rule_iterator = rules.iterator();
        var field_ok = false;
        while (rule_iterator.next()) |e| {
            var indices = ArrayList(bool).init(allocator);
            defer indices.deinit();

            const name = e.key;
            const rule = e.value;

            var i: usize = 0;
            while (i < ticket_length) : (i += 1) {
                var ok = true;
                for (valid_tickets.items) |ticket| {
                    const field = ticket[i];
                    if ((rule.min_1 <= field and field <= rule.max_1) or
                        (rule.min_2 <= field and field <= rule.max_2))
                        continue;
                    ok = false;
                    break;
                }
                try indices.append(ok);
            }
            try candidates.put(name, indices.toOwnedSlice());
        }
    }

    part2_ans = 1;
    var found: u16 = 0;
    while (found < 6) {
        var candidates_iterator = candidates.iterator();
        var s: []const u8 = undefined;
        var i: usize = undefined;
        while (candidates_iterator.next()) |e| {
            const name = e.key;
            const indices = e.value;

            if (std.mem.count(bool, indices, @as(*const [1]bool, &true)) == 1) {
                s = name;
                i = std.mem.indexOfScalar(bool, indices, true).?;
                if (std.mem.startsWith(u8, name, "departure")) {
                    found += 1;
                    part2_ans *= my_ticket[i];
                }
            }
        }
        _ = candidates.remove(s);
        candidates_iterator = candidates.iterator();
        while (candidates_iterator.next()) |e| {
            e.value[i] = false;
        }
    }

    print("=== Day 16 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
