const std = @import("std");
pub const RGB = struct { u8, u8, u8 };

const CustomColor = struct {
    r: u8,
    g: u8,
    b: u8,
    pub fn new(r: u8, g: u8, b: u8) CustomColor {
        return CustomColor{ .r = r, .g = g, .b = b };
    }
    pub fn from_rgb(rgb: RGB) CustomColor {
        const r, const g, const b = rgb;
        return CustomColor{ .r = r, .g = g, .b = b };
    }
};

const testing = std.testing;

test "custom color " {
    const c = CustomColor.new(197, 50, 50);
    try testing.expectEqual(c, CustomColor{ .r = 197, .b = 50, .g = 50 });
}
