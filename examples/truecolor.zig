const std = @import("std");
const colored = @import("colored");

pub fn main() !void {
    var str = colored.ColoredString.from_str("Hello World!");

    _ = str.add_fgcolor(.Cyan).bold();
    std.debug.print("true color {f}\n", .{str});
    _ = str.clear().cyan().bold();
    std.debug.print("base color{f}\n", .{str});

    var s = colored.ColoredString.from_str("Next Const is Wrong");
    _ = s.add_fgcolor(.BrightRed).underline();
    std.log.info("{f}", .{s});
    var str1 = colored.ColoredString.from_str("Learn from Colored-rs");
    _ = str1.add_bgcolor(.Yellow).add_fgcolor(.Blue);
    std.log.info("{f}", .{str1});
}
