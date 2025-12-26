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
        .{ ITALIC, Styles.Italic },
        .{ UNDERLINE, Styles.Underline },
        .{ BLINK, Styles.Blink },
        .{ REVERSED, Styles.Reversed },
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

    pub fn add(self: *Style, rhs: Styles) void {
        self.*.val |= rhs.to_u8();
        return;
    }
    pub fn remove(self: *Style, rhs: Styles) void {
        self.*.val &= ~rhs.to_u8();
        return;
    }
};

const CLEAR: Style = .{ .val = CLEARV };

pub const Styles = enum {
    Clear,
    Bold,
    Dimmed,
    Italic,
    Underline,
    Blink,
    Reversed,
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

    fn bitAnd(self: Styles, rhs: Style) Style {
        return Style{ .val = self.to_u8() & rhs.val };
    }
    fn bitXor(self: Styles, rhs: Style) Style {
        return Style{ .val = self.to_u8() ^ rhs.val };
    }
    fn not(self: Styles) Style {
        return Style{ .val = ~self.to_u8() };
    }
};
const testing = std.testing;

test "Style: 基础位运算逻辑" {
    var s = Style.default();

    // 测试添加
    s.add(.Bold);
    s.add(.Underline);
    try testing.expect(s.contains(.Bold));
    try testing.expect(s.contains(.Underline));
    try testing.expectEqual(@as(u8, BOLD | UNDERLINE), s.val);

    // 测试移除
    s.remove(.Bold);
    try testing.expect(!s.contains(.Bold));
    try testing.expect(s.contains(.Underline));
}

test "Style: 字符串输出验证 (to_str)" {
    const alloc = testing.allocator;

    // --- 适配 Zig 0.15 的 ArrayList 写法 ---

    // 情况 1: 多重样式 (验证分号分割)
    {
        var s = Style.default();
        s.add(.Bold);
        s.add(.Italic);
        s.add(.Strikethrough);

        // 使用 empty 初始化，deinit 必须传 alloc
        var list = std.ArrayList(u8).empty;
        defer list.deinit(alloc);

        // 注意：writer() 现在需要传入 allocator
        // 因为 .empty 本身不持有分配器状态
        try s.to_str(list.writer(alloc));

        // 按照你代码中 STYLES 的定义顺序：Bold(1), Italic(3), Strikethrough(9)
        // 实际输出取决于 STYLES 数组里的排列
        try testing.expectEqualStrings("1;3;9", list.items);
    }

    // 情况 2: 无样式输出为空
    {
        const s = Style.default();
        var list = std.ArrayList(u8).empty;
        defer list.deinit(alloc);

        try s.to_str(list.writer(alloc));
        try testing.expectEqualStrings("", list.items);
    }
}

test "Styles: 逻辑运算辅助函数" {
    // 验证枚举转字符
    try testing.expectEqual(@as(u8, '1'), Styles.Bold.to_char());

    // 验证 bitAnd (修正之前的隐式初始化写法)
    const s_bold = Style{ .val = BOLD };
    const result = Styles.Bold.bitAnd(s_bold);
    try testing.expectEqual(BOLD, result.val);

    // 验证 not
    const s_not = Styles.Bold.not();
    try testing.expectEqual(@as(u8, ~BOLD), s_not.val);
}

test "Style: 顺序一致性压力测试" {
    const alloc = testing.allocator;
    var s = Style.default();

    // 按照 STYLES 数组中定义的全部顺序添加
    const all = [_]Styles{ .Bold, .Dimmed, .Underline, .Reversed, .Italic, .Blink, .Hidden, .Strikethrough };
    for (all) |item| s.add(item);

    var list = std.ArrayList(u8).empty;
    defer list.deinit(alloc);

    try s.to_str(list.writer(alloc));

    // 这里验证的是你 STYLES 数组中定义的物理顺序
    // 目前定义是：Bold(1), Dimmed(2), Underline(4), Reversed(7), Italic(3), Blink(5), Hidden(8), Strikethrough(9)
    try testing.expectEqualStrings("1;2;4;7;3;5;8;9", list.items);
}
