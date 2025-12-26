const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1. 先创建一个共享的 root_module，这样库和测试都能共用一套配置
    const common_module = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target, // 必须在这里！
        .optimize = optimize, // 必须在这里！
    });

    // 2. 定义库
    const lib = b.addLibrary(.{
        .name = "colored",
        .root_module = common_module,
        .linkage = .static,
    });
    b.installArtifact(lib);

    // 3. 配置单元测试
    // 同样直接引用上面那个已经包含 target 的 common_module
    const lib_unit_tests = b.addTest(.{
        .root_module = common_module,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
