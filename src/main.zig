const std = @import("std");
const d = @import("deque.zig");

const Token = struct { isOp: bool, value: usize };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = "21+2*45687844-3";

    // Setup stacks
    var holding_stack = try d.Deque(Token).init(allocator);
    defer holding_stack.deinit();

    var output_stack = try d.Deque(Token).init(allocator);
    defer output_stack.deinit();

    var solve_stack = try d.Deque(Token).init(allocator);
    defer solve_stack.deinit();

    // Parse input
    var curNumb: usize = 0;
    for (input) |c| {
        if (isNumber(c)) {
            curNumb = (curNumb * 10) + parseNumber(c);
        } else {
            try output_stack.pushBack(Token{ .isOp = false, .value = curNumb });
            curNumb = 0;
            try holding_stack.pushBack(Token{ .isOp = true, .value = c });
        }
    }
    try output_stack.pushBack(Token{ .isOp = false, .value = curNumb });

    // Solve
    for (output_stack.buf) |thing| {
        std.debug.print("{} ", .{thing.value});
    }
}

pub fn isNumber(c: u8) bool {
    if (c >= 48 and c <= 57) {
        return true;
    }
    return false;
}

pub fn parseNumber(c: u8) u8 {
    return c - 48;
}

pub fn isOperator(c: u8) bool {
    if (c >= 42 and c <= 47) {
        return true;
    }
    return false;
}
