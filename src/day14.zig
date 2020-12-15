const std = @import("std");
const ArrayList = std.ArrayList;
const Map = std.AutoHashMap;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day14_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

fn write(mem: *Map(usize, u64), float_bits: []const u6, addr: usize, val: u64) void {
    if (float_bits.len == 0) return;
    const cleared = addr & ~(@as(u64, 1) << float_bits[0]);
    const set = addr | @as(u64, 1) << float_bits[0];
    mem.put(cleared, val) catch unreachable;
    mem.put(set, val) catch unreachable;
    write(mem, float_bits[1..], cleared, val);
    write(mem, float_bits[1..], set, val);
}

pub fn main() !void {
    var timer = try Timer.start();

    var part_iterator = std.mem.tokenize(input, " =[]\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    var part1_mem = Map(usize, u64).init(allocator);
    var part2_mem = Map(usize, u64).init(allocator);

    var mask: []const u8 = undefined;
    while (part_iterator.next()) |part| {
        if (std.mem.eql(u8, part, "mask")) {
            mask = part_iterator.next().?;
        } else if (std.mem.eql(u8, part, "mem")) {
            const addr = try std.fmt.parseInt(usize, part_iterator.next().?, 10);
            const val = try std.fmt.parseInt(u64, part_iterator.next().?, 10);

            var float_bits = ArrayList(u6).init(allocator);

            // Part 1
            var masked_addr = addr;
            var masked_val = val;
            var i: u6 = 0;
            while (i < 36) : (i += 1) {
                const c = mask[35 - i];
                if (c == '0') {
                    masked_val &= ~(@as(u64, 1) << i);
                } else if (c == '1') {
                    masked_val |= @as(u64, 1) << i;
                    masked_addr |= @as(u64, 1) << i;
                } else if (c == 'X') {
                    try float_bits.append(i);
                }
            }
            try part1_mem.put(addr, masked_val);

            // Part 2
            write(&part2_mem, float_bits.items, masked_addr, val);
        }
    }

    var mem_iterator = part1_mem.iterator();
    while (mem_iterator.next()) |e| part1_ans += e.value;

    mem_iterator = part2_mem.iterator();
    while (mem_iterator.next()) |e| part2_ans += e.value;

    print("=== Day 14 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
