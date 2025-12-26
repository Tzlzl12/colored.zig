const std = @import("std");
const colored = @import("colored");

pub fn main() !void {
    var color = colored.ColoredString.from_str("hello world!");
    _ = color.red().bold().on_brightblack();

    std.debug.print("{f}\n", .{color});
    std.log.info("{f}", .{color});
}
