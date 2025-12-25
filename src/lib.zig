const std = @import("std");
const Style = @import("style.zig").Style;
const Styles = @import("style.zig").Styles;
pub const Color = @import("color.zig").Color;

pub const ColoredString = struct {
    input: []const u8,
    fg_color: ?Color = null,
    bg_color: ?Color = null,
    style: Style = Style.default(),

    pub fn get_fgcolor(self: *ColoredString) ?Color {
        return self.fg_color;
    }
    pub fn get_bgcolor(self: *ColoredString) ?Color {
        return self.bg_color;
    }
    pub fn get_style(self: *ColoredString) Style {
        return self.style;
    }

    ///
    pub fn clear_fg(self: *ColoredString) *ColoredString {
        self.fg_color = null;
        return self;
    }
    pub fn clear_bg(self: *ColoredString) *ColoredString {
        self.bg_color = null;
        return self;
    }
    pub fn clear_style(self: *ColoredString) *ColoredString {
        self.style = Style.default();
        return self;
    }

    pub fn is_plain(self: *ColoredString) bool {
        return (self.fg_color == null) and (self.fg_color == null) and (self.style == Style.default());
    }
    fn compute_style(self: *ColoredString, alloc: std.mem.Allocator) ![]const u8 {
        if (self.is_plain()) {
            return "";
        }
        var res = std.ArrayList(u8).empty;
        try res.appendSlice(alloc, "\x1B[");

        var has_written = if (self.style == Style.default()) {
            false;
        } else {
            const styles = try self.style.to_str(alloc);
            defer alloc.free(styles);
            try res.appendSlice(alloc, styles);
            true;
        };

        if (self.fg_color) |fg| {
            if (has_written) {
                res.append(alloc, ';');
            }
            const fg_str = try fg.to_fg_str(alloc);
            defer alloc.free(fg_str);
            res.appendSlice(alloc, fg_str);
            has_written = true;
        }

        if (self.bg_color) |bg| {
            if (has_written) {
                res.append(alloc, ';');
            }
            const bg_str = try bg.to_bg_str(alloc);
            defer alloc.free(bg_str);
            res.appendSlice(alloc, bg_str);
            has_written = true;
        }
        res.append(alloc, 'm');
        return try res.toOwnedSlice(alloc);
    }

    pub fn from_str(input: []const u8) ColoredString {
        return ColoredString{
            .input = input,
        };
    }
    pub fn set_fgcolor(self: *ColoredString, color: Color) *ColoredString {
        self.*.fg_color = color;
        return self;
    }

    pub fn set_bgcolor(self: *ColoredString, color: Color) *ColoredString {
        self.*.bg_color = color;
        return self;
    }
    pub fn clear(self: *ColoredString) *ColoredString {
        self.clear_fg();
        self.clear_bg();
        self.clear_style();
        return self;
    }
    pub fn bold(self: *ColoredString) *ColoredString {
        self.*.style.add(Styles.Bold);
        return self;
    }
    pub fn dimmed(self: *ColoredString) *ColoredString {
        self.*.style.add(Styles.Dimmed);
        return self;
    }
    pub fn underline(self: *ColoredString) *ColoredString {
        self.*.style.add(Styles.Underline);
        return self;
    }
    pub fn reversed(self: *ColoredString) *ColoredString {
        self.*.style.add(Styles.Reversed);
        return self;
    }
    pub fn italic(self: *ColoredString) *ColoredString {
        self.*.style.add(Styles.Italic);
        return self;
    }
    pub fn blink(self: *ColoredString) *ColoredString {
        self.*.style.add(Styles.Blink);
        return self;
    }
    pub fn hidden(self: *ColoredString) *ColoredString {
        self.*.style.add(Styles.Hidden);
        return self;
    }
    pub fn strikethrough(self: *ColoredString) *ColoredString {
        self.*.style.add(Styles.Strikethrough);
        return self;
    }
    pub fn format(self: ColoredString, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        if (self.is_plain()) {
            try writer.writeAll(self.input);
            return;
        }

        try writer.writeAll("{}\x1b[0m", .{self.compute_style(alloc)});
    }
};

const testing = std.testing;
test "init coloredString" {
    var c = ColoredString.from_str("asd");
    _ = c.set_fgcolor(.Black);

    // try testing.expectEqual(c, ColoredString{ .input = "asd" });
}
