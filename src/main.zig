const std = @import("std");
const d = @import("deque.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    //const input = "1+2*4-3";

    var holding_stack = try d.Deque(u16).init(allocator);
    defer holding_stack.deinit();

    var output_stack = try d.Deque(u16).init(allocator);
    defer output_stack.deinit();

    var solve_stack = try d.Deque(u16).init(allocator);
    defer solve_stack.deinit();

    try execute(&holding_stack, &output_stack, &solve_stack);

    std.debug.print("{}\n", .{solve_stack.get(0).?.*});
}

pub fn execute(holding_stack: *d.Deque(u16), output_stack: *d.Deque(u16), solve_stack: *d.Deque(u16)) !void {
    try holding_stack.pushFront(8);
    try output_stack.pushFront(69);
    try solve_stack.pushFront(72);
    try solve_stack.pushFront(100);
}
