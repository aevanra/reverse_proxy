const std = @import("std");
const Config = @import("src/config.zig").Config;
const server = @import("src/server.zig");
const net = std.net;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    const config = try Config.get(&arena);
    std.debug.print("Host: {s}, Port: {}\n", .{ config.server.host, config.server.listen_port });
    const address = try net.Address.parseIp4(config.server.host, config.server.listen_port);

    var svr = try address.listen(net.Address.ListenOptions{});

    try server.runServer(&svr);
}


