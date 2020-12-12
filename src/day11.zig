const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day11_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

const Tile = enum {
    floor,
    seat,
    occupied,
};

const Map = struct {
    tiles: []Tile,
    width: usize,
    height: usize,

    fn dup(self: *Map) Map {
        var tiles = allocator.alloc(Tile, self.width * self.height) catch unreachable;
        std.mem.copy(Tile, tiles, self.tiles);
        var copy = Map{
            .tiles = tiles,
            .width = self.width,
            .height = self.height,
        };
        return copy;
    }

    fn get(self: *const Map, x: usize, y: usize) Tile {
        return self.tiles[y * self.width + x];
    }

    fn peek(self: *const Map, x_i: usize, y_i: usize, dx: isize, dy: isize) bool {
        var x: isize = @intCast(isize, x_i) + dx;
        var y: isize = @intCast(isize, y_i) + dy;
        if (x >= 0 and x <= self.width - 1 and y >= 0 and y <= self.height - 1) {
            const tile = get(self, @intCast(usize, x), @intCast(usize, y));
            if (tile == Tile.occupied) return true;
        }
        return false;
    }

    fn neighbors_part1(self: *const Map, x: usize, y: usize) usize {
        var count: usize = 0;

        if (self.peek(x, y, -1, 0)) count += 1;
        if (self.peek(x, y, 1, 0)) count += 1;

        if (self.peek(x, y, 0, 1)) count += 1;
        if (self.peek(x, y, 0, -1)) count += 1;

        if (self.peek(x, y, -1, -1)) count += 1;
        if (self.peek(x, y, -1, 1)) count += 1;
        if (self.peek(x, y, 1, -1)) count += 1;
        if (self.peek(x, y, 1, 1)) count += 1;

        return count;
    }

    fn scan(self: *const Map, x_i: usize, y_i: usize, dx: isize, dy: isize) bool {
        var x: isize = @intCast(isize, x_i) + dx;
        var y: isize = @intCast(isize, y_i) + dy;
        while (x >= 0 and x <= self.width - 1 and y >= 0 and y <= self.height - 1) : ({
            x += dx;
            y += dy;
        }) {
            const tile = get(self, @intCast(usize, x), @intCast(usize, y));
            if (tile == Tile.occupied) return true;
            if (tile == Tile.seat) return false;
        }
        return false;
    }

    fn neighbors_part2(self: *const Map, x: usize, y: usize) usize {
        var count: usize = 0;

        if (self.scan(x, y, -1, 0)) count += 1;
        if (self.scan(x, y, 1, 0)) count += 1;

        if (self.scan(x, y, 0, 1)) count += 1;
        if (self.scan(x, y, 0, -1)) count += 1;

        if (self.scan(x, y, -1, -1)) count += 1;
        if (self.scan(x, y, -1, 1)) count += 1;
        if (self.scan(x, y, 1, -1)) count += 1;
        if (self.scan(x, y, 1, 1)) count += 1;

        return count;
    }

    fn run_part1(self: *Map) void {
        var scratch = allocator.alloc(Tile, self.width * self.height) catch unreachable;
        while (true) {
            var y: usize = 0;
            while (y < self.height) : (y += 1) {
                var x: usize = 0;
                while (x < self.width) : (x += 1) {
                    const tile = get(self, x, y);
                    switch (tile) {
                        Tile.floor => scratch[y * self.width + x] = Tile.floor,
                        Tile.seat => {
                            if (neighbors_part1(self, x, y) == 0)
                                scratch[y * self.width + x] = Tile.occupied
                            else
                                scratch[y * self.width + x] = Tile.seat;
                        },
                        Tile.occupied => {
                            if (neighbors_part1(self, x, y) >= 4)
                                scratch[y * self.width + x] = Tile.seat
                            else
                                scratch[y * self.width + x] = Tile.occupied;
                        },
                    }
                }
            }
            if (std.mem.eql(Tile, self.tiles, scratch)) return;
            const tmp = self.tiles;
            self.tiles = scratch;
            scratch = tmp;
        }
    }

    fn run_part2(self: *Map) void {
        var scratch = allocator.alloc(Tile, self.width * self.height) catch unreachable;
        while (true) {
            var y: usize = 0;
            while (y < self.height) : (y += 1) {
                var x: usize = 0;
                while (x < self.width) : (x += 1) {
                    const tile = get(self, x, y);
                    switch (tile) {
                        Tile.floor => scratch[y * self.width + x] = Tile.floor,
                        Tile.seat => {
                            if (neighbors_part2(self, x, y) == 0)
                                scratch[y * self.width + x] = Tile.occupied
                            else
                                scratch[y * self.width + x] = Tile.seat;
                        },
                        Tile.occupied => {
                            if (neighbors_part2(self, x, y) >= 5)
                                scratch[y * self.width + x] = Tile.seat
                            else
                                scratch[y * self.width + x] = Tile.occupied;
                        },
                    }
                }
            }
            if (std.mem.eql(Tile, self.tiles, scratch)) return;
            const tmp = self.tiles;
            self.tiles = scratch;
            scratch = tmp;
        }
    }

    fn print(self: *Map) void {
        var y: usize = 0;
        while (y < self.height) : (y += 1) {
            var x: usize = 0;
            while (x < self.width) : (x += 1) {
                const tile = get(self, x, y);
                switch (tile) {
                    Tile.floor => print(".", .{}),
                    Tile.seat => print("L", .{}),
                    Tile.occupied => print("#", .{}),
                }
            }
            print("\n", .{});
        }
    }
};

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.tokenize(input, "\n");

    var part1_ans: u64 = 0;
    var part2_ans: u64 = 0;

    var tiles_al = ArrayList(Tile).init(allocator);

    var width: usize = 0;
    var height: usize = 0;
    while (line_iterator.next()) |line| {
        var tmp: usize = 0;
        for (line) |c| {
            tmp += 1;
            if (c == '.') try tiles_al.append(Tile.floor);
            if (c == 'L') try tiles_al.append(Tile.seat);
        }
        height += 1;
        width = tmp;
    }
    var tiles = tiles_al.toOwnedSlice();
    tiles_al.deinit();

    var orig = Map{
        .tiles = tiles,
        .width = width,
        .height = height,
    };

    {
        var temp = orig.dup();
        temp.run_part1();

        var y: usize = 0;
        while (y < temp.height) : (y += 1) {
            var x: usize = 0;
            while (x < temp.width) : (x += 1) {
                if (temp.get(x, y) == Tile.occupied) part1_ans += 1;
            }
        }
    }

    {
        var temp = orig.dup();
        temp.run_part2();

        var y: usize = 0;
        while (y < temp.height) : (y += 1) {
            var x: usize = 0;
            while (x < temp.width) : (x += 1) {
                if (temp.get(x, y) == Tile.occupied) part2_ans += 1;
            }
        }
    }

    print("=== Day 11 ({} µs) ===\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
