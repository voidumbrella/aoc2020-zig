const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day13_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

// Finds (g, x, y) such that a * x + b * y = g = gcd(a, b)
fn egcd(a: i64, b: i64, x: *i64, y: *i64) i64 {
    if (a == 0) {
        x.* = 0;
        y.* = 1;
        return b;
    } else {
        const g = egcd(@mod(b, a), a, x, y);
        const tmp = x.*;
        x.* = y.* - @divTrunc(b, a) * x.*;
        y.* = tmp;
        return g;
    }
}

// a * x + m * y = 1
// a * x = 1 (mod m)
fn modinv(a: i64, m: i64) i64 {
    var x: i64 = undefined;
    var y: i64 = undefined;
    const g = egcd(a, m, &x, &y);
    assert(g == 1);
    return x;
}

pub fn main() !void {
    var timer = try Timer.start();

    var part1_ans: i64 = 0;
    var part2_ans: i64 = 0;
    var part_iterator = std.mem.tokenize(input, "\n,");

    const time = try std.fmt.parseInt(i64, part_iterator.next().?, 10);

    var min_id: i64 = undefined;
    var min_time: i64 = std.math.maxInt(i64);

    var min: i64 = 0;
    var a: i64 = 0;
    var b: i64 = 0;
    while (part_iterator.next()) |part| {
        if (part[0] == 'x') {
            min += 1;
            continue;
        }
        const m = try std.fmt.parseInt(i64, part, 10);

        // Part 1
        const waiting_time = m * (@divTrunc(time, m) + 1) - time;
        if (min_time > waiting_time) {
            min_id = m;
            min_time = waiting_time;
        }

        // Part 2
        //
        // For each bus, we get the modular equation
        // t = -r_i (mod m_i)
        // where m is the ID of the ith bus and r is the number of minutes it should arrive after.
        //
        // This implies
        // t = m_i * x_i + r_i  for some x_i
        // Renaming variables,
        // t = a_i * x_i + b_i
        //
        // Substitute that into the equation for the next bus to get
        // a_i * x_i + b_i = r_i+1 (mod m_i+1)
        //
        // Let y_i = modinv(a_i, m_i).
        // (The bus IDs all happen to be coprime, so it is guaranteed to exist)
        //
        // Solve for x_i,
        // x_i = y_i (r_i+1 - b_i) (mod m_i+1)
        // implying
        // x_i = m_i+1 * x_i+1 + (y_i (r_i+1 - b_i)) % m_i+1   for some x_i+1
        //
        // Substitute this back in,
        // t = a_i * [m_i+1 * x_i+1 + (y_i (r_i+1 - b_i)) % m_i+1] + b_i
        // t = [a_i * m_i+1] * x_i+1 + [a_i * (y_i * (r_i+1 - b_i)) % m + b_i]
        //
        // So
        // a_i+1 = a_i * m_i+1
        // b_i+1 = b_i + a_i * (y_i * (r_i+1 - b_i)) % m_i+1
        //
        // Do this for each equation to get
        // t = ax + b
        //
        // Since a is the product of all moduli, for each modulo m_i
        // t = b (mod m_i)
        // and therefore t = b is the smallest number that satisfies each modular equation.
        if (a == 0) {
            a = m;
            b = 0;
        } else {
            b += a * @mod(modinv(a, m) * -(min + b), m);
            a *= m;
        }

        min += 1;
    }
    part1_ans = min_time * min_id;
    part2_ans = b;

    print("=== Day 13 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
