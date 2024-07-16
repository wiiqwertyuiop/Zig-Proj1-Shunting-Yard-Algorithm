const d = @import("other/deque.zig");
const global = @import("global.zig");
const Token = global.Token;
const allocator = global.allocator;

pub fn reversePolishNotation(input: []const u8) !d.Deque(Token) {

    // Setup stacks
    var holding_stack = try d.Deque(Token).init(allocator);
    defer holding_stack.deinit();

    var output_stack = try d.Deque(Token).init(allocator);

    // Parse input
    var curNumb: isize = 0;
    for (input) |c| {

        // Check if this is an operator
        const op = getOperator(c);
        if (op != null) {
            // Push number
            try output_stack.pushBack(Token{ .id = 0, .value = curNumb });
            curNumb = 0;

            // If there are higher priority operators already on the stack...
            // move from holding -> output stack
            while (holding_stack.len() > 0) {
                const last = holding_stack.back().?.*;
                if (op.?.id == -1 or last.id < op.?.id) {
                    // Take precedence if we are a opening bracket/parentheses
                    // or higher ID
                    break;
                }
                // Move from holding -> output stack
                const oldOp = holding_stack.popBack().?;
                try output_stack.pushBack(oldOp);
            }

            // Push operator to holding stack
            try holding_stack.pushBack(op.?);
        } else if (isNumber(c)) {
            // Otherwise handle number
            curNumb = (curNumb * 10) + parseNumber(c);
        }
    }

    // Flush anything remaining
    try output_stack.pushBack(Token{ .id = 0, .value = curNumb });
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

pub fn getOperator(c: u8) ?Token {
    switch (c) {
        '(' => {
            return Token{ .id = -1, .value = '(' };
        },
        ')' => {
            return Token{ .id = -2, .value = ')' };
        },
        '[' => {
            return Token{ .id = -1, .value = '[' };
        },
        ']' => {
            return Token{ .id = -2, .value = ']' };
        },
        '/' => {
            return Token{ .id = 3, .value = '/' };
        },
        '*' => {
            return Token{ .id = 3, .value = '*' };
        },
        '+' => {
            return Token{ .id = 2, .value = '+' };
        },
        '-' => {
            return Token{ .id = 2, .value = '-' };
        },
        else => {
            // TODO: ERROR
            return null;
        },
    }
}
