const d = @import("other/deque.zig");
const global = @import("global.zig");
const Token = global.Token;
const allocator = global.allocator;

pub fn solve(rpn: *d.Deque(global.Token)) !usize {
    var solve_stack = try d.Deque(Token).init(allocator);
    defer solve_stack.deinit();

    while (rpn.len() > 0) {
        var token = rpn.popFront().?;
        if (token.isOp) {
            // Handle operator
            // TODO: ERROR
            const right = solve_stack.popBack().?;
            const left = solve_stack.popBack().?;
            // Execute operator and generate new token
            token = executeOperator(left, right, token.value).?;
        }
        try solve_stack.pushBack(token);
    }
    // The remaning item in the solve stack is the result
    return solve_stack.back().?.*.value;
}

pub fn executeOperator(left: Token, right: Token, op: usize) ?Token {
    switch (op) {
        4 => {
            return Token{ .isOp = false, .value = (left.value / right.value) };
        },
        3 => {
            return Token{ .isOp = false, .value = (left.value * right.value) };
        },
        2 => {
            return Token{ .isOp = false, .value = (left.value + right.value) };
        },
        1 => {
            return Token{ .isOp = false, .value = (left.value - right.value) };
        },
        else => {
            // TODO: ERROR
            return null;
        },
    }
}
