const std = @import("std");
const net = std.net;
const http = std.http;
const router = @import("router.zig");
const Config = @import("config.zig").Config;

pub fn runServer(server: *net.Server, config: *Config) !void {
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

        router.handleRequest(&request, config) catch |err| {
            std.debug.print("Request errored: {}", .{err});
            continue;
        };
    }
}
