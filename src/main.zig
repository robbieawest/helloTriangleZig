const std = @import("std");
const sf = @import("sfml").graphics;

pub fn main() !void {
    std.debug.print("Hello world!", .{});
    var window = try sf.RenderWindow.createDefault(.{ .x = 800, .y = 800 }, "SFML works!");
    defer window.destroy();

    var shape = try sf.CircleShape.create(100.0);
    defer shape.destroy();
    shape.setFillColor(sf.Color.Green);

    while (window.isOpen()) {
        while (window.pollEvent()) |event| {
            if (event == .closed)
                window.close();
        }

        window.clear(sf.Color.Black);
        window.draw(shape, null);
        window.display();
    }
}
