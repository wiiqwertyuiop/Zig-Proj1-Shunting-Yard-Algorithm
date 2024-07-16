pub const Token = struct { isOp: u8, value: isize };

pub var gpa = @import("std").heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();
