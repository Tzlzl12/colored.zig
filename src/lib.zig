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

    pub fn is_plain(self: ColoredString) bool {
        return (self.fg_color == null) and (self.bg_color == null) and (self.style.val == Style.default().val);
    }
    fn compute_style(self: ColoredString, writer: anytype) !void {
        if (self.is_plain()) {
            return;
        }
        try writer.writeAll("\x1B[");

        var has_written = false;
        if (self.style.val != Style.default().val) {
            try self.style.to_str(writer);
            has_written = true;
        }

        if (self.fg_color) |fg| {
            if (has_written) {
                try writer.writeByte(';');
            }
            try fg.to_fg_str(writer);
            has_written = true;
        }

        if (self.bg_color) |bg| {
            if (has_written) {
                try writer.writeByte(';');
            }
            try bg.to_bg_str(writer);
            has_written = true;
        }
        try writer.writeByte('m');
        return;
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
    pub fn black(self: *ColoredString) *ColoredString {
        self.*.fg_color = .Black;
        return self;
    }
    pub fn red(self: *ColoredString) *ColoredString {
        self.*.fg_color = .Red;
        return self;
    }
    pub fn green(self: *ColoredString) *ColoredString {
        self.*.fg_color = .Green;
        return self;
    }
    pub fn yellow(self: *ColoredString) *ColoredString {
        self.*.fg_color = .Yellow;
        return self;
    }
    pub fn blue(self: *ColoredString) *ColoredString {
        self.*.fg_color = .Blue;
        return self;
    }
    pub fn magenta(self: *ColoredString) *ColoredString {
        self.*.fg_color = .Magenta;
        return self;
    }
    pub fn cyan(self: *ColoredString) *ColoredString {
        self.*.fg_color = .Cyan;
        return self;
    }
    pub fn white(self: *ColoredString) *ColoredString {
        self.*.fg_color = .White;
        return self;
    }
    pub fn bright_black(self: *ColoredString) *ColoredString {
        self.*.fg_color = .BrightBlack;
        return self;
    }
    pub fn bright_red(self: *ColoredString) *ColoredString {
        self.*.fg_color = .BrightRed;
        return self;
    }
    pub fn bright_green(self: *ColoredString) *ColoredString {
        self.*.fg_color = .BrightGreen;
        return self;
    }
    pub fn bright_yellow(self: *ColoredString) *ColoredString {
        self.*.fg_color = .BrightYellow;
        return self;
    }
    pub fn bright_blue(self: *ColoredString) *ColoredString {
        self.*.fg_color = .BrightBlue;
        return self;
    }
    pub fn bright_magenta(self: *ColoredString) *ColoredString {
        self.*.fg_color = .BrightMagenta;
        return self;
    }
    pub fn bright_cyan(self: *ColoredString) *ColoredString {
        self.*.fg_color = .BrightCyan;
        return self;
    }
    pub fn bright_white(self: *ColoredString) *ColoredString {
        self.*.fg_color = .BrightWhite;
        return self;
    }
    pub fn bold(self: *ColoredString) *ColoredString {
        self.*.style.add(Styles.Bold);
        return self;
    }
    pub fn on_black(self: *ColoredString) *ColoredString {
        self.*.bg_color = .Black;
        return self;
    }
    pub fn on_red(self: *ColoredString) *ColoredString {
        self.*.bg_color = .Red;
        return self;
    }
    pub fn on_green(self: *ColoredString) *ColoredString {
        self.*.bg_color = .Green;
        return self;
    }
    pub fn on_yellow(self: *ColoredString) *ColoredString {
        self.*.bg_color = .Yellow;
        return self;
    }
    pub fn on_blue(self: *ColoredString) *ColoredString {
        self.*.bg_color = .Blue;
        return self;
    }
    pub fn on_magenta(self: *ColoredString) *ColoredString {
        self.*.bg_color = .Magenta;
        return self;
    }
    pub fn on_cyan(self: *ColoredString) *ColoredString {
        self.*.bg_color = .Cyan;
        return self;
    }
    pub fn on_white(self: *ColoredString) *ColoredString {
        self.*.bg_color = .White;
        return self;
    }
    pub fn on_brightblack(self: *ColoredString) *ColoredString {
        self.*.bg_color = .BrightBlack;
        return self;
    }
    pub fn on_brightred(self: *ColoredString) *ColoredString {
        self.*.bg_color = .BrightRed;
        return self;
    }
    pub fn on_brightgreen(self: *ColoredString) *ColoredString {
        self.*.bg_color = .BrightGreen;
        return self;
    }
    pub fn on_brightyellow(self: *ColoredString) *ColoredString {
        self.*.bg_color = .BrightYellow;
        return self;
    }
    pub fn on_brightblue(self: *ColoredString) *ColoredString {
        self.*.bg_color = .BrightBlue;
        return self;
    }
    pub fn on_brightmagenta(self: *ColoredString) *ColoredString {
        self.*.bg_color = .BrightMagenta;
        return self;
    }
    pub fn on_brightcyan(self: *ColoredString) *ColoredString {
        self.*.bg_color = .BrightCyan;
        return self;
    }
    pub fn on_brightwhite(self: *ColoredString) *ColoredString {
        self.*.bg_color = .BrightWhite;
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
    pub fn format(
        self: ColoredString,
        writer: anytype,
    ) !void {
        if (self.fg_color == null and self.bg_color == null and self.style.val == Style.default().val) {
            try writer.writeAll(self.input);
            return;
        }

        try self.compute_style(writer);
        try writer.writeAll(self.input);
        try writer.writeAll("\x1b[0m");
    }
};

const testing = std.testing;
test "Color: 验证前景色输出" {
    // 显式声明 Color 类型，确保 Union 激活
    const color: Color = .Red;
    const alloc = std.testing.allocator;

    // 1. 初始化空列表
    var list = std.ArrayList(u8).empty;
    // 2. 注意：现代 Zig 中 empty 对应的 deinit 需要传入 allocator
    defer list.deinit(alloc);

    // 3. 正确传入 writer (必须带上分配器)
    try color.to_fg_str(list.writer(alloc));

    // 验证输出是否为 "31"
    try std.testing.expectEqualStrings("31", list.items);
}

test "ColoredString: 完整流程测试" {
    var c = ColoredString.from_str("asd");
    _ = c.red().bold();

    const alloc = std.testing.allocator;

    var list = std.ArrayList(u8).empty;
    defer list.deinit(alloc);
    std.debug.print("{f}", .{c});

    // 这里调用 ColoredString 的 format
    try c.format(list.writer(alloc));

    // 预期结果：\x1b[1;31masd\x1b[0m
    try std.testing.expectEqualStrings("\x1b[1;31masd\x1b[0m", list.items);
}
