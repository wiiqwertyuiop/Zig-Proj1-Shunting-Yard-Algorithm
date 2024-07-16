pub const TokenId = enum(i8) {
    multiplication = 3,
    addition = 2,
    noOperation = 0,
    open_enclosure = -1,
    closed_enclosure = -2,
};
pub const Token = struct { id: TokenId, value: isize };

pub var gpa = @import("std").heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();
