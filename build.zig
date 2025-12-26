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
    // 3. 实现 Rust 风格的 Examples
    // 假设你的例子放在 examples/ 目录下，例如 examples/hello.zig
    const examples_step = b.step("examples", "Build all examples");

    // 遍历 examples 文件夹
    var iter_dir = std.fs.openDirAbsolute(b.pathFromRoot("examples"), .{ .iterate = true }) catch return;
    var it = iter_dir.iterate();
    while (it.next() catch null) |entry| {
        // 只处理以 .zig 结尾的文件
        if (entry.kind == .file and std.mem.endsWith(u8, entry.name, ".zig")) {
            const example_name = entry.name[0 .. entry.name.len - 4]; // 去掉 .zig 后缀
            const example_path = b.fmt("examples/{s}", .{entry.name});

            // 为每个例子创建一个可执行文件
            const exe = b.addExecutable(.{
                .name = example_name,
                .root_module = b.createModule(.{
                    .root_source_file = b.path(example_path),
                    .target = target,
                    .optimize = optimize,
                }),
            });

            // 让例子能够 @import("colored")
            exe.root_module.addImport("colored", common_module);

            // 将编译结果放入 zig-out/bin/examples
            const install_exe = b.addInstallArtifact(exe, .{
                .dest_dir = .{ .override = .{ .custom = "bin/examples" } },
            });

            examples_step.dependOn(&install_exe.step);

            // 创建运行步骤：zig build run-example-hello
            const run_cmd = b.addRunArtifact(exe);
            const run_step = b.step(b.fmt("run-example-{s}", .{example_name}), b.fmt("Run the {s} example", .{example_name}));
            run_step.dependOn(&run_cmd.step);
        }
    }
    // 3. 配置单元测试
    // 同样直接引用上面那个已经包含 target 的 common_module
    const lib_unit_tests = b.addTest(.{
        .root_module = common_module,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
