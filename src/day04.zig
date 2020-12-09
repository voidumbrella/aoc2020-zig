const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const HashMap = std.StringHashMap;
const Timer = std.time.Timer;
const assert = std.debug.assert;
const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

const input = @embedFile("../input/day04_input.txt");

pub fn main() !void {
    var timer = try Timer.start();

    var line_iterator = std.mem.split(input, "\n");

    const Passport: type = HashMap([]const u8);

    var passports = ArrayList(Passport).init(allocator);

    {
        var passport: Passport = Passport.init(allocator);
        while (line_iterator.next()) |line| {
            var iterator = std.mem.tokenize(line, ": ");

            while (iterator.next()) |key| {
                const value = iterator.next().?;
                try passport.put(key, value);
            }

            if (line.len == 0) {
                try passports.append(passport);
                passport = Passport.init(allocator);
            }
        }
    }

    var req_keys = [_][]const u8{
        "byr",
        "iyr",
        "eyr",
        "hgt",
        "hcl",
        "ecl",
        "pid",
    };

    var part1_ans: u32 = 0;
    var part2_ans: u32 = 0;
    outer: for (passports.items) |passport| {
        for (req_keys) |key| {
            if (!passport.contains(key))
                continue :outer;
        }
        part1_ans += 1;

        const byr = std.fmt.parseInt(u32, passport.get("byr").?, 10) catch |_| continue;
        if (byr < 1920 or byr > 2002) continue;

        const iyr = std.fmt.parseInt(u32, passport.get("iyr").?, 10) catch |_| continue;
        if (iyr < 2010 or iyr > 2020) continue;

        const eyr = std.fmt.parseInt(u32, passport.get("eyr").?, 10) catch |_| continue;
        if (eyr < 2020 or eyr > 2030) continue;

        const hgt_s = passport.get("hgt").?;
        if (std.mem.endsWith(u8, hgt_s, "cm")) {
            const hgt = std.fmt.parseInt(u32, hgt_s[0 .. hgt_s.len - 2], 10) catch |_| continue;
            if (hgt < 150 or hgt > 193) continue;
        } else if (std.mem.endsWith(u8, hgt_s, "in")) {
            const hgt = std.fmt.parseInt(u32, hgt_s[0 .. hgt_s.len - 2], 10) catch |_| continue;
            if (hgt < 59 or hgt > 76) continue;
        } else continue;

        const hcl = passport.get("hcl").?;
        if (hcl[0] != '#' or hcl.len != 7) continue;
        for (hcl[1..]) |c| {
            if (!std.ascii.isAlNum(c))
                continue :outer;
        }

        const ecl = passport.get("ecl").?;
        if (!std.mem.eql(u8, ecl, "amb") and
            !std.mem.eql(u8, ecl, "blu") and
            !std.mem.eql(u8, ecl, "brn") and
            !std.mem.eql(u8, ecl, "gry") and
            !std.mem.eql(u8, ecl, "grn") and
            !std.mem.eql(u8, ecl, "hzl") and
            !std.mem.eql(u8, ecl, "oth")) continue;

        const pid = passport.get("pid").?;
        if (pid.len != 9) continue;
        _ = std.fmt.parseInt(u32, pid, 10) catch |_| continue;

        part2_ans += 1;
    }

    print("=== Day 04 === ({} µs) \n", .{timer.lap() / 1000});
    print("Part 1: {}\nPart 2: {}\n", .{ part1_ans, part2_ans });
}
