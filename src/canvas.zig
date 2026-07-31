const std = @import("std");
const png = @import("png_writer.zig");

pub const image_width = 800;
pub const image_height = 450;

pub const Point = struct {
    x: i32,
    y: i32,
};

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
};

pub const Canvas = struct {
    pixels: [image_height][image_width]Color,

    pub fn init() Canvas {
        return undefined;
    }

    pub fn clear(self: *Canvas, color: Color) void {
        for (&self.pixels) |*row| {
            for (row) |*pixel| {
                pixel.* = color;
            }
        }
    }

    pub fn putPixel(self: *Canvas, x: i32, y: i32, color: Color) void {
        if (x < 0 or y < 0) return;
        if (x >= image_width or y >= image_height) return;

        self.pixels[@intCast(y)][@intCast(x)] = color;
    }

    pub fn drawLine(self: *Canvas, start: Point, end: Point, color: Color) void {
        var x0 = start.x;
        var y0 = start.y;

        const dx: i32 = @intCast(@abs(end.x - start.x));
        const dy: i32 = -@as(i32, @intCast(@abs(end.y - start.y)));
        const step_x: i32 = if (start.x < end.x) 1 else -1;
        const step_y: i32 = if (start.y < end.y) 1 else -1;

        var error_value = dx + dy;

        while (true) {
            self.putPixel(x0, y0, color);
            if (x0 == end.x and y0 == end.y) break;

            const double_error = error_value * 2;
            if (double_error >= dy) {
                error_value += dy;
                x0 += step_x;
            }
            if (double_error <= dx) {
                error_value += dx;
                y0 += step_y;
            }
        }
    }

    pub fn drawPolygon(self: *Canvas, points: []const Point, color: Color) void {
        for (points, 0..) |point, index| {
            const next = points[(index + 1) % points.len];
            self.drawLine(point, next, color);
        }
    }

    pub fn fillPolygon(self: *Canvas, points: []const Point, color: Color) void {
        self.fillPolygonWithHole(points, null, color);
    }

    pub fn fillPolygonWithHole(self: *Canvas, outside: []const Point, hole: ?[]const Point, color: Color) void {
        var intersections: [96]i32 = undefined;

        var y: i32 = 0;
        while (y < image_height) : (y += 1) {
            var total: usize = 0;
            addScanlineCuts(outside, y, &intersections, &total);

            if (hole) |inside| {
                addScanlineCuts(inside, y, &intersections, &total);
            }

            std.sort.insertion(i32, intersections[0..total], {}, struct {
                fn lessThan(_: void, a: i32, b: i32) bool {
                    return a < b;
                }
            }.lessThan);

            var index: usize = 0;
            while (index + 1 < total) : (index += 2) {
                var x = intersections[index];
                const last_x = intersections[index + 1];

                while (x <= last_x) : (x += 1) {
                    self.putPixel(x, y, color);
                }
            }
        }
    }

    pub fn save(self: *const Canvas, file_name: [:0]const u8) !void {
        try png.write(file_name, self);
    }
};

fn addScanlineCuts(points: []const Point, y: i32, cuts: *[96]i32, total: *usize) void {
    for (points, 0..) |a, index| {
        const b = points[(index + 1) % points.len];
        if (a.y == b.y) continue;

        const top = @min(a.y, b.y);
        const bottom = @max(a.y, b.y);
        if (y < top or y >= bottom) continue;

        const x = @as(f64, @floatFromInt(a.x)) +
            (@as(f64, @floatFromInt(y - a.y)) * @as(f64, @floatFromInt(b.x - a.x))) /
            @as(f64, @floatFromInt(b.y - a.y));

        cuts[total.*] = @intFromFloat(@round(x));
        total.* += 1;
    }
}
