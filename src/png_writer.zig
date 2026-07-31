const std = @import("std");

const image_width = @import("canvas.zig").image_width;
const image_height = @import("canvas.zig").image_height;

pub fn write(file_name: [:0]const u8, canvas: anytype) !void {
    const file = std.c.fopen(file_name, "wb") orelse return error.CouldNotOpenOutput;
    defer _ = std.c.fclose(file);

    try writeBytes(file, "\x89PNG\r\n\x1a\n");
    try writeChunk(file, "IHDR", &makeHeader());

    const allocator = std.heap.page_allocator;
    var raw_pixels = std.ArrayList(u8).empty;
    defer raw_pixels.deinit(allocator);
    try raw_pixels.ensureTotalCapacity(allocator, (image_width * 3 + 1) * image_height);

    for (canvas.pixels) |row| {
        try raw_pixels.append(allocator, 0);
        for (row) |pixel| {
            try raw_pixels.append(allocator, pixel.r);
            try raw_pixels.append(allocator, pixel.g);
            try raw_pixels.append(allocator, pixel.b);
        }
    }

    var compressed = std.ArrayList(u8).empty;
    defer compressed.deinit(allocator);
    try writeStoredZlib(&compressed, raw_pixels.items);

    try writeChunk(file, "IDAT", compressed.items);
    try writeChunk(file, "IEND", "");
}

fn makeHeader() [13]u8 {
    var header: [13]u8 = undefined;
    writeU32(header[0..4], image_width);
    writeU32(header[4..8], image_height);
    header[8] = 8;
    header[9] = 2;
    header[10] = 0;
    header[11] = 0;
    header[12] = 0;
    return header;
}

fn writeStoredZlib(output: *std.ArrayList(u8), bytes: []const u8) !void {
    const allocator = std.heap.page_allocator;

    try output.append(allocator, 0x78);
    try output.append(allocator, 0x01);

    var index: usize = 0;
    while (index < bytes.len) {
        const remaining = bytes.len - index;
        const block_size: u16 = @intCast(@min(remaining, 65535));
        const is_last_block: u8 = if (index + block_size >= bytes.len) 1 else 0;

        try output.append(allocator, is_last_block);
        try writeU16Little(output, block_size);
        try writeU16Little(output, ~block_size);
        try output.appendSlice(allocator, bytes[index .. index + block_size]);

        index += block_size;
    }

    var checksum: [4]u8 = undefined;
    writeU32(&checksum, adler32(bytes));
    try output.appendSlice(allocator, &checksum);
}

fn writeChunk(file: *std.c.FILE, chunk_name: *const [4]u8, data: []const u8) !void {
    var length: [4]u8 = undefined;
    writeU32(&length, @intCast(data.len));

    try writeBytes(file, &length);
    try writeBytes(file, chunk_name);
    try writeBytes(file, data);

    var crc = std.hash.Crc32.init();
    crc.update(chunk_name);
    crc.update(data);

    var crc_bytes: [4]u8 = undefined;
    writeU32(&crc_bytes, crc.final());
    try writeBytes(file, &crc_bytes);
}

fn writeBytes(file: *std.c.FILE, bytes: []const u8) !void {
    if (bytes.len == 0) return;

    const written = std.c.fwrite(bytes.ptr, 1, bytes.len, file);
    if (written != bytes.len) return error.OutputWriteFailed;
}

fn writeU16Little(output: *std.ArrayList(u8), value: u16) !void {
    const allocator = std.heap.page_allocator;
    try output.append(allocator, @intCast(value & 0xff));
    try output.append(allocator, @intCast(value >> 8));
}

fn writeU32(dest: []u8, value: u32) void {
    dest[0] = @intCast((value >> 24) & 0xff);
    dest[1] = @intCast((value >> 16) & 0xff);
    dest[2] = @intCast((value >> 8) & 0xff);
    dest[3] = @intCast(value & 0xff);
}

fn adler32(bytes: []const u8) u32 {
    const modulo = 65521;
    var a: u32 = 1;
    var b: u32 = 0;

    for (bytes) |byte| {
        a = (a + byte) % modulo;
        b = (b + a) % modulo;
    }

    return (b << 16) | a;
}
