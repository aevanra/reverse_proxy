const std = @import("std");
const http = std.http;

pub fn handleRequest(request: *http.Server.Request) !void {
    // get the requested path
    const path = request.head.target;
    std.debug.print("{s}\n", .{path});

    if (std.mem.eql(u8,path,"/favicon.ico")) {
        std.debug.print("Favicon request caught!\n", .{});
        return;
    }

    // do stuff down below.
    try request.respond("hello world!", .{});
}
