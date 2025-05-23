const std = @import("std");
const http = std.http;
const Config = @import("config.zig").Config;

pub fn handleRequest(request: *http.Server.Request, config: *Config) !void {
    // get the requested path
    const path = request.head.target;
    // only search on the first item in path
    const search_path = getFirstSegment(path);

    // skip favicon requests
    if (std.mem.eql(u8,path,"/favicon.ico")) {
        return;
    }

    // search path against config for passthrough
    for (config.*.resources) |item| {
        if (std.mem.eql(u8,search_path,item.endpoint)) {
            std.debug.print("Matched {s}\n", .{item.endpoint});

            // pass through once we have a client build
            continue;
        }
    }

    // do stuff down below.
    try request.respond("hello world!", .{});
}

fn getFirstSegment(path: []const u8) []const u8 {
    var i: usize = 1;
    while (i < path.len): (i += 1) {
        if (path[i] == '/') {
            return path[0..i];
        }
    }

    return path;
}
