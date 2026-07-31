const canvas_file = @import("canvas.zig");
const Canvas = canvas_file.Canvas;
const Point = canvas_file.Point;

pub fn main() !void {
    var canvas = Canvas.init();
    canvas.clear(.{ .r = 245, .g = 247, .b = 250 });

    const polygon1 = [_]Point{
        .{ .x = 165, .y = 380 },
        .{ .x = 185, .y = 360 },
        .{ .x = 180, .y = 330 },
        .{ .x = 207, .y = 345 },
        .{ .x = 233, .y = 330 },
        .{ .x = 230, .y = 360 },
        .{ .x = 250, .y = 380 },
        .{ .x = 220, .y = 385 },
        .{ .x = 205, .y = 410 },
        .{ .x = 193, .y = 383 },
    };

    const polygon2 = [_]Point{
        .{ .x = 321, .y = 335 },
        .{ .x = 288, .y = 286 },
        .{ .x = 339, .y = 251 },
        .{ .x = 374, .y = 302 },
    };

    const polygon3 = [_]Point{
        .{ .x = 377, .y = 249 },
        .{ .x = 411, .y = 197 },
        .{ .x = 436, .y = 249 },
    };

    const polygon4 = [_]Point{
        .{ .x = 413, .y = 177 },
        .{ .x = 448, .y = 159 },
        .{ .x = 502, .y = 88 },
        .{ .x = 553, .y = 53 },
        .{ .x = 535, .y = 36 },
        .{ .x = 676, .y = 37 },
        .{ .x = 660, .y = 52 },
        .{ .x = 750, .y = 145 },
        .{ .x = 761, .y = 179 },
        .{ .x = 672, .y = 192 },
        .{ .x = 659, .y = 214 },
        .{ .x = 615, .y = 214 },
        .{ .x = 632, .y = 230 },
        .{ .x = 580, .y = 230 },
        .{ .x = 597, .y = 215 },
        .{ .x = 552, .y = 214 },
        .{ .x = 517, .y = 144 },
        .{ .x = 466, .y = 180 },
    };

    const polygon5 = [_]Point{
        .{ .x = 682, .y = 175 },
        .{ .x = 708, .y = 120 },
        .{ .x = 735, .y = 148 },
        .{ .x = 739, .y = 170 },
    };

    canvas.fillPolygon(&polygon1, .{ .r = 235, .g = 92, .b = 92 });
    canvas.fillPolygon(&polygon2, .{ .r = 72, .g = 132, .b = 232 });
    canvas.fillPolygon(&polygon3, .{ .r = 245, .g = 185, .b = 70 });
    canvas.fillPolygonWithHole(&polygon4, &polygon5, .{ .r = 74, .g = 173, .b = 111 });

    canvas.drawPolygon(&polygon1, .{ .r = 105, .g = 29, .b = 29 });
    canvas.drawPolygon(&polygon2, .{ .r = 29, .g = 69, .b = 135 });
    canvas.drawPolygon(&polygon3, .{ .r = 128, .g = 88, .b = 9 });
    canvas.drawPolygon(&polygon4, .{ .r = 20, .g = 91, .b = 47 });
    canvas.drawPolygon(&polygon5, .{ .r = 20, .g = 91, .b = 47 });

    try canvas.save("out.png");
}
