const std = @import("std");

const colored = @import("colored");

pub fn main() !void {
    var str = colored.ColoredString.from_str("Hello World!");
    _ = str.add_fgcolor(colored.Color{ .AnsiColor = 45 });
    std.debug.print("custom color {f}\n", .{str});

    _ = str.clear().add_fgcolor(colored.Color{ .TrueColor = .{ 221, 151, 241 } });
    std.debug.print("true color {f}\n", .{str});
    _ = str.clear().add_fgcolor(try colored.Color.from_str("#ffe4df"));
    std.debug.print("hex color {f}\n", .{str});
}
