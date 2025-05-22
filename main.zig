const std = @import("std");
const Config = @import("types/config.zig").Config;
const json = std.json;
const net = std.net;
const http = std.http;

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
    const address = try net.Address.parseIp4(config.server.host, config.server.listen_port);

    var server = try address.listen(net.Address.ListenOptions{});

    try runServer(&server);
}

fn runServer(server: *net.Server,) !void {
    // listener loop
    while (true) {
        // accept requests
        var connection = server.accept() catch |err| {
            std.debug.print("Connection to client interrupted: {}\n", .{err});
            continue;
        };
        defer connection.stream.close();

        var read_buffer: [1024]u8 = undefined;
        var http_server = http.Server.init(connection, &read_buffer);

        var request = http_server.receiveHead() catch |err| {
            std.debug.print("Could not read head: {}\n", .{err});
            continue;
        };

        handleRequest(&request) catch |err| {
            std.debug.print("Request errored: {}", .{err});
            continue;
        };
    }
}

fn handleRequest(request: *http.Server.Request) !void {
    // do we see routes here?
    std.debug.print("{s}\n", .{request.head.target});
    // do stuff down below.
    try request.respond("hello world!", .{});
}
