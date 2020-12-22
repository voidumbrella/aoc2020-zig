const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day22_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

fn score(deck: *ArrayList(u32)) u32 {
    var res: u32 = 0;
    var i: u32 = @intCast(u32, deck.items.len);
    for (deck.items) |n| {
        res += n * i;
        i -= 1;
    }
    return res;
}

// Returns true if player 1 wins
fn war(p1_deck: *ArrayList(u32), p2_deck: *ArrayList(u32)) bool {
    while (p1_deck.items.len != 0 and p2_deck.items.len != 0) {
        const p1 = p1_deck.orderedRemove(0);
        const p2 = p2_deck.orderedRemove(0);
        if (p1 > p2) {
            p1_deck.append(p1) catch unreachable;
            p1_deck.append(p2) catch unreachable;
        } else {
            p2_deck.append(p2) catch unreachable;
            p2_deck.append(p1) catch unreachable;
        }
    }
    return p1_deck.items.len != 0;
}

const Record = struct { p1: ArrayList(u32), p2: ArrayList(u32) };

// Returns true if player 1 wins
fn rec_war(p1_deck: *ArrayList(u32), p2_deck: *ArrayList(u32)) bool {
    var history = std.AutoHashMap(u32, void).init(allocator);

    while (p1_deck.items.len != 0 and p2_deck.items.len != 0) {
        var p1_wins: bool = undefined;

        const r = score(p1_deck) * score(p2_deck);
        if (history.get(r) != null) {
            return true;
        }
        history.put(r, .{}) catch unreachable;

        const p1 = p1_deck.orderedRemove(0);
        const p2 = p2_deck.orderedRemove(0);

        if (p1 <= p1_deck.items.len and p2 <= p2_deck.items.len) {
            var new_p1 = ArrayList(u32).init(allocator);
            var new_p2 = ArrayList(u32).init(allocator);
            new_p1.appendSlice(p1_deck.items[0..p1]) catch unreachable;
            new_p2.appendSlice(p2_deck.items[0..p2]) catch unreachable;
            p1_wins = rec_war(&new_p1, &new_p2);
        } else {
            p1_wins = p1 > p2;
        }

        if (p1_wins) {
            p1_deck.append(p1) catch unreachable;
            p1_deck.append(p2) catch unreachable;
        } else {
            p2_deck.append(p2) catch unreachable;
            p2_deck.append(p1) catch unreachable;
        }
    }
    return p1_deck.items.len != 0;
}

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, ":\n");

    var p1_deck = ArrayList(u32).init(allocator);
    var p2_deck = ArrayList(u32).init(allocator);

    _ = line_iterator.next();
    while (line_iterator.next()) |line| {
        if (line[0] == 'P') break;
        const n = try std.fmt.parseInt(u32, line, 10);
        try p1_deck.append(n);
    }
    while (line_iterator.next()) |line| {
        const n = try std.fmt.parseInt(u32, line, 10);
        try p2_deck.append(n);
    }

    var p1_copy = ArrayList(u32).init(allocator);
    var p2_copy = ArrayList(u32).init(allocator);
    p1_copy.appendSlice(p1_deck.items[0..]) catch unreachable;
    p2_copy.appendSlice(p2_deck.items[0..]) catch unreachable;

    var winner = if (war(&p1_deck, &p2_deck)) p1_deck else p2_deck;
    const part1_ans = score(&winner);

    winner = if (rec_war(&p1_copy, &p2_copy)) p1_copy else p2_copy;
    const part2_ans = score(&winner);

    print("=== Day 22 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
