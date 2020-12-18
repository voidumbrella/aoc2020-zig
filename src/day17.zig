const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day17_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

const Point = struct {
    x: i64,
    y: i64,
    z: i64,
    w: i64,
};

const Map = std.AutoHashMap(Point, void);

const Dimension = struct {
    points: Map,
    need_check: Map,

    fn init(a: *Allocator) Dimension {
        return Dimension{
            .points = Map.init(a),
            .need_check = Map.init(a),
        };
    }

    fn set(self: *Dimension, point: Point) !void {
        try self.points.put(point, .{});

        var dx: i64 = -1;
        while (dx <= 1) : (dx += 1) {
            var dy: i64 = -1;
            while (dy <= 1) : (dy += 1) {
                var dz: i64 = -1;
                while (dz <= 1) : (dz += 1) {
                    try self.need_check.put(Point{
                        .x = point.x + dx,
                        .y = point.y + dy,
                        .z = point.z + dz,
                        .w = point.w,
                    }, .{});
                }
            }
        }
    }

    fn hyperSet(self: *Dimension, point: Point) !void {
        try self.points.put(point, .{});

        var dx: i64 = -1;
        while (dx <= 1) : (dx += 1) {
            var dy: i64 = -1;
            while (dy <= 1) : (dy += 1) {
                var dz: i64 = -1;
                while (dz <= 1) : (dz += 1) {
                    var dw: i64 = -1;
                    while (dw <= 1) : (dw += 1) {
                        try self.need_check.put(Point{
                            .x = point.x + dx,
                            .y = point.y + dy,
                            .z = point.z + dz,
                            .w = point.w + dw,
                        }, .{});
                    }
                }
            }
        }
    }

    fn neighbors(self: *Dimension, point: Point) u16 {
        var count: u16 = 0;

        var dx: i64 = -1;
        while (dx <= 1) : (dx += 1) {
            var dy: i64 = -1;
            while (dy <= 1) : (dy += 1) {
                var dz: i64 = -1;
                while (dz <= 1) : (dz += 1) {
                    if (dx == 0 and dy == 0 and dz == 0) continue;
                    if (self.points.get(Point{
                        .x = point.x + dx,
                        .y = point.y + dy,
                        .z = point.z + dz,
                        .w = point.w,
                    }) != null) count += 1;
                }
            }
        }

        return count;
    }

    fn hyperNeighbors(self: *Dimension, point: Point) u16 {
        var count: u16 = 0;

        var dx: i64 = -1;
        while (dx <= 1) : (dx += 1) {
            var dy: i64 = -1;
            while (dy <= 1) : (dy += 1) {
                var dz: i64 = -1;
                while (dz <= 1) : (dz += 1) {
                    var dw: i64 = -1;
                    while (dw <= 1) : (dw += 1) {
                        if (dx == 0 and dy == 0 and dz == 0 and dw == 0) continue;
                        if (self.points.get(Point{
                            .x = point.x + dx,
                            .y = point.y + dy,
                            .z = point.z + dz,
                            .w = point.w + dw,
                        }) != null) count += 1;
                    }
                }
            }
        }

        return count;
    }

    fn step(self: *Dimension) !void {
        var new = Dimension.init(allocator);

        var iterator = self.need_check.iterator();
        while (iterator.next()) |e| {
            const point = e.key;
            const ns = self.neighbors(point);
            if (self.points.get(point) != null) {
                if (ns == 2 or ns == 3)
                    try new.set(point);
            } else {
                if (ns == 3)
                    try new.set(point);
            }
        }

        var tmp = self.*;
        self.* = new;
        tmp.points.deinit();
        tmp.need_check.deinit();
    }

    fn hyperStep(self: *Dimension) !void {
        var new = Dimension.init(allocator);

        var iterator = self.need_check.iterator();
        while (iterator.next()) |e| {
            const point = e.key;
            const ns = self.hyperNeighbors(point);
            if (self.points.get(point) != null) {
                if (ns == 2 or ns == 3)
                    try new.hyperSet(point);
            } else {
                if (ns == 3)
                    try new.hyperSet(point);
            }
        }

        var tmp = self.*;
        self.* = new;
        tmp.points.deinit();
        tmp.need_check.deinit();
    }
};

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, "\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    var dim = Dimension.init(allocator);
    var hyperdim = Dimension.init(allocator);
    {
        var y: i64 = 0;
        while (line_iterator.next()) |line| {
            var x: i64 = 0;
            for (line) |c| {
                if (c == '#') {
                    const p = Point{
                        .x = x,
                        .y = y,
                        .z = 0,
                        .w = 0,
                    };
                    try dim.set(p);
                    try hyperdim.hyperSet(p);
                }
                x += 1;
            }
            y += 1;
        }
    }

    var i: usize = 0;
    while (i < 6) : (i += 1) {
        try dim.step();
        try hyperdim.hyperStep();
    }
    part1_ans = dim.points.count();
    part2_ans = hyperdim.points.count();

    print("=== Day 17 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
