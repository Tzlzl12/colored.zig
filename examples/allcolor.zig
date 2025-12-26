const std = @import("std");
const colored = @import("colored");

pub fn main() !void {
    const all_color = [_]colored.Color{
        .Black,
        .BrightBlack,
        .Red,
        .BrightRed,
        .Green,
        .BrightGreen,
        .Yellow,
        .BrightYellow,
        .Blue,
        .BrightBlue,
        .Magenta,
        .BrightMagenta,
        .Cyan,
        .BrightCyan,
        .White,
        .BrightWhite,
    };
    var str = colored.ColoredString.from_str("Hello World!");
    for (all_color) |color| {
        _ = str.clear();
        _ = str.add_fgcolor(color).bold();
        std.debug.print("{f}\n", .{str});
    }
}
