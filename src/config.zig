const std = @import("std");
const json = std.json;

const Resource = struct {
    name: []const u8,
    endpoint: []const u8,
    destination_url: []const u8,
};

pub const Config = struct {
    server: struct {
        host: []const u8,
        listen_port: u16
    },
    resources: []Resource,

    pub fn get(arena: *std.heap.ArenaAllocator) !Config {
        const allocator = arena.allocator();

        const file = try std.fs.cwd().openFile("config.json", .{});
        defer file.close();

        const stat = try file.stat();
        const source = try file.readToEndAlloc(allocator, stat.size);

        var parsed = try json.parseFromSlice(Config, allocator, source, .{});
        defer parsed.deinit();

        return parsed.value;
    }
};
