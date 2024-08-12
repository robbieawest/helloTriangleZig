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
    var window = try sf.RenderWindow.createDefault(.{ .x = 800, .y = 800 }, "Hello Triangle");
    defer window.destroy();

    if (!procs.init(getProcAddress)) return error.InitFailed;

    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    const vertices = [9]f32{ -0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.0, 0.5, 0.0 }; //stupid zls formatting gonna make me jump off a high structure

    var VAO: c_uint = undefined;
    gl.GenVertexArrays(1, @ptrCast(&VAO));
    gl.BindVertexArray(VAO);

    var VBO: c_uint = undefined;
    gl.GenBuffers(1, @ptrCast(&VBO));
    defer gl.DeleteBuffers(1, @ptrCast(&VBO));
    gl.BindBuffer(gl.ARRAY_BUFFER, VBO);
    gl.BufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, gl.STATIC_DRAW);

    const vertexShaderSource = "#version 330core\n" ++
        "layout (location = 0) in vec3 aPos;\n" ++
        "void main()\n" ++
        "{\n" ++
        "   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n" ++
        "};";

    const vertexShader: c_uint = gl.CreateShader(gl.VERTEX_SHADER);
    defer gl.DeleteShader(vertexShader);
    gl.ShaderSource(vertexShader, 1, &[1][*]const u8{vertexShaderSource}, null);
    gl.CompileShader(vertexShader);

    const fragmentShaderSource = "#version 330core\n" ++
        "out vec4 FragColor;\n" ++
        "void main()\n" ++
        "{\n" ++
        "   FragColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);\n" ++
        "};";

    const fragmentShader: c_uint = gl.CreateShader(gl.FRAGMENT_SHADER);
    defer gl.DeleteShader(fragmentShader);
    gl.ShaderSource(fragmentShader, 1, &[1][*]const u8{fragmentShaderSource}, null);
    gl.CompileShader(fragmentShader);

    const shaderProgram: c_uint = gl.CreateProgram();
    gl.AttachShader(shaderProgram, vertexShader);
    gl.AttachShader(shaderProgram, fragmentShader);
    gl.LinkProgram(shaderProgram);
    gl.UseProgram(shaderProgram);

    //Linking vertex attributes, simple 3 v pos no colour or normals tight packed
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), 0);
    gl.EnableVertexAttribArray(0);

    while (window.isOpen()) {
        while (window.pollEvent()) |event| {
            if (event == .closed)
                window.close();
        }

        gl.ClearColor(0.2, 0.5, 0.3, 1.0);
        window.clear(sf.Color.Blue);

        //Draw
        gl.UseProgram(shaderProgram);
        gl.BindVertexArray(VAO);

        gl.DrawArrays(gl.TRIANGLES, 0, 3);
        window.display();
    }
}
