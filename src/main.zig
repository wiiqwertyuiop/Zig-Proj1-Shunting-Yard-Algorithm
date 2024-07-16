const std = @import("std");
const parser = @import("parser.zig");
const solver = @import("solver.zig");

pub fn main() !void {
    const input = "3 + 3 + 3";
    std.debug.print("Input: {s}\n", .{input});

    // Parse input to RPN
    var rpn = try parser.reversePolishNotation(input);
    defer rpn.deinit();

    // Solve
    const result = try solver.solve(&rpn);
    std.debug.print("The result is: {}\n", .{result});
}
