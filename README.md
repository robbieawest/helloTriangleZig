# helloTriangleZig

### Hello triangle for OpenGL in zig.
This currently only works for Windows, as SFML does not provide an equivalent to `glfw.getProcAddress()` (atleast as far as I know), and I only implemented `getProcAddress()` using windows APIs. Although if one wished they could implement it for linux as well.

### Build
Simply build with `zig build`, or `zig build -Drun` to build and execute immediately.

### Bindings
This uses the SFML and OpenGL bindings from [zig-sfml-wrapper](https://github.com/Guigui220D/zig-sfml-wrapper) and [zigglgen](https://github.com/castholm/zigglgen) respectively.
To include these in this project I used:
`zig fetch --save https://github.com/Guigui220D/zig-sfml-wrapper/archive/d5272051a937c8a3756bb96eab8276b76a271de4.tar.gz` and
`zig fetch --save https://github.com/castholm/zigglgen/releases/download/v0.2.3/zigglgen.tar.gz`, adding to the buiid.zig.zon file.
Changes to build.zig for each are available.

This also requires "opengl32.dll" to be stored either in `zig-out/bin`, where the SFML DLLs currently are, or in a place linked to by PATH.

### Versioning
This has been tested with zig `0.13.0` using the most recent changes up to 14/08/2024 for zigglgen and zig-sfml-wrapper. If you wish you can use the hashes above to get the same commits as I did.

This doesn't work for the zig master branch as of now (pretty much anything after `0.14.0`), due to zig-sfml-wrapper not having support for it.

