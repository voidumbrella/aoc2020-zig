const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../input/day20_input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

const Border = enum {
    top, bottom, left, right
};

const Tile = struct {
    id: u64,

    p: [10][10]u8 = [_][10]u8{[_]u8{'.'} ** 10} ** 10,
    fixed: bool = false,

    fn print(self: Tile) void {
        print("{}: {}\n", .{ self.id, self.fixed });
        for (self.p) |row| {
            for (row) |c| {
                print("{c}", .{c});
            }
            print("\n", .{});
        }
    }

    fn rotate(self: *Tile) void {
        var new = [_][10]u8{[_]u8{'.'} ** 10} ** 10;
        var i: usize = 0;
        while (i < 10) : (i += 1) {
            var j: usize = 0;
            while (j < 10) : (j += 1) {
                new[i][j] = self.p[9 - j][i];
            }
        }

        i = 0;
        while (i < 10) : (i += 1) {
            std.mem.copy(u8, &self.p[i], &new[i]);
        }
    }

    fn flipX(self: *Tile) void {
        var i: usize = 0;
        while (i < 10) : (i += 1) {
            var j: usize = 0;
            while (j < 5) : (j += 1) {
                var tmp = self.p[i][j];
                self.p[i][j] = self.p[i][9 - j];
                self.p[i][9 - j] = tmp;
            }
        }
    }

    fn flipY(self: *Tile) void {
        var i: usize = 0;
        while (i < 5) : (i += 1) {
            var j: usize = 0;
            while (j < 10) : (j += 1) {
                var tmp = self.p[i][j];
                self.p[i][j] = self.p[9 - i][j];
                self.p[9 - i][j] = tmp;
            }
        }
    }

    fn match(self: *const Tile, other: *const Tile) ?Border {
        if (std.mem.eql(u8, &self.p[0], &other.p[9])) return Border.top;
        if (std.mem.eql(u8, &self.p[9], &other.p[0])) return Border.bottom;

        var i: usize = 0;
        var left: bool = true;
        var right: bool = true;
        while (i < 10) : (i += 1) {
            if (self.p[i][0] != other.p[i][9]) left = false;
            if (self.p[i][9] != other.p[i][0]) right = false;
        }
        if (left) return Border.left;
        if (right) return Border.right;

        return null;
    }

    fn findMatch(self: *Tile, other: *Tile) ?Border {
        assert(!self.fixed);
        var rots: u8 = 0;
        var found: ?Border = null;
        while (rots < 4) : (rots += 1) {
            if (self.match(other)) |b| {
                found = b;
                break;
            }
            self.rotate();
        }

        return found;
    }
};

const Image = struct {
    p: [96][96]u8 = [_][96]u8{[_]u8{'.'} ** 96} ** 96,

    fn place(self: *Image, x: usize, y: usize, tile: Tile) void {
        assert(x < 12 and y < 12);
        tile.print();
        print("\n", .{});

        for (tile.p[1..10]) |row, i| {
            for (row[1..10]) |c, j| {
                self.p[y * 8 + i][x * 8 + j] = c;
            }
        }
    }

    fn print(self: Image) void {
        for (self.p) |row| {
            for (row) |c| {
                print("{c}", .{c});
            }
            print("\n", .{});
        }
    }
};

fn eql(a: []const u8, b: []const u8) bool {
    assert(a.len == b.len);
    for (a) |c, i|
        if (c != b[i]) return false;
    return true;
}

fn reql(a: []const u8, b: []const u8) bool {
    assert(a.len == b.len);
    for (a) |c, i|
        if (c != b[b.len - 1 - i]) return false;
    return true;
}

pub fn main() !void {
    var timer = try Timer.start();

    var tile_iterator = std.mem.split(input, "\n\n");

    var tiles = ArrayList(Tile).init(allocator);

    while (tile_iterator.next()) |tile_str| {
        var line_iterator = std.mem.tokenize(tile_str, " :\n");
        _ = line_iterator.next().?; // "Tile "
        const id = try std.fmt.parseInt(u64, line_iterator.next().?, 0);

        var i: usize = 0;

        var tile = Tile{ .id = id };

        while (line_iterator.next()) |line| {
            std.mem.copy(u8, &tile.p[i], line);
            i += 1;
        }

        try tiles.append(tile);
    }

    var image = Image{};

    var part1_ans: u64 = 1;

    // Find corner pieces for part 1, and determine right orientation for each tile
    var i: usize = 0;
    while (i < tiles.items.len) : (i += 1) {
        var self = &tiles.items[i];

        var j: usize = 0;
        while (j < tiles.items.len) : (j += 1) {
            if (j == i) continue;

            var other = &tiles.items[j];
        }
    }

    // Finding upper-left corner
    for (tiles.items) |self| {
        // var top = false;
        // var left = false;
        // var right = false;
        // var bottom = false;
        // for (tiles.items) |other| {
        //     if (other.id == self.id) continue;

        //     if (self.match(&other)) |b| {
        //         if (b == Border.top) top = true;
        //         if (b == Border.left) left = true;
        //         if (b == Border.right) right = true;
        //         if (b == Border.bottom) bottom = true;
        //     }
        // }
        // if (!right and !bottom and !top and !left)
        //     image.place(0, 0, self);
    }

    var part2_ans: u64 = 0;

    print("=== Day 20 === ({} µs)\n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
