const std = @import("std");

const ColorError = error{
    InvalidColor,
    InvalidCharacter,
    Overflow,
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

    fn truecolor_support(alloc: std.mem.Allocator) !bool {
        const color_term = try std.process.getEnvVarOwned(alloc, "COLORTERM");
        defer alloc.free(color_term);
        return std.mem.eql(u8, color_term, "truecolor") or std.mem.eql(u8, color_term, "24bit");
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
    fn into_truecolor(self: Color) Color {
        return switch (self) {
            .Black => .{.TrueColor{ 0, 0, 0 }},
            .Red => .{.TrueColor{ 205, 0, 0 }},
            .Green => .{.TrueColor{ 0, 205, 0 }},
            .Yellow => .{.TrueColor{ 205, 205, 0 }},
            .Blue => .{.TrueColor{ 0, 0, 238 }},
            .Magenta => .{.TrueColor{ 205, 0, 205 }},
            .Cyan => .{.TrueColor{ 0, 205, 205 }},
            .White => .{.TrueColor{ 229, 229, 229 }},

            .BrightBlack => .{.TrueColor{ 127, 127, 127 }},
            .BrightRed => .{.TrueColor{ 255, 0, 0 }},
            .BrightGreen => .{.TrueColor{ 0, 255, 0 }},
            .BrightYellow => .{.TrueColor{ 255, 255, 0 }},
            .BrightBlue => .{.TrueColor{ 92, 92, 255 }},
            .BrightMagenta => .{.TrueColor{ 255, 0, 255 }},
            .BrightCyan => .{.TrueColor{ 0, 255, 255 }},
            .BrightWhite => .{.TrueColor{ 255, 255, 255 }},
            else => self,
        };
    }
    pub fn from_str(str: []const u8) ColorError!Color {
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
    fn parse_hex(str: []const u8) ColorError!Color {
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
    const alloc = testing.allocator;
    const val = try Color.truecolor_support(alloc);
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
