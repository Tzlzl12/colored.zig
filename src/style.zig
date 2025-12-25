const std = @import("std");

const CLEARV: u8 = 0b0000_0000;
const BOLD: u8 = 0b0000_0001;
const UNDERLINE: u8 = 0b0000_0010;
const REVERSED: u8 = 0b0000_0100;
const ITALIC: u8 = 0b0000_1000;
const BLINK: u8 = 0b0001_0000;
const HIDDEN: u8 = 0b0010_0000;
const DIMMED: u8 = 0b0100_0000;
const STRIKETHROUGH: u8 = 0b1000_0000;

const Tuple = struct { u8, Styles };
pub const Style = struct {
    val: u8,
    const STYLES: [8]Tuple = .{
        .{ BOLD, Styles.Bold },
        .{ DIMMED, Styles.Dimmed },
        .{ UNDERLINE, Styles.Underline },
        .{ REVERSED, Styles.Reversed },
        .{ ITALIC, Styles.Italic },
        .{ BLINK, Styles.Blink },
        .{ HIDDEN, Styles.Hidden },
        .{ STRIKETHROUGH, Styles.Strikethrough },
    };
    pub fn default() Style {
        return Style{ .val = CLEARV };
    }
    pub fn contains(self: Style, style: Styles) bool {
        return self.val & style.to_u8() == style.to_u8();
    }
    pub fn to_str(self: Style, writer: anytype) !void {
        var first = true;
        for (STYLES) |value| {
            const mask = value[0];
            const style = value[1];
            if (mask & self.val == mask) {
                if (!first) {
                    try writer.writeByte(';');
                }
                try writer.writeByte(style.to_char());
                first = false;
            }
        }
    }
    // pub fn to_str(alloc: std.mem.Allocator, style: Style) ![]const u8 {
    //     var res = std.ArrayList(u8).empty;
    //
    //     const styles = try Styles.from_u8(style.val, alloc);
    //     defer if (styles) |s| alloc.free(s);
    //
    //     if (styles) |s| {
    //         for (s) |value| {
    //             try res.append(alloc, value.to_char());
    //             try res.append(alloc, ';');
    //         }
    //
    //         return try res.toOwnedSlice(alloc);
    //     } else {
    //         return "";
    //     }
    // }
    pub fn add(self: *Style, rhs: Styles) void {
        self.*.val |= rhs.to_u8();
        return;
    }
    pub fn remove(self: *Style, rhs: Styles) void {
        self.*.val &= ~rhs.to_u8();
        return;
    }
    // pub fn bold(self: *Style) Style {
    //     return self.add(Styles.Bold);
    // }
    // pub fn dimmed(self: *Style) Style {
    //     return self.add(Styles.Dimmed);
    // }
    // pub fn underline(self: *Style) Style {
    //     return self.add(Styles.Underline);
    // }
    // pub fn reversed(self: *Style) Style {
    //     return self.add(Styles.Reversed);
    // }
    // pub fn italic(self: *Style) Style {
    //     return self.add(Styles.Italic);
    // }
    // pub fn blink(self: Style) Style {
    //     return self.add(Styles.Blink);
    // }
    // pub fn hidden(self: Style) Style {
    //     return self.add(Styles.Hidden);
    // }
    // pub fn strikethrough(self: Style) Style {
    //     return self.add(Styles.Strikethrough);
    // }
};

const CLEAR: Style = .{ .val = CLEARV };

pub const Styles = enum {
    Clear,
    Bold,
    Dimmed,
    Underline,
    Reversed,
    Italic,
    Blink,
    Hidden,
    Strikethrough,

    fn to_char(self: Styles) u8 {
        return switch (self) {
            .Clear => unreachable,
            .Bold => '1',
            .Dimmed => '2',
            .Italic => '3',
            .Underline => '4',
            .Blink => '5',
            .Reversed => '7',
            .Hidden => '8',
            .Strikethrough => '9',
        };
    }
    fn to_u8(self: Styles) u8 {
        return switch (self) {
            .Clear => CLEARV,
            .Bold => BOLD,
            .Dimmed => DIMMED,
            .Underline => UNDERLINE,
            .Reversed => REVERSED,
            .Italic => ITALIC,
            .Blink => BLINK,
            .Hidden => HIDDEN,
            .Strikethrough => STRIKETHROUGH,
        };
    }

    // fn from_u8(val: u8, writer: anytype) !void {
    //     if (val == CLEARV) {
    //         return;
    //     }
    //     for (STYLES) |style| {
    //         if (style[0] & val == style[0]) {
    //             try writer.writeByte(style[1].to_char());
    //         }
    //     }
    // }

    fn bitAnd(self: Styles, rhs: Style) Style {
        return .{self.to_u8() & rhs.val};
    }
    fn bitXor(self: Styles, rhs: Style) Style {
        return .{self.to_u8() ^ rhs.val};
    }
    fn not(self: Styles) Style {
        return .{~self.to_u8()};
    }
};
