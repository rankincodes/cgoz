const std = @import("std");
const TerminalControl = @import("terminal_control.zig").TerminalControl;
const Game = @import("game.zig").Game;

pub fn main() !void {
    // allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // terminal
    var term = try TerminalControl.init();
    defer term.deinit();
    try term.hideCursor();
    defer term.showCursor() catch {};
    try term.setColor(1, 0);

    // game
    const size = try term.getTerminalSize();
    var game = try Game.init(allocator, size.rows, size.cols);
    defer game.deinit();

    // Initialize with a simple blinker
    game.setCell(3, 3, true);
    game.setCell(3, 4, true);
    game.setCell(3, 5, true);

    while (true) {
        try term.clearScreen();
        try term.moveCursor(1, 1);
        // try term.stdout.print("Welcome to the game of life! ({}rows x {}cols : {}px x {}px)\n", .{ size.rows, size.cols, size.x_px, size.y_px });

        for (0..game.rows) |row| {
            for (0..game.cols) |col| {
                try term.stdout.print("{s}", .{if (game.getCell(row, col)) "■" else " "});
            }
        }

        // const input = try term.readChar();

        // switch (input) {
        //     'q' => break,
        //     'c' => {
        //         const color = std.crypto.random.intRangeAtMost(u8, 0, 255);
        //         try term.setColor(color, 0);
        //     },
        //     else => {},
        // }

        try game.evolve();
        std.time.sleep(std.time.ns_per_ms * 500);
    }

    try term.resetColor();
    try term.clearScreen();
    try term.moveCursor(1, 1);
}
