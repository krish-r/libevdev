# libevdev

This is [libevdev](https://www.freedesktop.org/software/libevdev/doc/latest/), packaged for [Zig](https://ziglang.org/).

**NOTE**: This repository includes only basic build functionality (still a WIP, not thoroughly tested yet).

## Dependencies

* Python3

## Usage

* Update your `build.zig.zon`:

```
zig fetch --save git+https://github.com/krish-r/libevdev.git
```

* Add the following snippet to your `build.zig` script:

```zig
const dep_optimize = b.option(std.builtin.OptimizeMode, "dep-optimize", "optimization mode") orelse .ReleaseFast;

const libevdev = b.dependency("libevdev", .{
    .target = target,
    .optimize = dep_optimize,
});
your_compilation.linkLibrary(libevdev.artifact("evdev"));
```

This will provide libevdev as a shared library to `your_compilation`.


## Credits

- [libevdev](https://gitlab.freedesktop.org/libevdev/libevdev)
- [All Your Codebase](https://github.com/allyourcodebase)
- [Ziggit](https://ziggit.dev)
