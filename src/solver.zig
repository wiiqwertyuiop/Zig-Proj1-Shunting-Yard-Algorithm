const d = @import("other/deque.zig");
const global = @import("global.zig");
const Token = global.Token;
const allocator = global.allocator;

const std = @import("std");

pub fn solve(rpn: *d.Deque(global.Token)) !isize {
    var solve_stack = try d.Deque(Token).init(allocator);
    defer solve_stack.deinit();

    while (rpn.len() > 0) {
        var token = rpn.popFront().?;
        // Handle operators
        if (token.id != 0) {
            // Handle operator
            // TODO: ERROR
            const right = solve_stack.popBack().?;
            const left = solve_stack.popBack().?;
            // Execute operator and generate new token
            token = executeOperator(left, right, token.value).?;
        }
        // Push token to solve stack
        try solve_stack.pushBack(token);
    }
    // The remaning item in the solve stack is the result
    return solve_stack.back().?.*.value;
}

pub fn executeOperator(left: Token, right: Token, op: isize) ?Token {
    switch (op) {
        '/' => {
            return Token{ .id = 0, .value = @divExact(left.value, right.value) };
        },
        '*' => {
            return Token{ .id = 0, .value = (left.value * right.value) };
        },
        '+' => {
            return Token{ .id = 0, .value = (left.value + right.value) };
        },
        '-' => {
            return Token{ .id = 0, .value = (left.value - right.value) };
        },
        else => {
            // TODO: ERROR
            return null;
        },
    }
}
