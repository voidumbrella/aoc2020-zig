/// This code sucks, and is slow, and will segfault since I actually never resize the grid
/// But I don't care about this enough to improve it
const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day17_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

const N = 20;

const Dimension = struct {
    grid: []bool,
    min_x: isize,
    max_x: isize,
    min_y: isize,
    max_y: isize,
    min_z: isize,
    max_z: isize,
    min_w: isize,
    max_w: isize,

    fn create() Dimension {
        var p = allocator.alloc(bool, N * N * N * N) catch unreachable;
        return Dimension{
            .grid = p,
            .min_x = 0,
            .max_x = 0,
            .min_y = 0,
            .max_y = 0,
            .min_z = 0,
            .max_z = 0,
            .min_w = 0,
            .max_w = 0,
        };
    }

    fn clone(self: *Dimension) Dimension {
        var p = allocator.alloc(bool, N * N * N * N) catch unreachable;
        std.mem.copy(bool, p, self.grid);
        return Dimension{
            .grid = p,
            .min_x = self.min_x,
            .max_x = self.max_x,
            .min_y = self.min_y,
            .max_y = self.max_y,
            .min_z = self.min_z,
            .max_z = self.max_z,
            .min_w = self.min_w,
            .max_w = self.max_w,
        };
    }

    fn translate(x: isize, y: isize, z: isize, w: isize) usize {
        return @intCast(usize, (N / 2 + w) * N * N * N + (N / 2 + z) * N * N + (N / 2 + y) * N + (N / 2 + x));
    }

    fn isActive(self: *Dimension, x: isize, y: isize, z: isize, w: isize) bool {
        return self.grid[translate(x, y, z, w)];
    }

    fn set(self: *Dimension, x: isize, y: isize, z: isize, w: isize) void {
        if (x < self.min_x) self.min_x = x;
        if (x > self.max_x) self.max_x = x;
        if (y < self.min_y) self.min_y = y;
        if (y > self.max_y) self.max_y = y;
        if (z < self.min_z) self.min_z = z;
        if (z > self.max_z) self.max_z = z;
        if (w < self.min_w) self.min_w = w;
        if (w > self.max_w) self.max_w = w;
        self.grid[translate(x, y, z, w)] = true;
    }

    fn clear(self: *Dimension, x: isize, y: isize, z: isize, w: isize) void {
        self.grid[translate(x, y, z, w)] = false;
    }

    fn neighbors(self: *Dimension, x: isize, y: isize, z: isize) u64 {
        var count: u64 = 0;

        var dx: i64 = -1;
        while (dx <= 1) : (dx += 1) {
            var dy: i64 = -1;
            while (dy <= 1) : (dy += 1) {
                var dz: i64 = -1;
                while (dz <= 1) : (dz += 1) {
                    if (dx == 0 and dy == 0 and dz == 0) continue;
                    if (self.isActive(x + dx, y + dy, z + dz, 0)) count += 1;
                }
            }
        }
        return count;
    }

    fn hyperNeighbors(self: *Dimension, x: isize, y: isize, z: isize, w: isize) u64 {
        var count: u64 = 0;

        var dx: i64 = -1;
        while (dx <= 1) : (dx += 1) {
            var dy: i64 = -1;
            while (dy <= 1) : (dy += 1) {
                var dz: i64 = -1;
                while (dz <= 1) : (dz += 1) {
                    var dw: i64 = -1;
                    while (dw <= 1) : (dw += 1) {
                        if (dx == 0 and dy == 0 and dz == 0 and dw == 0) continue;
                        if (self.isActive(x + dx, y + dy, z + dz, w + dw)) count += 1;
                    }
                }
            }
        }
        return count;
    }

    fn update(self: *Dimension) void {
        var cloned = self.clone();
        var z: isize = cloned.min_z - 1;
        while (z <= cloned.max_z + 1) : (z += 1) {
            var y: isize = cloned.min_y - 1;
            while (y <= cloned.max_y + 1) : (y += 1) {
                var x: isize = cloned.min_x - 1;
                while (x <= cloned.max_x + 1) : (x += 1) {
                    const n = cloned.neighbors(x, y, z);
                    if (cloned.isActive(x, y, z, 0)) {
                        if (n != 2 and n != 3)
                            self.clear(x, y, z, 0);
                    } else {
                        if (n == 3)
                            self.set(x, y, z, 0);
                    }
                }
            }
        }
        allocator.free(cloned.grid);
    }

    fn hyperUpdate(self: *Dimension) void {
        var cloned = self.clone();
        var w: isize = cloned.min_w - 1;
        while (w <= cloned.max_w + 1) : (w += 1) {
            var z: isize = cloned.min_z - 1;
            while (z <= cloned.max_z + 1) : (z += 1) {
                var y: isize = cloned.min_y - 1;
                while (y <= cloned.max_y + 1) : (y += 1) {
                    var x: isize = cloned.min_x - 1;
                    while (x <= cloned.max_x + 1) : (x += 1) {
                        const n = cloned.hyperNeighbors(x, y, z, w);
                        if (cloned.isActive(x, y, z, w)) {
                            if (n != 2 and n != 3)
                                self.clear(x, y, z, w);
                        } else {
                            if (n == 3)
                                self.set(x, y, z, w);
                        }
                    }
                }
            }
        }
        allocator.free(cloned.grid);
    }
};

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, "\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    var dimension = Dimension.create();
    {
        var y: i64 = 0;
        while (line_iterator.next()) |line| {
            var x: i64 = 0;
            for (line) |c| {
                if (c == '#') {
                    dimension.set(x, y, 0, 0);
                }
                x += 1;
            }
            y += 1;
        }
    }

    var part1 = dimension.clone();

    {
        var i: usize = 0;
        while (i < 6) : (i += 1)
            part1.update();

        for (part1.grid) |b| {
            if (b) part1_ans += 1;
        }
    }

    var part2 = dimension.clone();

    {
        var i: usize = 0;
        while (i < 6) : (i += 1)
            part2.hyperUpdate();

        for (part2.grid) |b| {
            if (b) part2_ans += 1;
        }
    }

    print("=== Day 17 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
