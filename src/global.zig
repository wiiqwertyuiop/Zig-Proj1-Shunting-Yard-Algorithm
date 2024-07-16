pub const Token = struct { id: i8, value: isize };

pub var gpa = @import("std").heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();
