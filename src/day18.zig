const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day18_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

fn consume(expr: []const u8, index: *usize) ?u8 {
    var i: usize = index.*;
    while (i < expr.len) : (i += 1) {
        if (expr[i] == ' ') continue;
        index.* = i + 1;
        return expr[i];
    }
    return null;
}

fn peek(expr: []const u8, index: *usize) ?u8 {
    var i: usize = index.*;
    while (i < expr.len) : (i += 1) {
        if (expr[i] == ' ') continue;
        return expr[i];
    }
    return null;
}

// Either a number or expression in parentheses
fn eval_term_part1(expr: []const u8, i: *usize) u64 {
    const token: u8 = consume(expr, i).?;

    if (token == '(') {
        const result = part1_eval(expr, i);
        const right_paren = consume(expr, i) orelse @panic("Expected matching right paren");
        assert(right_paren == ')');
        return result;
    } else { // Assuming number
        return token - '0';
    }
}

fn part1_eval(expr: []const u8, i: *usize) u64 {
    var result: u64 = eval_term_part1(expr, i);
    while (true) {
        const op = peek(expr, i) orelse break;
        if (op == '+') {
            _ = consume(expr, i);
            result += eval_term_part1(expr, i);
        } else if (op == '*') {
            _ = consume(expr, i);
            result *= eval_term_part1(expr, i);
        } else break;
    }

    return result;
}

// Either a number or expression in parentheses
fn eval_term(expr: []const u8, i: *usize) u64 {
    const token: u8 = consume(expr, i).?;

    if (token == '(') {
        const result = part2_eval(expr, i);
        const right_paren = consume(expr, i) orelse @panic("Expected matching right paren");
        assert(right_paren == ')');
        return result;
    } else { // Assuming number
        return token - '0';
    }
}

// Scan input, add all terms found, stop if multiplying
fn eval_sum(expr: []const u8, i: *usize) u64 {
    var result: u64 = eval_term(expr, i);
    while (true) {
        const op = peek(expr, i) orelse break;
        if (op == '+') {
            _ = consume(expr, i);
            result += eval_term(expr, i);
        } else break;
    }
    return result;
}

// Scan input, calculate any sums found, and multiply them
fn part2_eval(expr: []const u8, i: *usize) u64 {
    var result = eval_sum(expr, i);
    while (true) {
        const op = peek(expr, i) orelse break;
        if (op == '*') {
            _ = consume(expr, i);
            result *= eval_sum(expr, i);
        } else break;
    }
    return result;
}

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, "\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    while (line_iterator.next()) |line| {
        var i: usize = 0;
        part1_ans += part1_eval(line, &i);
        i = 0;
        part2_ans += part2_eval(line, &i);
    }

    print("=== Day 18 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
