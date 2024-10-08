const std = @import("std");
const Game = @import("game.zig").Game;
const testing = std.testing;

test "game init" {
    const allocator = testing.allocator;

    var game = try Game.init(allocator, 20, 20);
    defer game.deinit();

    try testing.expectEqual(@as(usize, 7), game.state.len);
    try testing.expectEqual(@as(usize, 20), game.rows);
    try testing.expectEqual(@as(usize, 20), game.cols);

    for (0..20) |row| {
        for (0..20) |col| {
            try testing.expect(!game.getCell(row, col));
        }
    }
}

test "Set and get cell" {
    const allocator = testing.allocator;

    var game = try Game.init(allocator, 10, 10);
    defer game.deinit();

    game.setCell(0, 0, true);
    game.setCell(3, 7, true);
    game.setCell(8, 9, true);
    game.setCell(3, 8, true);

    try testing.expect(game.getCell(0, 0));
    try testing.expect(game.getCell(0, 0));
    try testing.expect(game.getCell(0, 0));
    try testing.expect(game.getCell(0, 0));
    try testing.expect(!game.getCell(1, 3));
}

test "game evolution" {
    const allocator = testing.allocator;

    var game = try Game.init(allocator, 10, 10);
    defer game.deinit();

    game.setCell(3, 3, true);
    game.setCell(3, 4, true);
    game.setCell(3, 5, true);

    try game.evolve();

    try testing.expect(game.getCell(2, 4));
    try testing.expect(game.getCell(3, 4));
    try testing.expect(game.getCell(4, 4));
    try testing.expect(!game.getCell(3, 3));
    try testing.expect(!game.getCell(3, 5));

    try game.evolve();

    try testing.expect(game.getCell(3, 3));
    try testing.expect(game.getCell(3, 4));
    try testing.expect(game.getCell(3, 5));
    try testing.expect(!game.getCell(2, 4));
    try testing.expect(!game.getCell(4, 4));
}
