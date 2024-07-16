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
        if (op.isOp != 0) {
            // Push number
            try output_stack.pushBack(Token{ .isOp = 0, .value = curNumb });
            curNumb = 0;

            // If there are higher priority operators already on the stack...
            // move from holding -> output stack
            while (holding_stack.len() > 0) {
                const last = holding_stack.back().?.*;
                if (last.isOp < op.isOp) {
                    // Take precedence if we are a higher priority operator
                    break;
                }
                // Move from holding -> output stack
                const oldOp = holding_stack.popBack().?;
                try output_stack.pushBack(oldOp);
            }

            // Push operator to holding stack
            try holding_stack.pushBack(op);
        } else if (isNumber(c)) {
            // Otherwise handle number
            curNumb = (curNumb * 10) + parseNumber(c);
        }
    }

    // Flush anything remaining
    try output_stack.pushBack(Token{ .isOp = 0, .value = curNumb });
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

pub fn getOperator(c: u8) Token {
    switch (c) {
        '/' => {
            return Token{ .isOp = 3, .value = 4 };
        },
        '*' => {
            return Token{ .isOp = 3, .value = 3 };
        },
        '+' => {
            return Token{ .isOp = 2, .value = 2 };
        },
        '-' => {
            return Token{ .isOp = 2, .value = 1 };
        },
        else => {
            // TODO: ERROR
            return Token{ .isOp = 0, .value = 0 };
        },
    }
}
