const std = @import("std");
const sf = @import("sfml").graphics;
const gl = @import("gl");

const c = @cImport({
    @cInclude("windows.h");
    @cInclude("GL/gl.h");
});

// Define the type for wglGetProcAddress
const WglGetProcAddress = *const fn ([*c]const u8) callconv(.C) ?*anyopaque;

// Global variable to hold the wglGetProcAddress function pointer
var wglGetProcAddressPtr: ?WglGetProcAddress = null;

// Function to load wglGetProcAddress
fn loadWglGetProcAddress() !void {
    const opengl32 = c.LoadLibraryA("opengl32.dll");
    if (opengl32 == null) return error.FailedToLoadOpenGL32;

    wglGetProcAddressPtr = @ptrCast(c.GetProcAddress(opengl32, "wglGetProcAddress"));
    if (wglGetProcAddressPtr == null) return error.FailedToGetWglGetProcAddress;
}

// The main getProcAddress function
pub fn getProcAddress(name: [*:0]const u8) ?*const anyopaque {
    if (wglGetProcAddressPtr == null) {
        loadWglGetProcAddress() catch |err| {
            std.debug.print("Failed to load wglGetProcAddress: {}\n", .{err});
            return null;
        };
    }

    if (wglGetProcAddressPtr.?(name)) |proc| {
        return proc;
    }

    const opengl32 = c.LoadLibraryA("opengl32.dll");
    if (opengl32 == null) return null;

    return c.GetProcAddress(opengl32, name);
}

var procs: gl.ProcTable = undefined;

pub fn main() !void {
    std.debug.print("Hello world!", .{});
    var window = try sf.RenderWindow.createDefault(.{ .x = 800, .y = 800 }, "SFML works!");
    defer window.destroy();

    if (!procs.init(getProcAddress)) return error.InitFailed;

    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    while (window.isOpen()) {
        std.debug.print("In loop\n", .{});
        while (window.pollEvent()) |event| {
            if (event == .closed)
                window.close();
        }

        gl.Clear(gl.COLOR_BUFFER_BIT);
    }
}
