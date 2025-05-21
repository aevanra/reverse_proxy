const std = @import("std");
const Config = @import("types/config.zig").Config;
const json = std.json;


pub fn get_config(arena: *std.heap.ArenaAllocator) !*Config {
    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("config.json", .{});
    defer file.close();

    const stat = try file.stat();
    const source = try file.readToEndAlloc(allocator, stat.size);

    var parsed = try json.parseFromSlice(Config, allocator, source, .{});
    defer parsed.deinit();

    return &parsed.value;

}


pub fn main() !void {
    const gpa = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    const config = try get_config(&arena);
    std.debug.print("Host: {s}, Port: {}\n", .{ config.server.host, config.server.listen_port });
}
