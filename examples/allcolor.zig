const std = @import("std");
const colored = @import("colored");

pub fn main() !void {
    const all_color = [_]colored.Color{ .Black, .BrightBlack, .Red, .BrightRed, .Green, .BrightGreen, .Yellow, .BrightYellow };
    const bg_color = [_]colored.Color{
        .Blue,
        .BrightBlue,
        .Magenta,
        .BrightMagenta,
        .Cyan,
        .BrightCyan,
        .White,
        .BrightWhite,
    };
    // all styles use
    var str = colored.ColoredString.from_str("Hello World!");
    _ = str.bold();
    std.debug.print("{f} ", .{str});
    _ = str.clear().dimmed();
    std.debug.print("{f} ", .{str});
    _ = str.clear().blink();
    std.debug.print("{f} ", .{str});
    _ = str.clear().reversed();
    std.debug.print("{f} ", .{str});
    std.debug.print("\n", .{});
    _ = str.clear().hidden();
    std.debug.print("{f} ", .{str});
    _ = str.clear().underline();
    std.debug.print("{f} ", .{str});
    _ = str.clear().strikethrough();
    std.debug.print("{f} ", .{str});
    _ = str.clear().italic();
    std.debug.print("{f} ", .{str});
    std.debug.print("\n", .{});
    for (all_color) |color| {
        _ = str.clear();
        _ = str.add_fgcolor(color);
        std.debug.print("{f} ", .{str});
    }
    std.debug.print("\n", .{});
    for (bg_color) |color| {
        _ = str.clear();
        _ = str.add_bgcolor(color).black();
        std.debug.print("{f} ", .{str});
    }
    std.debug.print("\n", .{});
}
