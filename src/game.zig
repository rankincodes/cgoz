const std = @import("std");

pub const Game = struct {
    allocator: std.mem.Allocator,
    state: []u64,
    rows: usize,
    cols: usize,

    pub fn init(allocator: std.mem.Allocator, rows: usize, cols: usize) !Game {
        const bits_required = rows * cols;
        const u64s_required = (bits_required + 63) / 64;
        const state = try allocator.alloc(u64, u64s_required);
        @memset(state, 0);

        return Game{
            .allocator = allocator,
            .state = state,
            .rows = rows,
            .cols = cols,
        };
    }

    pub fn deinit(self: *Game) void {
        self.allocator.free(self.state);
    }

    pub fn setCell(self: *Game, row: usize, col: usize, alive: bool) void {
        const idx = self.getIdx(row, col);

        if (alive) {
            self.state[idx.u64_idx] |= @as(u64, 1) << idx.bit_idx;
        } else {
            self.state[idx.u64_idx] &= ~(@as(u64, 1) << idx.bit_idx);
        }
    }

    pub fn getCell(self: *const Game, row: usize, col: usize) bool {
        const idx = self.getIdx(row, col);

        return (self.state[idx.u64_idx] & (@as(u64, 1) << idx.bit_idx)) != 0;
    }

    pub fn evolve(self: *Game) !void {
        var new_state = try self.allocator.alloc(u64, self.state.len);
        defer self.allocator.free(new_state);

        for (0..self.rows) |row| {
            for (0..self.cols) |col| {
                const alive_neighbors = self.countAliveNeighbors(row, col);
                const current_state = self.getCell(row, col);

                const next_state = switch (alive_neighbors) {
                    2 => current_state,
                    3 => true,
                    else => false,
                };

                const idx = self.getIdx(row, col);

                if (next_state) {
                    new_state[idx.u64_idx] |= @as(u64, 1) << idx.bit_idx;
                } else {
                    new_state[idx.u64_idx] &= ~(@as(u64, 1) << idx.bit_idx);
                }
            }
        }

        @memcpy(self.state, new_state);
    }

    fn countAliveNeighbors(self: *const Game, row: usize, col: usize) u8 {
        var count: u8 = 0;
        const offsets = [_][2]i8{
            .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
            .{ 0, -1 },  .{ 0, 1 },  .{ 1, -1 },
            .{ 1, 0 },   .{ 1, 1 },
        };

        for (offsets) |offset| {
            const check_row = @as(i32, @intCast(row)) + offset[0];
            const check_col = @as(i32, @intCast(col)) + offset[1];

            if (check_row >= 0 and check_row < self.rows and check_col >= 0 and check_col <= self.cols) {
                if (self.getCell(@intCast(check_row), @intCast(check_col))) {
                    count += 1;
                }
            }
        }

        return count;
    }

    fn getIdx(self: *const Game, row: usize, col: usize) struct { u64_idx: usize, bit_idx: u6 } {
        const grid_idx = row * self.cols + col;
        const u64_idx = grid_idx / 64;
        const bit_idx: u6 = @truncate(grid_idx % 64);

        return .{ .u64_idx = u64_idx, .bit_idx = bit_idx };
    }
};
