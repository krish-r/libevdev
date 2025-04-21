pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libevdev_src = b.dependency("libevdev", .{});

    const os = switch (builtin.os.tag) {
        .linux, .freebsd => |supported| @tagName(supported),
        else => |unsupported| @compileError("Unsupported OS: '" ++ @tagName(unsupported) ++ "'"),
    };

    const linkage = b.option(std.builtin.LinkMode, "linkage", "link mode") orelse .dynamic;

    const root = libevdev_src.path("");
    const src = root.path(b, "libevdev");
    const include = root.path(b, "include");
    const include_subpath = include.path(b, b.fmt("linux/{s}", .{os}));

    const lib = b.addLibrary(.{
        .name = "evdev",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        .linkage = linkage,
        .version = version,
    });

    const input_h = include_subpath.path(b, "input.h");
    const input_event_codes_h = include_subpath.path(b, "input-event-codes.h");
    const libevdev_h = src.path(b, "libevdev.h");
    const libevdev_uinput_h = src.path(b, "libevdev-uinput.h");

    // NOTE: This depends on `python` to generate event-names.h
    const make_event_names = src.path(b, "make-event-names.py");
    const cmd = b.addSystemCommand(&.{"python"});
    cmd.addFileArg(make_event_names);
    cmd.addFileArg(libevdev_h);
    cmd.addFileArg(input_h);
    cmd.addFileArg(input_event_codes_h);
    const wf = b.addWriteFiles();
    _ = wf.addCopyFile(cmd.captureStdOut(), "event-names.h");

    const config_h = b.addConfigHeader(.{ .style = .blank }, .{ ._GNU_SOURCE = 1 });
    lib.addConfigHeader(config_h);

    lib.addCSourceFiles(.{
        .root = root,
        .files = files,
        .flags = flags,
    });

    lib.addIncludePath(root);
    lib.addIncludePath(src);
    lib.addIncludePath(include);
    lib.addIncludePath(include_subpath);
    lib.addIncludePath(wf.getDirectory());

    lib.installHeader(libevdev_h, "libevdev/libevdev.h");
    lib.installHeader(libevdev_uinput_h, "libevdev/libevdev-uinput.h");

    b.installArtifact(lib);
}

const std = @import("std");
const builtin = @import("builtin");

const files: []const []const u8 = &.{
    "libevdev/libevdev.c",
    "libevdev/libevdev-uinput.c",
    "libevdev/libevdev-names.c",
};

const flags: []const []const u8 = &.{
    "-std=gnu99", "-Wall", "-Wextra", // default_options
    "-Wno-unused-parameter", "-fvisibility=hidden", // cppflags
    "-Wmissing-prototypes", "-Wstrict-prototypes", // cflags
};

const libevdev_lt_c = 5;
const libevdev_lt_r = 0;
const libevdev_lt_a = 3;
const version: std.SemanticVersion = .{
    .major = libevdev_lt_c - libevdev_lt_a,
    .minor = libevdev_lt_a,
    .patch = libevdev_lt_r,
};
