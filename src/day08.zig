const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day08_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

const Op = enum {
    acc, jmp, nop
};

const Instruction = struct {
    op: Op,
    arg: i64,
};

const Vm = struct {
    code: []Instruction,
    seen: []bool,
    accumulator: i64 = 0,
    ip: usize = 0,
    halted: bool = true,

    fn run(self: *Vm) void {
        self.accumulator = 0;
        self.ip = 0;
        std.mem.set(bool, self.seen, false);

        self.halted = true;
        while (true) {
            if (self.seen[self.ip]) {
                self.halted = false;
                return;
            }

            var ins = self.code[self.ip];
            self.seen[self.ip] = true;

            var step: isize = 1;
            switch (ins.op) {
                Op.nop => {},
                Op.jmp => step = ins.arg,
                Op.acc => self.accumulator += ins.arg,
            }
            self.ip = @intCast(usize, @intCast(isize, self.ip) + step);

            if (self.ip == self.code.len)
                return;
        }
    }
};

pub fn main() !void {
    var part_iterator = std.mem.tokenize(input, " \n");

    var part1_ans: i64 = 0;
    var part2_ans: i64 = 0;

    var code = ArrayList(Instruction).init(allocator);
    while (part_iterator.next()) |opstring| {
        const op = if (std.mem.eql(u8, opstring, "acc"))
            Op.acc
        else if (std.mem.eql(u8, opstring, "jmp"))
            Op.jmp
        else if (std.mem.eql(u8, opstring, "nop"))
            Op.nop
        else
            @panic("unexpected opcode");

        const varstring = part_iterator.next().?;
        const arg = try std.fmt.parseInt(i64, varstring, 10);

        const instruction = Instruction{
            .op = op,
            .arg = arg,
        };
        try code.append(instruction);
    }

    var buf = try allocator.alloc(bool, code.items.len);
    var vm = Vm{ .code = code.toOwnedSlice(), .seen = buf };

    vm.run();
    part1_ans = vm.accumulator;
    assert(!vm.halted);

    var i: usize = 0;
    while (i < vm.code.len) : (i += 1) {
        var cur = &vm.code[i].op;
        switch (vm.code[i].op) {
            Op.nop => cur.* = Op.jmp,
            Op.jmp => cur.* = Op.nop,
            Op.acc => continue,
        }

        vm.run();
        if (vm.halted) {
            part2_ans = vm.accumulator;
            break;
        }

        switch (vm.code[i].op) {
            Op.nop => cur.* = Op.jmp,
            Op.jmp => cur.* = Op.nop,
            Op.acc => continue,
        }
    }

    print("=== Day 08 ===\n", .{});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
