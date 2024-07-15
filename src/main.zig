const std = @import("std");
const d = @import("deque.zig");

const Token = struct { isOp: bool, value: usize };

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    const input = "21+70*10-80";

    // Parse input->output
    const output_stack = try parseInput(input);
    defer output_stack.deinit();

    // Solve
    var solve_stack = try d.Deque(Token).init(allocator);
    defer solve_stack.deinit();

    for (output_stack.buf) |c| {
        std.debug.print("{} : ", .{c.value});
    }
}

pub fn parseInput(input: *const [11:0]u8) !d.Deque(Token) {

    // Setup stacks
    var holding_stack = try d.Deque(Token).init(allocator);
    defer holding_stack.deinit();

    var output_stack = try d.Deque(Token).init(allocator);

    // Parse input
    var curNumb: usize = 0;
    for (input) |c| {
        if (isNumber(c)) {
            curNumb = (curNumb * 10) + parseNumber(c);
        } else {
            // Push number
            try output_stack.pushBack(Token{ .isOp = false, .value = curNumb });
            curNumb = 0;

            // Figure out operator
            const newOp = getOperator(c);
            const holding_stack_len = holding_stack.len();

            if (holding_stack_len > 0) {
                const last = holding_stack.get(holding_stack_len - 1).?.*;
                if (last.value > newOp) {
                    while (holding_stack.len() > 0) {
                        const oldOp = holding_stack.popBack().?;
                        try output_stack.pushBack(oldOp);
                    }
                }
            }

            try holding_stack.pushBack(Token{ .isOp = true, .value = newOp });
        }
    }

    // Drain anything remaining
    try output_stack.pushBack(Token{ .isOp = false, .value = curNumb });
    while (holding_stack.len() > 0) {
        const op = holding_stack.popBack().?;
        try output_stack.pushBack(op);
    }

    return output_stack;
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

pub fn getOperator(c: u8) u8 {
    switch (c) {
        '/' => {
            return 4;
        },
        '*' => {
            return 3;
        },
        '+' => {
            return 2;
        },
        '-' => {
            return 1;
        },
        else => {
            // TODO: ERROR
            return 0;
        },
    }
}
