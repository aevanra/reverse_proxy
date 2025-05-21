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
    resources: []Resource
};
