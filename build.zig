const std = @import("std");
const sfml = @import("sfml");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "helloTriangle",
        .root_source_file = b.path("./src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    //SFML with CSFML and zig-sfml-wrapper by Guigui220D
    const sfml_dep = b.dependency("sfml", .{}).module("sfml");
    exe.root_module.addImport("sfml", sfml_dep);

    sfml_dep.addIncludePath(b.path("CSFML/include/"));
    exe.addLibraryPath(b.path("CSFML/lib/msvc/"));

    sfml.link(exe);

    //OpenGL bindings with zigglgen
    const gl_bindings = @import("zigglgen").generateBindingsModule(b, .{
        .api = .gl,
        .version = .@"4.1",
        .profile = .core,
        .extensions = &.{ .ARB_clip_control, .NV_scissor_exclusive },
    });

    exe.root_module.addImport("gl", gl_bindings);
    exe.linkSystemLibrary("opengl32");

    //Install and run
    b.installArtifact(exe);

    if (b.option(bool, "run", "Run the app") orelse false) {
        const run = b.addRunArtifact(exe);
        run.step.dependOn(b.getInstallStep());

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run.step);

        b.default_step = run_step;
    }
}
