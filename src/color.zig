const std = @import("std");

const ColorError = error{
    InvalidColor,
};

pub const Color = union(enum) {
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
    BrightBlack,
    BrightRed,
    BrightGreen,
    BrightYellow,
    BrightBlue,
    BrightMagenta,
    BrightCyan,
    BrightWhite,
    AnsiColor: u8,
    TrueColor: struct { u8, u8, u8 },

    /// TODO: windows is not support
    pub fn truecolor_support() bool {
        const val = std.posix.getenv("COLORTERM") orelse return false;
        return std.mem.eql(u8, val, "truecolor") or std.mem.eql(u8, val, "24bit");
    }

    pub fn to_fg_str(self: Color, writer: anytype) !void {
        switch (self) {
            .Black => try writer.writeAll("30"),
            .Red => try writer.writeAll("31"),
            .Green => try writer.writeAll("32"),
            .Yellow => try writer.writeAll("33"),
            .Blue => try writer.writeAll("34"),
            .Magenta => try writer.writeAll("35"),
            .Cyan => try writer.writeAll("36"),
            .White => try writer.writeAll("37"),
            .BrightBlack => try writer.writeAll("90"),
            .BrightRed => try writer.writeAll("91"),
            .BrightGreen => try writer.writeAll("92"),
            .BrightYellow => try writer.writeAll("93"),
            .BrightBlue => try writer.writeAll("94"),
            .BrightMagenta => try writer.writeAll("95"),
            .BrightCyan => try writer.writeAll("96"),
            .BrightWhite => try writer.writeAll("97"),
            .AnsiColor => |n| try writer.print("38;5;{d}", .{n}),
            .TrueColor => |color| try writer.print("38;2;{d};{d};{d}", .{ color[0], color[1], color[2] }),
        }
    }
    pub fn to_bg_str(self: Color, writer: anytype) !void {
        return switch (self) {
            .Black => try writer.writeAll("40"),
            .Red => try writer.writeAll("41"),
            .Green => try writer.writeAll("42"),
            .Yellow => try writer.writeAll("43"),
            .Blue => try writer.writeAll("44"),
            .Magenta => try writer.writeAll("45"),
            .Cyan => try writer.writeAll("46"),
            .White => try writer.writeAll("47"),
            .BrightBlack => try writer.writeAll("100"),
            .BrightRed => try writer.writeAll("101"),
            .BrightGreen => try writer.writeAll("102"),
            .BrightYellow => try writer.writeAll("103"),
            .BrightBlue => try writer.writeAll("104"),
            .BrightMagenta => try writer.writeAll("105"),
            .BrightCyan => try writer.writeAll("106"),
            .BrightWhite => try writer.writeAll("107"),
            .AnsiColor => |n| try writer.print("48;5;{d}", .{n}),
            .TrueColor => |color| try writer.print("48;2;{d};{d};{d}", .{ color[0], color[1], color[2] }),
        };
    }
    pub fn into_truecolor(self: Color) Color {
        return switch (self) {
            .Black => Color{ .TrueColor = .{ 17, 19, 23 } }, // #111317
            .Red => Color{ .TrueColor = .{ 255, 131, 139 } }, // #ff838b
            .Green => Color{ .TrueColor = .{ 135, 192, 95 } }, // #87c05f
            .Yellow => Color{ .TrueColor = .{ 223, 171, 37 } }, // #dfab25
            .Blue => Color{ .TrueColor = .{ 94, 183, 255 } }, // #5eb7ff
            .Magenta => Color{ .TrueColor = .{ 221, 151, 241 } }, // #dd97f1
            .Cyan => Color{ .TrueColor = .{ 74, 194, 184 } }, // #4ec2b8
            .White => Color{ .TrueColor = .{ 155, 159, 169 } }, // #9b9fa9

            .BrightBlack => Color{ .TrueColor = .{ 42, 47, 56 } }, // #2a2f38
            .BrightRed => Color{ .TrueColor = .{ 255, 220, 223 } }, // #ffe4df
            .BrightGreen => Color{ .TrueColor = .{ 226, 241, 215 } }, // #e2f1d7
            .BrightYellow => Color{ .TrueColor = .{ 244, 228, 187 } }, // #f4e4bb
            .BrightBlue => Color{ .TrueColor = .{ 200, 230, 255 } }, // #c8e6ff
            .BrightMagenta => Color{ .TrueColor = .{ 243, 222, 249 } }, // #f3def9
            .BrightCyan => Color{ .TrueColor = .{ 188, 235, 231 } }, // #bbede7
            .BrightWhite => Color{ .TrueColor = .{ 236, 237, 241 } }, // #ecedf1
            else => self,
        };
    }
    pub fn from_str(str: []const u8) !Color {
        if (std.mem.eql(u8, str, "black")) return .Black;
        if (std.mem.eql(u8, str, "red")) return .Red;
        if (std.mem.eql(u8, str, "green")) return .Green;
        if (std.mem.eql(u8, str, "yellow")) return .Yellow;
        if (std.mem.eql(u8, str, "blue")) return .Blue;
        if (std.mem.eql(u8, str, "magenta")) return .Magenta;
        if (std.mem.eql(u8, str, "cyan")) return .Cyan;
        if (std.mem.eql(u8, str, "white")) return .White;
        if (std.mem.eql(u8, str, "bright black")) return .BrightBlack;
        if (std.mem.eql(u8, str, "bright red")) return .BrightRed;
        if (std.mem.eql(u8, str, "bright green")) return .BrightGreen;
        if (std.mem.eql(u8, str, "bright yellow")) return .BrightYellow;
        if (std.mem.eql(u8, str, "bright blue")) return .BrightBlue;
        if (std.mem.eql(u8, str, "bright magenta")) return .BrightMagenta;
        if (std.mem.eql(u8, str, "bright cyan")) return .BrightCyan;
        if (std.mem.eql(u8, str, "bright white")) return .BrightWhite;

        if (str.len > 0 and str[0] == '#') {
            return parse_hex(str[1..]);
        }

        return error.InvalidColor;
    }
    fn parse_hex(str: []const u8) !Color {
        if (str.len == 6) {
            return .{ .TrueColor = .{
                try std.fmt.parseInt(u8, str[0..2], 16),
                try std.fmt.parseInt(u8, str[2..4], 16),
                try std.fmt.parseInt(u8, str[4..6], 16),
            } };
        } else if (str.len == 3) {
            const r = try std.fmt.parseInt(u8, str[0..1], 16);
            const red = r | (r << 4);
            const g = try std.fmt.parseInt(u8, str[1..2], 16);
            const green = g | (g << 4);
            const b = try std.fmt.parseInt(u8, str[2..3], 16);
            const blue = b | (b << 4);
            return .{ .TrueColor = .{ red, green, blue } };
        } else {
            return error.InvalidColor;
        }
    }
};

const testing = std.testing;
test "env variables" {
    const val = Color.truecolor_support();
    try std.testing.expect(val);

    const str = "#112200";
    std.debug.print("{}\n", .{str.len});
}

test "to_fg_str - basic colors" {
    const cases = [_]struct { color: Color, expected: []const u8 }{
        .{ .color = .Black, .expected = "30" },
        .{ .color = .BrightMagenta, .expected = "95" },
        .{ .color = .White, .expected = "37" },
    };

    for (cases) |case| {
        var list = std.ArrayList(u8).empty;
        defer list.deinit(testing.allocator);

        // 必须传 writer，不能传 alloc
        try case.color.to_fg_str(list.writer(testing.allocator));
        try testing.expectEqualStrings(case.expected, list.items);
    }
}

test "to_fg_str - 256 colors" {
    const c = Color{ .AnsiColor = 45 };
    var list = std.ArrayList(u8).empty;
    defer list.deinit(testing.allocator);

    const w = list.writer(testing.allocator);
    try c.to_fg_str(w);

    try testing.expectEqualStrings("38;5;45", list.items);
}

test "to_fg_str - TrueColor" {
    const c = Color{ .TrueColor = .{ 123, 45, 67 } };
    var list = std.ArrayList(u8).empty;
    defer list.deinit(testing.allocator);

    const w = list.writer(testing.allocator);
    try c.to_fg_str(w);

    try testing.expectEqualStrings("38;2;123;45;67", list.items);
}

test "to_bg_str - bright background + 256 color" {
    {
        const c = Color{ .BrightYellow = {} };
        var list = std.ArrayList(u8).empty;
        defer list.deinit(testing.allocator);
        try c.to_bg_str(list.writer(testing.allocator));
        try testing.expectEqualStrings("103", list.items);
    }

    {
        const c = Color{ .AnsiColor = 199 };
        var list = std.ArrayList(u8).empty;
        defer list.deinit(testing.allocator);
        try c.to_bg_str(list.writer(testing.allocator));
        try testing.expectEqualStrings("48;5;199", list.items);
    }
}

test "from_str - basic colors" {
    const cases = [_]struct { input: []const u8, expected: Color }{
        .{ .input = "red", .expected = .Red },
        .{ .input = "blue", .expected = .Blue },
        .{ .input = "yellow", .expected = .Yellow },
    };

    for (cases) |c| {
        const result = try Color.from_str(c.input);
        try testing.expectEqual(c.expected, result);
    }
}

test "from_str - hex color #rrggbb" {
    const cases = [_]struct { input: []const u8, expected: Color }{
        .{ .input = "#FF0000", .expected = .{ .TrueColor = .{ 255, 0, 0 } } },
        .{ .input = "#00ff00", .expected = .{ .TrueColor = .{ 0, 255, 0 } } },
        .{ .input = "#123456", .expected = .{ .TrueColor = .{ 18, 52, 86 } } },
    };

    for (cases) |c| {
        const result = try Color.from_str(c.input);
        try testing.expectEqual(c.expected, result);
    }
}

test "from_str - short hex #rgb" {
    const cases = [_]struct { input: []const u8, expected: Color }{
        .{ .input = "#f00", .expected = .{ .TrueColor = .{ 255, 0, 0 } } },
        .{ .input = "#0af", .expected = .{ .TrueColor = .{ 0, 170, 255 } } },
    };

    for (cases) |c| {
        const result = try Color.from_str(c.input);
        try testing.expectEqual(c.expected, result);
    }
}
