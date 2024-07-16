const d = @import("other/deque.zig");
const global = @import("global.zig");
const Token = global.Token;
const TokenId = global.TokenId;
const allocator = global.allocator;

pub fn reversePolishNotation(input: []const u8) !d.Deque(Token) {

    // Setup stacks
    var holding_stack = try d.Deque(Token).init(allocator);
    defer holding_stack.deinit();

    var output_stack = try d.Deque(Token).init(allocator);

    // Parse input
    var curNumb: ?isize = null;
    for (input) |c| {

        // Handle raw numbers
        if (isNumber(c)) {
            if (curNumb == null) {
                curNumb = 0;
            }
            curNumb = (curNumb.? * 10) + parseNumber(c);
            continue;
        }

        // If its not a number, check if this is an operator
        const op = getOperator(c);
        if (op == null) {
            // If its not an operator ignore the character
            continue;
        }
        // Otherwise handle operators

        if (curNumb != null) {
            // Push number if we have one
            try output_stack.pushBack(Token{ .id = TokenId.noOperation, .value = curNumb.? });
            curNumb = null;
        }

        // If there are higher priority operators already on the stack...
        // move from holding -> output stack
        while (holding_stack.len() > 0) {
            const last = holding_stack.back().?.*;
            if (op.?.id != TokenId.closed_enclosure and (op.?.id == TokenId.open_enclosure or @intFromEnum(last.id) < @intFromEnum(op.?.id))) {
                // Take precedence if we are a opening bracket/parentheses
                // or higher ID
                break;
            }
            // Move from holding -> output stack
            const oldOp = holding_stack.popBack().?;
            if (oldOp.id == TokenId.open_enclosure) {
                // Don't add the open enclosure to the output stack
                break;
            }
            try output_stack.pushBack(oldOp);
        }

        // Dont add the closed enclosure to the holding stack
        if (op.?.id == TokenId.closed_enclosure) {
            continue;
        }

        // Push operator to holding stack
        try holding_stack.pushBack(op.?);
    }

    // Flush anything remaining
    if (curNumb != null) {
        try output_stack.pushBack(Token{ .id = TokenId.noOperation, .value = curNumb.? });
    }
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
            return Token{ .id = TokenId.open_enclosure, .value = '(' };
        },
        ')' => {
            return Token{ .id = TokenId.closed_enclosure, .value = ')' };
        },
        '[' => {
            return Token{ .id = TokenId.open_enclosure, .value = '[' };
        },
        ']' => {
            return Token{ .id = TokenId.closed_enclosure, .value = ']' };
        },
        '/' => {
            return Token{ .id = TokenId.multiplication, .value = '/' };
        },
        '*' => {
            return Token{ .id = TokenId.multiplication, .value = '*' };
        },
        '+' => {
            return Token{ .id = TokenId.addition, .value = '+' };
        },
        '-' => {
            return Token{ .id = TokenId.addition, .value = '-' };
        },
        else => {
            // TODO: ERROR
            return null;
        },
    }
}
