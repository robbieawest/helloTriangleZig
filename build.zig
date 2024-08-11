const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "helloTriangle",
        .root_source_file = b.path("./src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    if (b.option(bool, "run", "Run the app") orelse false) {
        const run = b.addRunArtifact(exe);
        run.step.dependOn(b.getInstallStep());

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run.step);

        b.default_step = run_step;
    }
}
