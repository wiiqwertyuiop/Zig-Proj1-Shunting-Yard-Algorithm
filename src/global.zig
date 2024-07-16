pub const Token = struct { isOp: bool, value: usize };

pub var gpa = @import("std").heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();
