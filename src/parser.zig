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
    var lastCharWasOp = true;
    var numberIsNegative = false;

    for (input) |c| {

        // Handle raw numbers
        if (isNumber(c)) {
            if (curNumb == null) {
                curNumb = parseNumber(c);
            } else {
                curNumb = (curNumb.? * 10) + parseNumber(c);
            }
            if (numberIsNegative) {
                curNumb.? *= -1;
                numberIsNegative = false;
            }
            lastCharWasOp = false;
            continue;
        }

        // If its not a number, check if this is an operator
        const op = getOperator(c);
        if (op == null) {
            // If its not an operator ignore the character
            continue;
        }
        // Otherwise handle operators

        // Handle negative numbers (e.g. "2 + -2")
        if (lastCharWasOp) {
            if (op.?.id == TokenId.addition) {
                if (op.?.value == '-') {
                    numberIsNegative = true;
                }
                continue;
            }
        }

        if (curNumb != null) {
            // Push number if we have one
            try output_stack.pushBack(Token{ .id = TokenId.noOperation, .value = curNumb.? });
            curNumb = null;
        }

        while (holding_stack.len() > 0) {
            const last = holding_stack.back().?.*;
            // If:
            // The new operator ID is greater than the current ID already on the stack AND this is not a closing enclosure...
            // OR if this is an open enclosure...
            //
            // We can break out of the loop and just add the current operator to the stack
            if ((@intFromEnum(last.id) < @intFromEnum(op.?.id) and op.?.id != TokenId.closed_enclosure) or op.?.id == TokenId.open_enclosure) {
                break;
            }
            // Otherwise we need to move stuff from the holding stack -> output stack
            const oldOp = holding_stack.popBack().?;
            if (oldOp.id == TokenId.open_enclosure) {
                // If this is the end of a enclosure block, break out
                // basically move everything between ( ) to the output stack
                break;
            }
            try output_stack.pushBack(oldOp);
        }

        // Dont add the closed enclosure to the holding stack
        if (op.?.id == TokenId.closed_enclosure) {
            continue;
        }

        // Push all other operators to holding stack
        try holding_stack.pushBack(op.?);

        // Set flag
        lastCharWasOp = true;
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
