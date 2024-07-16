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
    var curNumb: usize = 0;
    for (input) |c| {

        // Check if this is an operator
        const op = getOperator(c);
        if (op != 0) {
            // Push number
            try output_stack.pushBack(Token{ .isOp = false, .value = curNumb });
            curNumb = 0;

            // Figure out operator

            while (holding_stack.len() > 0) {
                const last = holding_stack.back().?.*;
                if (last.value < op) {
                    break;
                }
                const oldOp = holding_stack.popBack().?;
                try output_stack.pushBack(oldOp);
            }

            try holding_stack.pushBack(Token{ .isOp = true, .value = op });
        } else if (isNumber(c)) {
            curNumb = (curNumb * 10) + parseNumber(c);
        }
    }

    // Flush anything remaining
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
